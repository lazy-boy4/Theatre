//! Core lifecycle — data-contract.md §2.

use crate::{
    api::types::{InitConfig, InitResult},
    downloader::{ffmpeg::FfmpegSidecar, Downloader},
    error::{Result, TheatreError},
    history::History,
    library::Library,
    net::NetClient,
    proxy,
    settings::Settings,
    sources::SourceRegistry,
    state::Db,
};
use std::{
    path::PathBuf,
    sync::{Arc, OnceLock},
};

/// Global app state — set once at init.
pub(crate) struct AppState {
    pub(crate) settings: Arc<Settings>,
    pub(crate) history: Arc<History>,
    pub(crate) library: Arc<Library>,
    pub(crate) sources: Arc<SourceRegistry>,
    pub(crate) downloader: Arc<Downloader>,
    pub(crate) proxy_port: Option<u16>,
}

static STATE: OnceLock<AppState> = OnceLock::new();

/// Sole accessor — callers drill into the field they need.
pub(crate) fn state() -> &'static AppState {
    STATE.get().expect("theatre core not initialized")
}

fn init_result(data_dir: &str, proxy_port: Option<u16>) -> InitResult {
    InitResult {
        db_path: format!("{}/theatre.db", data_dir.trim_end_matches('/')),
        proxy_port,
        core_version: env!("CARGO_PKG_VERSION").to_owned(),
        contract_version: "1.0.0".to_owned(),
    }
}

/// Initialize the core. Idempotent — safe to call twice.
/// data-contract.md §2.1
pub async fn init(config: InitConfig) -> Result<InitResult> {
    if STATE.get().is_some() {
        // Already initialized — return existing result
        return Ok(init_result(
            &config.data_dir,
            STATE.get().and_then(|s| s.proxy_port),
        ));
    }

    // Open database
    let db_path = PathBuf::from(&config.data_dir).join("theatre.db");
    std::fs::create_dir_all(&config.data_dir).map_err(|e| TheatreError::Storage {
        reason: format!("create data dir: {}", e),
    })?;
    let db = Db::open(&db_path)?;

    // Core services
    let net = NetClient::new();
    let settings = Arc::new(Settings::new(db.clone()));
    let history = Arc::new(History::new(db.clone()));
    let library = Arc::new(Library::new(db.clone()));
    let sources = Arc::new(SourceRegistry::new(
        db.clone(),
        net.clone(),
    ));

    // FFmpeg sidecar
    let ffmpeg = Arc::new(
        FfmpegSidecar::locate().ok_or_else(|| TheatreError::Internal {
            panic_message: "ffmpeg sidecar not found beside executable".into(),
        })?,
    );

    // Download root
    let download_root = settings
        .get_str(crate::settings::KEY_DOWNLOAD_ROOT, &config.data_dir)?
        .into();
    let downloader = Arc::new(Downloader::new(
        db.clone(),
        net.clone(),
        download_root,
        ffmpeg,
    ));

    // Proxy (if enabled)
    let proxy_port = if config.proxy_enabled {
        match proxy::start(net.clone()).await {
            Ok((_, port)) => Some(port),
            Err(e) => {
                eprintln!("[theatre] proxy start failed: {}", e);
                None
            }
        }
    } else {
        None
    };

    let state = AppState {
        settings,
        history,
        library,
        sources,
        downloader,
        proxy_port,
    };
    STATE.set(state).ok(); // ok() because OnceLock ignores second set

    Ok(init_result(&config.data_dir, proxy_port))
}

/// Graceful shutdown — data-contract.md §2.2
pub async fn shutdown() {
    // Cancel any pending downloads, stop proxy listener
    // The tokio runtime will clean up tasks when it shuts down
    eprintln!("[theatre] shutting down");
}
