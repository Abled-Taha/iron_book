use serde::{Deserialize, Serialize};
use tracing::{info, warn};

use crate::db::common;
use crate::errors::AppError;
use crate::state::AppState;

#[derive(Debug, Deserialize)]
pub struct SearchFilter {
    pub email: Option<String>,
    pub username: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct UserResponse {
    pub id: i64,
    pub username: String,
}

pub async fn get_user_by_id(state: &AppState, id: i64) -> Result<UserResponse, AppError> {
    info!(user_id = id, "Processing get_user_by_id request");

    let username_opt = common::get_username_by_id(state, &id).await?;
    let username = match username_opt {
        Some(value) => value,
        None => {
            warn!(user_id = id, "User not found by ID");
            return Err(AppError::InvalidCredentials);
        }
    };

    Ok(UserResponse { id, username })
}

pub async fn search(state: &AppState, filter: SearchFilter) -> Result<UserResponse, AppError> {
    info!(
        email = filter.email.as_deref(),
        username = filter.username.as_deref(),
        "Processing user search request"
    );

    if let Some(email) = filter.email {
        let user_id = common::get_user_id_by_email(state, &email)
            .await?
            .ok_or_else(|| {
                warn!(email = %email, "Search failed: user not found by email");
                AppError::InvalidCredentials
            })?;

        let username = common::get_username_by_id(state, &user_id)
            .await?
            .ok_or_else(|| {
                warn!(
                    user_id = user_id,
                    "Search failed: username not found for user_id"
                );
                AppError::InvalidCredentials
            })?;

        Ok(UserResponse {
            id: user_id,
            username,
        })
    } else if let Some(username) = filter.username {
        let user_id = common::get_user_id_by_username(state, &username)
            .await?
            .ok_or_else(|| {
                warn!(username = %username, "Search failed: user not found by username");
                AppError::InvalidCredentials
            })?;

        Ok(UserResponse {
            id: user_id,
            username: username.trim().to_string(),
        })
    } else {
        warn!("Search request missing both email and username filters");
        Err(AppError::InvalidCredentials)
    }
}
