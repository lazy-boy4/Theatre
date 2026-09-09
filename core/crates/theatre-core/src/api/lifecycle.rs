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
    subtitles::SubtitleManager,
};
use std::{
    path::PathBuf,
    sync::{Arc, OnceLock},
};

/// Global app state — set once at init.
struct AppState {
    db: Db,
    settings: Arc<Settings>,
    history: Arc<History>,
    library: Arc<Library>,
    sources: Arc<SourceRegistry>,
    downloader: Arc<Downloader>,
    subtitles: Arc<SubtitleManager>,
    proxy_port: Option<u16>,
}

static STATE: OnceLock<AppState> = OnceLock::new();

pub fn state_db() -> &'static Db {
    &STATE.get().unwrap().db
}
pub fn settings() -> &'static Arc<Settings> {
    &STATE.get().unwrap().settings
}
pub fn history() -> &'static Arc<History> {
    &STATE.get().unwrap().history
}
pub fn library() -> &'static Arc<Library> {
    &STATE.get().unwrap().library
}
pub fn sources() -> &'static Arc<SourceRegistry> {
    &STATE.get().unwrap().sources
}
pub fn downloader() -> &'static Arc<Downloader> {
    &STATE.get().unwrap().downloader
}
pub fn subtitles() -> &'static Arc<SubtitleManager> {
    &STATE.get().unwrap().subtitles
}
pub fn proxy_port() -> Option<u16> {
    STATE.get().and_then(|s| s.proxy_port)
}

/// Initialize the core. Idempotent — safe to call twice.
/// data-contract.md §2.1
pub async fn init(config: InitConfig) -> Result<InitResult> {
    if STATE.get().is_some() {
        // Already initialized — return existing result
        return Ok(InitResult {
            db_path: format!("{}/theatre.db", config.data_dir),
            proxy_port: proxy_port(),
            core_version: env!("CARGO_PKG_VERSION").to_owned(),
            contract_version: "1.0.0".to_owned(),
        });
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
        settings.clone(),
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

    // Subtitles cache dir
    let subs_dir = PathBuf::from(&config.data_dir).join("subtitles");
    std::fs::create_dir_all(&subs_dir).ok();
    let subtitles = Arc::new(SubtitleManager::new(net.clone(), subs_dir));

    // Proxy (if enabled)
    let proxy_port = if config.proxy_enabled {
        match proxy::start(db.clone(), net.clone()).await {
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
        db,
        settings,
        history,
        library,
        sources,
        downloader,
        subtitles,
        proxy_port,
    };
    STATE.set(state).ok(); // ok() because OnceLock ignores second set

    Ok(InitResult {
        db_path: db_path.to_string_lossy().into_owned(),
        proxy_port,
        core_version: env!("CARGO_PKG_VERSION").to_owned(),
        contract_version: "1.0.0".to_owned(),
    })
}

/// Graceful shutdown — data-contract.md §2.2
pub async fn shutdown() {
    // Cancel any pending downloads, stop proxy listener
    // The tokio runtime will clean up tasks when it shuts down
    eprintln!("[theatre] shutting down");
}
