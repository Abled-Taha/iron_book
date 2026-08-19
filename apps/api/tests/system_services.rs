mod common;

use common::{cleanup_log, test_state};
use ironbook_api::services::system;

#[tokio::test]
async fn greet_returns_expected_payload() {
    let (state, path) = test_state();
    let response = system::greet(&state).await.expect("greet succeeds");

    assert_eq!(response.message, "Hello, World!");
    assert_eq!(response.status, "success");

    drop(state);
    cleanup_log(path);
}

#[tokio::test]
async fn health_report_returns_expected_payload() {
    let (state, path) = test_state();
    let response = system::health_report(&state)
        .await
        .expect("health report succeeds");

    assert_eq!(response.overall, "All OK!");

    drop(state);
    cleanup_log(path);
}
