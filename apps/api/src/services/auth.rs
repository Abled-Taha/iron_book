use crate::db::auth;
use crate::state::AppState;
use anyhow::Result;
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

pub async fn register(state: &AppState, data: RegisterRequest) -> Result<AuthToken> {
    // need to do some manual checks rather than throwing everything at the db
    let token = Alphanumeric.sample_string(&mut rand::rng(), 32);
    match auth::register(&state, data, &token).await {
        Ok(_user_id) => Ok(AuthToken { token: token }),

        Err(err) => Err(err),
    }
}

pub async fn login(state: &AppState) -> Result<AuthToken> {
    Ok(AuthToken {
        token: String::from(""),
    })
}
