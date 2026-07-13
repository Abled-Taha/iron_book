use anyhow::Result;
use axum::{Router, routing::get};
use ironbook_api::grpc::auth::AuthGrpcService;
use ironbook_api::grpc::system::SystemGrpcService;
use ironbook_api::grpc::users::UsersGrpcService;
use ironbook_api::proto::auth::auth_service_server::AuthServiceServer;
use ironbook_api::proto::system::system_service_server::SystemServiceServer;
use ironbook_api::proto::users::users_service_server::UsersServiceServer;
use ironbook_api::views;
use ironbook_api::{db, proto, state::AppState};

#[tokio::main]
pub async fn main() -> Result<()> {
    // Connect to db
    let db = db::connect().await?;

    let state = AppState { db };

    // HTTP routes
    let app = Router::new()
        .route("/", get(views::system::greet))
        .route("/health", get(views::system::health_report))
        .route("/users/{id}", get(views::users::get_by_id))
        .route("/users/search", get(views::users::search))
        .route("/auth/register", get(views::auth::register))
        .route("/auth/login", get(views::auth::login))
        .with_state(state.clone());

    let http_server = async {
        let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await?;
        axum::serve(listener, app).await?;
        Ok::<(), anyhow::Error>(())
    };

    let grpc_server = async {
        let reflection = tonic_reflection::server::Builder::configure()
            .register_encoded_file_descriptor_set(proto::system::FILE_DESCRIPTOR_SET)
            .register_encoded_file_descriptor_set(proto::users::FILE_DESCRIPTOR_SET)
            .register_encoded_file_descriptor_set(proto::auth::FILE_DESCRIPTOR_SET)
            .build_v1()?;

        tonic::transport::Server::builder()
            .add_service(reflection)
            .add_service(SystemServiceServer::new(SystemGrpcService {
                state: state.clone(),
            }))
            .add_service(AuthServiceServer::new(AuthGrpcService {
                state: state.clone(),
            }))
            .add_service(UsersServiceServer::new(UsersGrpcService {
                state: state.clone(),
            }))
            .serve("0.0.0.0:50051".parse()?)
            .await?;

        Ok::<(), anyhow::Error>(())
    };

    tokio::try_join!(http_server, grpc_server)?;

    Ok(())
}
