use crate::handlers::config;
use crate::structs::Db;
use sqlx::postgres::PgPoolOptions;

pub async fn connect() -> Db {
    let db_user = config::get("POSTGRES_USER");
    let db_password = config::get("POSTGRES_PASSWORD");
    let db_name = config::get("POSTGRES_DATABASE");
    let db_url = &format!("postgres://{db_user}:{db_password}@localhost:5432/{db_name}");

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(db_url)
        .await
        .expect("Failed to connect to the database");

    Db { pool }
}
