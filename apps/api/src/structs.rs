use serde::Serialize;

#[derive(Serialize)]
pub struct Greeting {
    pub message: String,
    pub status: String,
}
