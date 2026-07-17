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
    pub salt: String,
}

pub async fn register(
    state: &AppState,
    api_token: String,
    data: RegisterRequest,
) -> Result<AuthToken> {
    if common::verify_api_token(state, &api_token).await?.is_none() {
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

pub async fn login(state: &AppState) -> Result<AuthToken> {
    Ok(AuthToken {
        token: String::from(""),
    })
}
