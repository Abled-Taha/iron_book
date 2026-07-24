use crate::errors::AppError;
use crate::log;
use crate::services::users;
use crate::state::AppState;
use axum::{
    Json,
    extract::{Path, Query, State},
    http::StatusCode,
    response::IntoResponse,
};

pub async fn get_user_by_id(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<impl IntoResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: format!("HTTP request on \"/users/({id})\""),
        },
        &state,
    )
    .map_err(AppError::Internal)?;

    let user = users::get_user_by_id(&state, id).await?;
    Ok((StatusCode::OK, Json(user)))
}

pub async fn search(
    State(state): State<AppState>,
    Query(filter): Query<users::SearchFilter>,
) -> Result<impl IntoResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: format!("HTTP request on \"/users/search/\""),
        },
        &state,
    )
    .map_err(AppError::Internal)?;

    let resp = users::search(&state, filter).await?;
    Ok((StatusCode::OK, Json(resp)))
}
