//! Theatre Core — architecture §5.
//! Only `api/` is public; all other modules are internal.

pub mod api;

pub mod downloader;
pub mod error;
pub mod history;
pub mod library;
pub mod net;
pub mod proxy;
pub mod resolver;
pub mod settings;
pub mod sources;
pub mod state;
pub mod subtitles;

pub use error::TheatreError;
