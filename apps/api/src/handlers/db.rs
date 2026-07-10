use crate::structs::Db;
use sqlx::postgres::PgPoolOptions;

pub async fn connect() -> Db {
    let db_url = "postgres://user:password@localhost:5432/ironbook";

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(db_url)
        .await
        .expect("Failed to connect to the database");

    Db { pool }
}
