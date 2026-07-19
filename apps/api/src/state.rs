use sqlx::PgPool;
use std::fs::File;
use std::sync::{Arc, Mutex};

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub log: Arc<Mutex<File>>,
}
