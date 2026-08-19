mod common;

use axum::extract::State;
use axum::response::IntoResponse;
use common::{cleanup_log, test_state};
use ironbook_api::views::system;

#[tokio::test]
async fn greet_handler_returns_200() {
    let (state, path) = test_state();
    let response = system::greet(State(state.clone()))
        .await
        .expect("handler succeeds")
        .into_response();

    assert_eq!(response.status(), axum::http::StatusCode::OK);
    drop(state);
    cleanup_log(path);
}

#[tokio::test]
async fn health_handler_returns_200() {
    let (state, path) = test_state();
    let response = system::health_report(State(state.clone()))
        .await
        .expect("handler succeeds")
        .into_response();

    assert_eq!(response.status(), axum::http::StatusCode::OK);
    drop(state);
    cleanup_log(path);
}
