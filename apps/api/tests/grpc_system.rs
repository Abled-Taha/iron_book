mod common;

use common::test_state;
use ironbook_api::grpc::system::SystemGrpcService;
use ironbook_api::proto::system::{
    GreetRequest, HealthReportRequest, system_service_server::SystemService,
};
use tonic::{Code, Request};

#[tokio::test]
async fn greet_rpc_maps_service_response() {
    let state = test_state();
    let service = SystemGrpcService { state };

    let response = service
        .greet(Request::new(GreetRequest {}))
        .await
        .expect("greet RPC succeeds");

    assert_eq!(response.get_ref().message, "Hello, World!");
    assert_eq!(response.get_ref().status, "success");
}

#[tokio::test]
async fn health_rpc_maps_service_response() {
    let state = test_state();
    let service = SystemGrpcService { state };

    let response = service
        .health_report(Request::new(HealthReportRequest {}))
        .await
        .expect("health RPC succeeds");

    assert_eq!(response.get_ref().overall, "All OK!");
}

#[tokio::test]
async fn default_greet_request_is_accepted() {
    let state = test_state();
    let service = SystemGrpcService { state };

    let result = service.greet(Request::new(GreetRequest::default())).await;
    assert!(result.is_ok());
}

#[test]
fn grpc_error_codes_remain_compatible_with_http_error_contract() {
    // Sanity check for the adapter contract used by the gRPC services.
    assert_eq!(Code::Unauthenticated as i32, 16);
    assert_eq!(Code::AlreadyExists as i32, 6);
    assert_eq!(Code::InvalidArgument as i32, 3);
    assert_eq!(Code::Internal as i32, 13);
}
