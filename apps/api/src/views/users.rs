use axum::{
    Json,
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
};
use tracing::info;

use crate::errors::AppError;
use crate::services::users;
use crate::state::AppState;

pub async fn get_user_by_id(
    State(state): State<AppState>,
    Path(id): Path<i64>,
) -> Result<impl IntoResponse, AppError> {
    info!(path = "/users/:id", user_id = id, "Received HTTP request");

    let user = users::get_user_by_id(&state, id).await?;
    Ok((StatusCode::OK, Json(user)))
}

pub async fn search(
    State(state): State<AppState>,
    Query(filter): Query<users::SearchFilter>,
) -> Result<impl IntoResponse, AppError> {
    info!(
        path = "/users/search",
        email = filter.email.as_deref(),
        username = filter.username.as_deref(),
        "Received HTTP request"
    );

    let resp = users::search(&state, filter).await?;
    Ok((StatusCode::OK, Json(resp)))
}
