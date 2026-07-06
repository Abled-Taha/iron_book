use axum::{Router, routing::get};

mod structs;
mod views;

#[tokio::main]
pub async fn main() {
    // Routes
    let app = Router::new()
        .route("/", get(views::system::root))
        .route("/health", get(views::system::health));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
