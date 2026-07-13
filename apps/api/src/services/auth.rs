use anyhow::Result;
use serde::Serialize;
// use crate::db;
use crate::state::AppState;

#[derive(Serialize)]
pub struct AuthToken {
    pub token: String,
}

pub async fn register(state: &AppState) -> Result<AuthToken> {
    Ok(AuthToken {
        token: String::from(""),
    })
}

pub async fn login(state: &AppState) -> Result<AuthToken> {
    Ok(AuthToken {
        token: String::from(""),
    })
}
