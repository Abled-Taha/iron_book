use crate::db::{auth, common};
use crate::errors::AppError;
use crate::log;
use crate::state::AppState;
use rand::distr::{Alphanumeric, SampleString};
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
pub struct AuthToken {
    pub token: String,
}

#[derive(Deserialize)]
pub struct RegisterRequest {
    pub email: String,
    pub username: String,
    pub password_hash: String,
}

#[derive(Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password_hash: String,
}

pub async fn register(
    state: &AppState,
    api_token: String,
    data: RegisterRequest,
) -> Result<AuthToken, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving \"register\"".to_string(),
        },
        state,
    )?;
    if !common::verify_api_token(state, &api_token).await? {
        return Err(AppError::InvalidApiToken);
    }
    if common::get_user_id_by_username(state, &data.username)
        .await?
        .is_some()
    {
        return Err(AppError::UsernameAlreadyExists);
    }
    if common::get_user_id_by_email(state, &data.email)
        .await?
        .is_some()
    {
        return Err(AppError::EmailAlreadyExists);
    }

    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
    auth::register(state, data, &token).await?;

    Ok(AuthToken { token })
}

pub async fn login(
    state: &AppState,
    api_token: String,
    data: LoginRequest,
) -> Result<AuthToken, AppError> {
    log::write(
        log::LogInfo {
            severity: "INFO".to_string(),
            log: "Serving \"login\"".to_string(),
        },
        state,
    )?;
    if !common::verify_api_token(state, &api_token).await? {
        return Err(AppError::InvalidApiToken);
    }
    let user_id_opt = common::get_user_id_by_email(state, &data.email).await?;
    let user_id = match user_id_opt {
        Some(id) => id,
        None => return Err(AppError::InvalidCredentials),
    };
    let password_hash_opt = common::get_password_hash_by_user_id(state, &user_id).await?;
    let password_hash = match password_hash_opt {
        Some(value) => value,
        None => return Err(AppError::InvalidCredentials),
    };
    if password_hash != data.password_hash {
        return Err(AppError::InvalidCredentials);
    }

    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
    auth::login(state, data, &token).await?;

    Ok(AuthToken { token })
}
