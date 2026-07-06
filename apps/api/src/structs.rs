use serde::{Deserialize, Serialize};

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
