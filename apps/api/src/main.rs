mod handlers;
mod structs;
mod views;

use crate::handlers::db::connect;
use axum::{Router, routing::get};

#[tokio::main]
pub async fn main() {
    // Connect to db
    connect().await;

    // Routes
    let app = Router::new()
        .route("/", get(views::system::root))
        .route("/health", get(views::system::health))
        .route("/users/{id}", get(views::users::get_by_id))
        .route("/users/search", get(views::users::search))
        .route("/auth/register", get(views::auth::register))
        .route("/auth/login", get(views::auth::login));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
