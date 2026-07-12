use axum::Json;
use serde::Serialize;

#[derive(Serialize)]
pub struct Greeting {
    pub message: String,
    pub status: String,
}

pub async fn root() -> Json<Greeting> {
    let response = Greeting {
        message: String::from("Hello, World!"),
        status: String::from("success"),
    };

    Json(response)
}

pub async fn health() -> &'static str {
    // Later will be returning a health report
    "All OK!"
}
