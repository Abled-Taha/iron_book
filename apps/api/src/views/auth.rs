use crate::errors::AppError;
use crate::services::auth;
use crate::state::AppState;

use axum::{
    Json,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
};
use tracing::info;

pub async fn register(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<auth::RegisterRequest>,
) -> Result<impl IntoResponse, AppError> {
    info!(
        path = "/register",
        username = %payload.username,
        email = %payload.email,
        "Received HTTP request"
    );

    let api_token = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .ok_or(AppError::InvalidApiToken)?;

    let resp = auth::register(&state, api_token, payload).await?;
    Ok((StatusCode::OK, Json(resp)))
}

pub async fn login(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<auth::LoginRequest>,
) -> Result<impl IntoResponse, AppError> {
    info!(
        path = "/login",
        email = %payload.email,
        "Received HTTP request"
    );

    let api_token = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .ok_or(AppError::InvalidApiToken)?;

    let resp = auth::login(&state, api_token, payload).await?;
    Ok((StatusCode::OK, Json(resp)))
}
