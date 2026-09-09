//! Loopback download proxy — data-contract.md §9, architecture §9.
//! Binds 127.0.0.1:0, per-session random token, token-miss → 403.
//! Direct pass-through with Range forwarding;
//! HLS: spool-and-serve with backpressure.

pub mod server;
pub mod session;
pub mod spool;

pub use server::ProxyServer;
pub use session::{ProxySession, ProxySessionStore};

use crate::{error::Result, net::NetClient, state::Db};
use std::sync::Arc;
use tokio::net::TcpListener;

/// Start the loopback proxy server and return its live port.
pub async fn start(db: Db, net: NetClient) -> Result<(ProxyServer, u16)> {
    let listener =
        TcpListener::bind("127.0.0.1:0")
            .await
            .map_err(|e| crate::error::TheatreError::Proxy {
                session: "init".into(),
                reason: format!("bind failed: {}", e),
            })?;
    let port = listener
        .local_addr()
        .map_err(|e| crate::error::TheatreError::Proxy {
            session: "init".into(),
            reason: e.to_string(),
        })?
        .port();

    let session_store = Arc::new(ProxySessionStore::new(db));
    let server = ProxyServer::new(listener, net, session_store.clone()).await?;
    Ok((server, port))
}
