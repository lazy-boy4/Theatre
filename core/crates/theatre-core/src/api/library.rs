//! data-contract.md §10 — library locations.

use crate::{
    api::lifecycle,
    error::Result,
    library::{LibraryLocation, LocationKind, MediaEntry},
};

pub async fn list_library_locations() -> Result<Vec<LibraryLocation>> {
    lifecycle::library().list_locations()
}

pub async fn add_library_location(
    path: String,
    label: Option<String>,
    is_saf: bool,
) -> Result<LibraryLocation> {
    let kind = if is_saf {
        LocationKind::Saf
    } else {
        LocationKind::Filesystem
    };
    lifecycle::library().add_location(&path, kind, label.as_deref())
}

pub async fn remove_library_location(id: String) -> Result<()> {
    lifecycle::library().remove_location(&id)
}

pub async fn browse_folder(path: String) -> Result<Vec<MediaEntry>> {
    crate::library::Library::browse_directory(&path).await
}
