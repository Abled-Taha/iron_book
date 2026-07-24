use crate::db::common;
use crate::errors::AppError;
use crate::log;
use crate::services::auth;
use crate::state::AppState;
use chrono::{Duration, Utc};
use sqlx::{Postgres, Transaction};

pub async fn register(
    state: &AppState,
    data: auth::RegisterRequest,
    token: &String,
) -> Result<u64, AppError> {
    let mut tx: Transaction<'_, Postgres> = state.db.begin().await?;

    // Insert the user into the database and return their newly generated ID
    let user_id_i64: i64 = sqlx::query_scalar!(
        r#"
        INSERT INTO users (username, email, password_hash)
        VALUES ($1, $2, $3)
        RETURNING id
        "#,
        data.username,
        data.email,
        data.password_hash,
    )
    .fetch_one(&mut *tx)
    .await?;

    // Convert returned DB i64 to u64
    let user_id_u64: u64 = user_id_i64.try_into().map_err(|_| {
        let _ = log::write(
            log::LogInfo {
                severity: "ERROR".to_string(),
                log: format!("Database generated negative or invalid user ID ({user_id_i64})"),
            },
            state,
        );
        AppError::Internal(anyhow::anyhow!("Invalid user ID returned from database"))
    })?;

    // Set session expiration
    let expires_at = Utc::now() + Duration::days(365);

    // Insert the session into the database
    sqlx::query!(
        r#"
        INSERT INTO sessions (user_id, token, expires_at)
        VALUES ($1, $2, $3)
        "#,
        user_id_i64,
        token,
        expires_at
    )
    .execute(&mut *tx)
    .await?;

    // Commit the transaction to finalize the insertions
    tx.commit().await?;

    Ok(user_id_u64)
}

pub async fn login(
    state: &AppState,
    data: auth::LoginRequest,
    token: &String,
) -> Result<String, AppError> {
    let expires_at = Utc::now() + Duration::days(365);

    let user_id_u64 = common::get_user_id_by_email(state, &data.email)
        .await?
        .ok_or(AppError::InvalidCredentials)?;

    let user_id_i64: i64 = user_id_u64.try_into().map_err(|_| {
        let _ = log::write(
            log::LogInfo {
                severity: "ERROR".to_string(),
                log: format!("User ID ({user_id_u64}) is too large for database i64"),
            },
            state,
        );
        AppError::InvalidCredentials
    })?;

    // Insert the token into sessions table and return it
    let token_return: String = sqlx::query_scalar!(
        r#"
        INSERT INTO sessions (user_id, token, expires_at)
        VALUES ($1, $2, $3)
        RETURNING token
        "#,
        user_id_i64,
        token,
        expires_at,
    )
    .fetch_one(&state.db)
    .await?;

    Ok(token_return)
}
