//! Axum-based loopback proxy server — architecture §9.

use super::session::ProxySessionStore;
use crate::{error::Result, net::NetClient};
use axum::{
    body::Body,
    extract::{Path, State},
    http::{Request, StatusCode},
    response::Response,
    routing::get,
    Router,
};
use std::sync::Arc;
use tokio::net::TcpListener;

#[derive(Clone)]
struct AppState {
    net: NetClient,
    sessions: Arc<ProxySessionStore>,
    // Maps job_id -> (stream_url, stream_headers, kind)
    jobs: Arc<tokio::sync::RwLock<std::collections::HashMap<String, JobInfo>>>,
}

#[derive(Clone)]
struct JobInfo {
    url: String,
    headers: std::collections::HashMap<String, String>,
    kind: String, // "direct" only (HLS spool arrives at M5)
}

pub struct ProxyServer {
    pub port: u16,
    state: AppState,
}

impl ProxyServer {
    pub async fn new(
        listener: TcpListener,
        net: NetClient,
        sessions: Arc<ProxySessionStore>,
    ) -> Result<Self> {
        let port = listener
            .local_addr()
            .map_err(|e| crate::error::TheatreError::Proxy {
                session: "init".into(),
                reason: e.to_string(),
            })?
            .port();
        let jobs = Arc::new(tokio::sync::RwLock::new(std::collections::HashMap::new()));
        let state = AppState {
            net,
            sessions,
            jobs,
        };
        let s2 = state.clone();

        let router = Router::new()
            .route("/d/{token}/{job_id}/{filename}", get(handle_download))
            .route("/health", get(|| async { "ok" }))
            .with_state(s2);

        tokio::spawn(async move {
            axum::serve(listener, router).await.ok();
        });

        Ok(Self { port, state })
    }

    /// Register a job so the proxy can serve it.
    pub async fn register_job(
        &self,
        job_id: &str,
        url: String,
        headers: std::collections::HashMap<String, String>,
        kind: &str,
    ) {
        let mut jobs = self.state.jobs.write().await;
        jobs.insert(
            job_id.to_owned(),
            JobInfo {
                url,
                headers,
                kind: kind.to_owned(),
            },
        );
    }

    /// Generate a download URL for a registered job.
    pub fn download_url(&self, job_id: &str, filename: &str) -> String {
        self.state
            .sessions
            .generate_url(self.port, job_id, filename)
    }

    pub fn active_sessions(&self) -> Vec<super::session::ProxySession> {
        self.state.sessions.list_active()
    }
}

async fn handle_download(
    State(state): State<AppState>,
    Path((token, job_id, _filename)): Path<(String, String, String)>,
    req: Request<Body>,
) -> Response<Body> {
    // Security: validate token
    if !state.sessions.validate_token(&token) {
        return Response::builder()
            .status(StatusCode::FORBIDDEN)
            .body(Body::empty())
            .unwrap();
    }

    // Look up job
    let job_info = {
        let jobs = state.jobs.read().await;
        jobs.get(&job_id).cloned()
    };
    let Some(job) = job_info else {
        return Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(Body::empty())
            .unwrap();
    };

    let session_id = uuid::Uuid::now_v7().to_string();
    state.sessions.start_session(&session_id, &job_id);

    // Extract Range header from client
    let range = req
        .headers()
        .get("range")
        .and_then(|v| v.to_str().ok())
        .map(|s| s.to_owned());

    match job.kind.as_str() {
        "direct" => serve_direct(&state.net, &job, range, session_id, state.sessions.clone()).await,
        // HLS spool serving arrives at M5; reject anything else.
        _ => Response::builder()
            .status(StatusCode::BAD_REQUEST)
            .body(Body::empty())
            .unwrap(),
    }
}

async fn serve_direct(
    net: &NetClient,
    job: &JobInfo,
    range: Option<String>,
    sess_id: String,
    sessions: Arc<ProxySessionStore>,
) -> Response<Body> {
    let mut headers = job.headers.clone();
    if let Some(r) = range {
        headers.insert("Range".to_owned(), r);
    }

    match net.get(&job.url, &headers).await {
        Ok(upstream) => {
            let status = upstream.status().as_u16();
            let content_len = upstream.content_length();
            let content_type = upstream
                .headers()
                .get("content-type")
                .and_then(|v| v.to_str().ok())
                .unwrap_or("video/mp4")
                .to_owned();

            let byte_stream = upstream.bytes_stream();
            let body = Body::from_stream(byte_stream);

            let mut builder = Response::builder()
                .status(status)
                .header("content-type", content_type)
                .header("accept-ranges", "bytes");
            if let Some(len) = content_len {
                builder = builder.header("content-length", len);
            }
            sessions.end_session(&sess_id);
            builder
                .body(body)
                .unwrap_or_else(|_| Response::builder().status(500).body(Body::empty()).unwrap())
        }
        Err(e) => {
            sessions.end_session(&sess_id);
            Response::builder()
                .status(502)
                .body(Body::from(e.to_string()))
                .unwrap()
        }
    }
}
