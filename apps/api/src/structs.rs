use serde::{Deserialize, Serialize};
use sqlx::PgPool;

#[derive(Serialize)]
pub struct Greeting {
    pub message: String,
    pub status: String,
}

#[derive(Deserialize)]
pub struct SearchFilter {
    pub email: Option<String>,
    pub username: Option<String>,
}

#[derive(Clone)]
pub struct Db {
    pub pool: PgPool,
}
