use crate::handlers::config;
use sqlx::PgPool;
use sqlx::postgres::{PgConnectOptions, PgPoolOptions};

#[derive(Clone)]
pub struct Db {
    pub pool: PgPool,
}

pub async fn connect() -> Db {
    let db_user = config::get("POSTGRES_USER").expect("POSTGRES_USER env var not set.");
    let db_password = config::get("POSTGRES_PASSWORD").expect("POSTGRES_PASSWORD env var not set.");
    let db_name = config::get("POSTGRES_DATABASE").expect("POSTGRES_DATABASE env var not set.");
    let db_host = config::get("POSTGRES_HOST").unwrap_or_else(|_| "localhost".to_string());
    let db_port = config::get("POSTGRES_PORT")
        .unwrap_or_else(|_| "5432".to_string())
        .parse()
        .expect("Invalid POSTGRES_PORT format. Must be a valid integer.");

    let options = PgConnectOptions::new()
        .host(&db_host)
        .port(db_port)
        .username(&db_user)
        .password(&db_password)
        .database(&db_name);

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect_with(options)
        .await
        .expect("Failed to connect to the database");

    Db { pool }
}
