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
) -> impl IntoResponse {
    let api_token_opt = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .map(|s| s.to_string());
    let api_token = match api_token_opt {
        Some(token) => token,
        None => {
            return (
                StatusCode::UNAUTHORIZED,
                Json(serde_json::json!({
                    "error":"Missing or invalid Authorization header"
                })),
            )
                .into_response();
        }
    };

    match auth::register(&state, api_token, payload).await {
        Ok(resp) => (StatusCode::OK, Json(resp)).into_response(),

        Err(err) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({
                "error": err.to_string()
            })),
        )
            .into_response(),
    }
}

pub async fn login(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<auth::LoginRequest>,
) -> impl IntoResponse {
    let api_token_opt = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .map(|s| s.to_string());
    let api_token = match api_token_opt {
        Some(token) => token,
        None => {
            return (
                StatusCode::UNAUTHORIZED,
                Json(serde_json::json!({
                    "error":"Missing or invalid Authorization header"
                })),
            )
                .into_response();
        }
    };

    match auth::login(&state, api_token, payload).await {
        Ok(resp) => (StatusCode::OK, Json(resp)).into_response(),

        Err(err) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!({
                "error": err.to_string()
            })),
        )
            .into_response(),
    }
}
