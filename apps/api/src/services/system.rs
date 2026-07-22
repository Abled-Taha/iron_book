use crate::db::{common, system};
use crate::errors::AppError;
use crate::log;
use crate::state::AppState;
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

pub async fn greet(state: &AppState) -> Result<GreetResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving \"/\"".to_string(),
        },
        state,
    )
    .map_err(AppError::Internal)?;

    Ok(GreetResponse {
        message: String::from("Hello, World!"),
        status: String::from("success"),
    })
}

pub async fn health_report(state: &AppState) -> Result<HealthReportResponse, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving \"health\"".to_string(),
        },
        state,
    )
    .map_err(AppError::Internal)?;

    Ok(HealthReportResponse {
        overall: String::from("All OK!"),
    })
}

pub async fn generate_api_token(
    state: &AppState,
    api_token_opt: Option<String>,
    data: ApiTokenRequest,
) -> Result<ApiTokenResponse, AppError> {
    async fn generate_api_token_inner(
        state: &AppState,
        data: ApiTokenRequest,
    ) -> Result<String, AppError> {
        if data.name.trim().is_empty() {
            return Err(AppError::InvalidName);
        }
        if data.owner_email.trim().is_empty() {
            return Err(AppError::InvalidOwnerEmail);
        }
        if system::get_api_token_by_name(state, &data.name)
            .await?
            .is_some()
        {
            return Err(AppError::ApiTokenNameAlreadyExists);
        }
        if system::get_api_token_by_owner_email(state, &data.owner_email)
            .await?
            .is_some()
        {
            return Err(AppError::ApiTokenOwnerEmailAlreadyExists);
        }

        let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
        system::store_api_token(state, data, &token).await?;
        Ok(token)
    }

    let api_token = api_token_opt.unwrap_or_default();

    if system::is_first_start(state).await? {
        let token = generate_api_token_inner(state, data).await?;
        Ok(ApiTokenResponse { token })
    } else {
        if !common::verify_api_token(state, &api_token).await? {
            return Err(AppError::InvalidApiToken);
        }
        let token = generate_api_token_inner(state, data).await?;
        Ok(ApiTokenResponse { token })
    }
}
