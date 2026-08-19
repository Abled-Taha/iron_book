mod common;

use axum::Json;
use axum::extract::State;
use axum::http::HeaderMap;
use common::{cleanup_log, test_state};
use ironbook_api::errors::AppError;
use ironbook_api::services::auth::{LoginRequest, RegisterRequest};
use ironbook_api::views::auth;

#[tokio::test]
async fn register_rejects_missing_authorization_header_before_database_access() {
    let (state, path) = test_state();

    let result = auth::register(
        State(state),
        HeaderMap::new(),
        Json(RegisterRequest {
            email: "test@example.com".into(),
            username: "test".into(),
            password_hash: "hash".into(),
        }),
    )
    .await;

    assert!(matches!(result, Err(AppError::InvalidApiToken)));
    cleanup_log(path);
}

#[tokio::test]
async fn login_rejects_missing_authorization_header_before_database_access() {
    let (state, path) = test_state();

    let result = auth::login(
        State(state),
        HeaderMap::new(),
        Json(LoginRequest {
            email: "test@example.com".into(),
            password_hash: "hash".into(),
        }),
    )
    .await;

    assert!(matches!(result, Err(AppError::InvalidApiToken)));
    cleanup_log(path);
}
