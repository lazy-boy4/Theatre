//! data-contract.md §11 — settings.

use crate::{api::lifecycle, error::Result};

pub async fn get_setting(key: String) -> Result<Option<String>> {
    lifecycle::state().settings.get::<String>(&key)
}

pub async fn set_setting(key: String, value: String) -> Result<()> {
    lifecycle::state().settings.set(&key, &value)
}
