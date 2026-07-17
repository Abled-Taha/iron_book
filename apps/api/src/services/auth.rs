use crate::db::{auth, common};
use crate::state::AppState;
use anyhow::{Result, anyhow};
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
) -> Result<AuthToken> {
    if !common::verify_api_token(state, &api_token).await? {
        return Err(anyhow!("Api token doesn't exist"));
    }
    if auth::get_user_id_by_username(state, &data.username)
        .await?
        .is_some()
    {
        return Err(anyhow!("Username already exists"));
    }
    if auth::get_user_id_by_email(state, &data.email)
        .await?
        .is_some()
    {
        return Err(anyhow!("Email already exists"));
    }

    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
    match auth::register(&state, data, &token).await {
        Ok(_user_id) => Ok(AuthToken { token: token }),

        Err(err) => Err(err.into()),
    }
}

pub async fn login(state: &AppState, api_token: String, data: LoginRequest) -> Result<AuthToken> {
    if !common::verify_api_token(state, &api_token).await? {
        return Err(anyhow!("Api token doesn't exist"));
    }
    let user_id_opt = auth::get_user_id_by_email(state, &data.email).await?;
    let user_id = match user_id_opt {
        Some(id) => id,
        None => return Err(anyhow!("Invalid Credentials")),
    };
    let password_hash_opt = auth::get_password_hash_by_user_id(state, &user_id).await?;
    let password_hash = match password_hash_opt {
        Some(value) => value,
        None => return Err(anyhow!("Db error")),
    };
    if password_hash != data.password_hash {
        return Err(anyhow!("Invalid Credentials"));
    }

    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);

    match auth::login(&state, data, &token).await {
        Ok(_token) => Ok(AuthToken { token: token }),

        Err(err) => Err(err.into()),
    }
}
