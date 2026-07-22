use anyhow::Result;
use axum::{
    Router,
    routing::{get, post},
};
use ironbook_api::{
    db,
    grpc::{auth::AuthGrpcService, system::SystemGrpcService, users::UsersGrpcService},
    log, proto,
    proto::{
        auth::auth_service_server::AuthServiceServer,
        system::system_service_server::SystemServiceServer,
        users::users_service_server::UsersServiceServer,
    },
    state::AppState,
    views,
};
use tokio::sync::broadcast;

#[tokio::main]
pub async fn main() -> Result<()> {
    let log_file = log::get_log_file()?;
    let db = db::connect().await?;
    let state = AppState { db, log: log_file };

    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "System initialized successfully.\n
                HTTP: http://localhost:8000/\n
                gRPC: localhost:50051"
                .to_string(),
        },
        &state,
    )?;

    // HTTP routes
    let app = Router::new()
        .route("/", get(views::system::greet))
        .route("/health", get(views::system::health_report))
        .route(
            "/generate_api_token",
            post(views::system::generate_api_token),
        )
        .route("/users/{id}", get(views::users::get_by_id))
        .route("/users/search", get(views::users::search))
        .route("/auth/register", post(views::auth::register))
        .route("/auth/login", post(views::auth::login))
        .with_state(state.clone());

    // 1. Setup a broadcast channel for fan-out shutdown signals
    let (tx, _) = broadcast::channel::<()>(1);
    let mut rx_http = tx.subscribe();
    let mut rx_grpc = tx.subscribe();

    // 2. Spawn a single listener task that catches Ctrl+C / SIGTERM
    let signal_state = state.clone();
    tokio::spawn(async move {
        let ctrl_c = async {
            tokio::signal::ctrl_c()
                .await
                .expect("failed to install Ctrl+C handler");
            "SIGINT (Ctrl+C)"
        };

        #[cfg(unix)]
        let terminate = async {
            tokio::signal::unix::signal(tokio::signal::unix::SignalKind::terminate())
                .expect("failed to install signal handler")
                .recv()
                .await;
            "SIGTERM"
        };

        #[cfg(not(unix))]
        let terminate = std::future::pending::<&str>();

        let signal_name = tokio::select! {
            sig = ctrl_c => sig,
            sig = terminate => sig,
        };

        let _ = log::write(
            log::LogInfo {
                severity: "WARN".to_string(),
                log: format!("{} received! Initiating graceful shutdown...", signal_name),
            },
            &signal_state,
        );

        // Notify both servers to drop out
        let _ = tx.send(());
    });

    // Futures that resolve ONLY when a message is explicitly broadcast
    let http_shutdown = async move {
        let _ = rx_http.recv().await;
    };
    let grpc_shutdown = async move {
        let _ = rx_grpc.recv().await;
    };

    let http_server = async {
        let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await?;
        axum::serve(listener, app)
            .with_graceful_shutdown(http_shutdown)
            .await?;
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
            .serve_with_shutdown("0.0.0.0:50051".parse()?, grpc_shutdown)
            .await?;

        Ok::<(), anyhow::Error>(())
    };

    // Run listeners concurrently
    tokio::try_join!(http_server, grpc_server)?;

    // --- APPLICATION CLEANUP LOGIC ---
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Executing final cleanup routines before termination...".to_string(),
        },
        &state,
    )?;

    state.db.close().await;

    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Application state destroyed safely. Goodbye!".to_string(),
        },
        &state,
    )?;

    std::process::exit(0);
}
