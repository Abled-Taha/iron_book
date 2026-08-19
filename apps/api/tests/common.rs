use ironbook_api::MIGRATOR;
use ironbook_api::state::AppState;
use sqlx::postgres::PgPoolOptions;
use std::fs::{self, File};
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};

pub fn test_state() -> (AppState, PathBuf) {
    let unique = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("clock before unix epoch")
        .as_nanos();

    let path = std::env::temp_dir().join(format!(
        "ironbook-api-test-{}-{}.log",
        std::process::id(),
        unique
    ));

    let file = File::create(&path).expect("create test log file");
    let db = PgPoolOptions::new()
        .connect_lazy("postgres://postgres:postgres@127.0.0.1:5432/ironbook_test")
        .expect("build lazy PostgreSQL pool");

    (
        AppState {
            db,
            log: Arc::new(Mutex::new(file)),
        },
        path,
    )
}

pub fn cleanup_log(path: PathBuf) {
    let _ = fs::remove_file(path);
}

#[allow(dead_code)] // It's being used in other test files
pub async fn init_db(pool: &sqlx::PgPool) {
    MIGRATOR
        .run(pool)
        .await
        .expect("failed to run database migrations");
}
