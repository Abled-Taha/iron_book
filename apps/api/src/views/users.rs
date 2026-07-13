use crate::services::users;
use crate::state::AppState;
use axum::{
    Json,
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
};

pub async fn get_by_id(State(state): State<AppState>, Path(id): Path<u64>) -> impl IntoResponse {
    match users::get_by_id(&state, id).await {
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

pub async fn search(
    State(state): State<AppState>,
    Query(filter): Query<users::SearchFilter>,
) -> impl IntoResponse {
    match users::search(&state, filter).await {
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
