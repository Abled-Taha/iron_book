use axum::{
    Json,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
};
use tracing::info;

use crate::errors::AppError;
use crate::services::system;
use crate::state::AppState;

pub async fn greet(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    info!(path = "/", "Received HTTP request");

    let resp = system::greet(&state).await?;
    Ok((StatusCode::OK, Json(resp)))
}

pub async fn health_report(State(state): State<AppState>) -> Result<impl IntoResponse, AppError> {
    info!(path = "/health", "Received HTTP request");

    let resp = system::health_report(&state).await?;
    Ok((StatusCode::OK, Json(resp)))
}

pub async fn generate_api_token(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<system::ApiTokenRequest>,
) -> Result<impl IntoResponse, AppError> {
    info!(
        path = "/generate-token",
        token_name = %payload.name,
        owner_email = %payload.owner_email,
        "Received HTTP request"
    );

    let api_token_opt = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok());

    let resp = system::generate_api_token(&state, api_token_opt, payload).await?;
    Ok((StatusCode::OK, Json(resp)))
}
