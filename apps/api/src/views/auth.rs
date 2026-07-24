use crate::errors::AppError;
use crate::log;
use crate::services::auth;
use crate::state::AppState;

use axum::{
    Json,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
};

pub async fn register(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<auth::RegisterRequest>,
) -> Result<impl IntoResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "HTTP request on \"/register\"".to_string(),
        },
        &state,
    )
    .map_err(AppError::Internal)?;

    let api_token = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .map(|s| s.to_string())
        .ok_or(AppError::InvalidApiToken)?;

    let resp = auth::register(&state, api_token, payload).await?;
    Ok((StatusCode::OK, Json(resp)))
}

pub async fn login(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<auth::LoginRequest>,
) -> Result<impl IntoResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "HTTP request on \"/login\"".to_string(),
        },
        &state,
    )
    .map_err(AppError::Internal)?;

    let api_token = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .map(|s| s.to_string())
        .ok_or(AppError::InvalidApiToken)?;

    let resp = auth::login(&state, api_token, payload).await?;
    Ok((StatusCode::OK, Json(resp)))
}
