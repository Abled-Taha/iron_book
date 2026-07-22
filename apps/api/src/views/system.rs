use axum::{
    Json,
    extract::State,
    http::{HeaderMap, StatusCode},
    response::IntoResponse,
};

use crate::state::AppState;
use crate::{log, services::system};

pub async fn greet(State(state): State<AppState>) -> impl IntoResponse {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "HTTP request on \"/\"".to_string(),
        },
        &state,
    )
    .expect("Logging Failed");
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
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "HTTP request on \"/health\"".to_string(),
        },
        &state,
    )
    .expect("Logging Failed");
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

pub async fn generate_api_token(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(payload): Json<system::ApiTokenRequest>,
) -> impl IntoResponse {
    let api_token_opt = headers
        .get("Authorization")
        .and_then(|value| value.to_str().ok())
        .map(|s| s.to_string());

    match system::generate_api_token(&state, api_token_opt, payload).await {
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
