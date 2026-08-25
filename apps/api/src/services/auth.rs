use crate::db::{auth, common};
use crate::errors::AppError;
use crate::log;
use crate::state::AppState;
use argon2::{
    Argon2,
    password_hash::{PasswordHasher, SaltString, rand_core::OsRng},
};
use argon2::{PasswordHash, PasswordVerifier};
use rand::distr::{Alphanumeric, SampleString};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize)]
pub struct AuthToken {
    pub token: String,
}

#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub email: String,
    pub username: String,
    pub password: String,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
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

    // Hash password
    let argon2 = Argon2::default();
    let salt = SaltString::generate(&mut OsRng);
    let hashed_password = argon2
        .hash_password(data.password.as_bytes(), &salt)
        .unwrap()
        .to_string();
    let data2 = RegisterRequest {
        email: data.email,
        username: data.username,
        password: hashed_password,
    };

    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
    auth::register(state, data2, &token).await?;

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
        log::write(
            log::LogInfo {
                severity: "INFO".to_string(),
                log: "Bad API Token".to_string(),
            },
            state,
        )?;
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
    let argon2 = Argon2::default();
    let parsed_hash = PasswordHash::new(&password_hash).unwrap();
    let password_matched = argon2
        .verify_password(data.password.as_bytes(), &parsed_hash)
        .is_ok();
    if !password_matched {
        return Err(AppError::InvalidCredentials);
    }

    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
    auth::login(state, data, &token).await?;

    Ok(AuthToken { token })
}
