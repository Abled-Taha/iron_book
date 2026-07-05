use crate::structs::Greeting;
use axum::Json;

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
