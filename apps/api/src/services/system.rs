use crate::db::{common, system};
use crate::log;
use crate::state::AppState;
use anyhow::{Result, anyhow};
use rand::distr::{Alphanumeric, SampleString};
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct GreetResponse {
    pub message: String,
    pub status: String,
}

#[derive(Serialize)]
pub struct HealthReportResponse {
    pub overall: String,
}

#[derive(Deserialize)]
pub struct ApiTokenRequest {
    pub name: String,
    pub owner_email: String,
}

#[derive(Serialize)]
pub struct ApiTokenResponse {
    pub token: String,
}

pub async fn greet(state: &AppState) -> Result<GreetResponse> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving \"/\"".to_string(),
        },
        &state,
    )?;
    Ok(GreetResponse {
        message: String::from("Hello, World!"),
        status: String::from("success"),
    })
}

pub async fn health_report(state: &AppState) -> Result<HealthReportResponse> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving \"health\"".to_string(),
        },
        &state,
    )?;
    Ok(HealthReportResponse {
        overall: String::from("All OK!"),
    })
}

pub async fn generate_api_token(
    state: &AppState,
    api_token_opt: Option<String>,
    data: ApiTokenRequest,
) -> Result<ApiTokenResponse> {
    async fn generate_api_token(state: &AppState, data: ApiTokenRequest) -> Result<String> {
        if data.name.trim() == "" {
            return Err(anyhow!("Invalid name"));
        }
        if data.owner_email.trim() == "" {
            return Err(anyhow!("Invalid owner_email"));
        }
        if system::get_api_token_by_name(state, &data.name)
            .await?
            .is_some()
        {
            return Err(anyhow!("Api token name already exists"));
        }
        if system::get_api_token_by_owner_email(state, &data.owner_email)
            .await?
            .is_some()
        {
            return Err(anyhow!("Api token owner_email already exists"));
        }

        let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
        match system::store_api_token(state, data, &token).await {
            Ok(_bool) => Ok(token),
            Err(err) => Err(err),
        }
    }

    let api_token = match api_token_opt {
        Some(token) => token,
        None => String::from(""),
    };

    if system::is_first_start(state).await? {
        match generate_api_token(state, data).await {
            Ok(token) => return Ok(ApiTokenResponse { token }),
            Err(err) => return Err(err),
        };
    } else {
        if !common::verify_api_token(state, &api_token).await? {
            return Err(anyhow!("Api token doesn't exist"));
        }
        match generate_api_token(state, data).await {
            Ok(token) => return Ok(ApiTokenResponse { token }),
            Err(err) => return Err(err),
        };
    }
}
