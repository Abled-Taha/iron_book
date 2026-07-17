use crate::services::auth;
use crate::state::AppState;

use axum::{Json, extract::State, http::StatusCode, response::IntoResponse};

pub async fn register(
    State(state): State<AppState>,
    Json(payload): Json<auth::RegisterRequest>,
) -> impl IntoResponse {
    let data = auth::RegisterRequest {
        email: payload.email,
        username: payload.username,
        password_hash: payload.password_hash,
        salt: payload.salt,
    };

    match auth::register(&state, data).await {
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

pub async fn login(State(state): State<AppState>) -> impl IntoResponse {
    match auth::login(&state).await {
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
