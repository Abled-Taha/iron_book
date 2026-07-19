use anyhow::Result;
use serde::{Deserialize, Serialize};

// use crate::db;
use crate::state::AppState;

#[derive(Deserialize)]
pub struct SearchFilter {
    pub email: Option<String>,
    pub username: Option<String>,
}

#[derive(Serialize)]
pub struct UserResponse {
    pub id: u64,
    pub username: String,
}

pub async fn get_by_id(_state: &AppState, id: u64) -> Result<UserResponse> {
    Ok(UserResponse {
        id,
        username: id.to_string(),
    })
}

pub async fn search(_state: &AppState, filter: SearchFilter) -> Result<UserResponse> {
    if let Some(email) = filter.email {
        Ok(UserResponse {
            id: 1,
            username: email,
        })
    } else if let Some(username) = filter.username {
        Ok(UserResponse {
            id: 1,
            username: username,
        })
    } else {
        Ok(UserResponse {
            id: 0,
            username: String::from(""),
        })
    }
}
