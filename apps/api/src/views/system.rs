use axum::{
    Json,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
};

use crate::errors::AppError;
use crate::log;
use crate::services::system;
use crate::state::AppState;

pub async fn greet(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "HTTP request on \"/\"".to_string(),
        },
        &state,
    )
    .map_err(AppError::Internal)?;

    let resp = system::greet(&state).await?;
    Ok((StatusCode::OK, Json(resp)))
}

pub async fn health_report(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "HTTP request on \"/health\"".to_string(),
        },
        &state,
    )
    .map_err(AppError::Internal)?;

    let resp = system::health_report(&state).await?;
    Ok((StatusCode::OK, Json(resp)))
}

pub async fn generate_api_token(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<system::ApiTokenRequest>,
) -> Result<impl IntoResponse, AppError> {
    let api_token_opt = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .map(|s| s.to_string());

    let resp = system::generate_api_token(&state, api_token_opt, payload).await?;
    Ok((StatusCode::OK, Json(resp)))
}
