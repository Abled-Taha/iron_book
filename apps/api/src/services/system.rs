use crate::state::AppState;
use anyhow::Result;
use serde::Serialize;
// use crate::db;

#[derive(Serialize)]
pub struct Greeting {
    pub message: String,
    pub status: String,
}

#[derive(Serialize)]
pub struct HealthReport {
    pub overall: String,
}

pub async fn greet(state: &AppState) -> Result<Greeting> {
    Ok(Greeting {
        message: String::from("Hello, World!"),
        status: String::from("success"),
    })
}

pub async fn health_report(state: &AppState) -> Result<HealthReport> {
    Ok(HealthReport {
        overall: String::from("All OK!"),
    })
}
