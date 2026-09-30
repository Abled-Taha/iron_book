use ironbook_api::MIGRATOR;
use ironbook_api::state::AppState;
use sqlx::postgres::PgPoolOptions;

pub fn test_state() -> AppState {
    let db = PgPoolOptions::new()
        .connect_lazy("postgres://postgres:postgres@127.0.0.1:5432/ironbook_test")
        .expect("build lazy PostgreSQL pool");

    AppState { db }
}

#[allow(dead_code)] // It's being used in other test files
pub async fn init_db(pool: &sqlx::PgPool) {
    MIGRATOR
        .run(pool)
        .await
        .expect("failed to run database migrations");
}
