use anyhow::Result;
use serde::{Deserialize, Serialize};

use crate::db::common;
use crate::errors::AppError;
use crate::log;
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

pub async fn get_user_by_id(state: &AppState, id: u64) -> Result<UserResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving get_user_by_id".to_string(),
        },
        state,
    )?;
    let username_opt = common::get_username_by_id(&state, &id).await?;
    let username = match username_opt {
        Some(value) => value,
        None => return Err(AppError::InvalidCredentials),
    };
    Ok(UserResponse {
        id,
        username: username,
    })
}

pub async fn search(state: &AppState, filter: SearchFilter) -> Result<UserResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving search".to_string(),
        },
        state,
    )?;

    if let Some(email) = filter.email {
        let user_id = common::get_user_id_by_email(state, &email)
            .await?
            .ok_or(AppError::InvalidCredentials)?;

        let username = common::get_username_by_id(state, &user_id)
            .await?
            .ok_or(AppError::InvalidCredentials)?;

        Ok(UserResponse {
            id: user_id,
            username,
        })
    } else if let Some(username) = filter.username {
        let user_id = common::get_user_id_by_username(state, &username)
            .await?
            .ok_or(AppError::InvalidCredentials)?;

        Ok(UserResponse {
            id: user_id,
            username: username.trim().to_string(),
        })
    } else {
        Err(AppError::InvalidCredentials)
    }
}
