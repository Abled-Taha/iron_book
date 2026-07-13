use axum::{Json, extract::State, http::StatusCode, response::IntoResponse};

use crate::services::system;
use crate::state::AppState;

pub async fn greet(State(state): State<AppState>) -> impl IntoResponse {
    match system::greet(&state).await {
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

pub async fn health_report(State(state): State<AppState>) -> impl IntoResponse {
    match system::health_report(&state).await {
        Ok(resp) => (StatusCode::OK, Json(resp)).into_response(),

        Err(err) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(serde_json::json!(
                {
                    "error": err.to_string()
                }
            )),
        )
            .into_response(),
    }
}
