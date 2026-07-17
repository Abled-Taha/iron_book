use crate::services::auth;
use crate::state::AppState;
use anyhow::{Result, anyhow};
use chrono::{Duration, Utc};
use sqlx::{Postgres, Transaction};

pub async fn register(
    state: &AppState,
    data: auth::RegisterRequest,
    token: &String,
) -> Result<i64> {
    let mut tx: Transaction<'_, Postgres> = state.db.begin().await?;

    // Insert the user into the database and return their newly generated ID
    let user_id: i64 = sqlx::query_scalar!(
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

    // Set session expiration
    let expires_at = Utc::now() + Duration::days(365);

    // Insert the session into the database
    sqlx::query!(
        r#"
        INSERT INTO sessions (user_id, token, expires_at)
        VALUES ($1, $2, $3)
        "#,
        user_id,
        token,
        expires_at
    )
    .execute(&mut *tx)
    .await?;

    // Commit the transaction to finalize the insertions
    tx.commit().await?;

    Ok(user_id)
}

pub async fn get_user_id_by_username(
    state: &AppState,
    username: &str,
) -> Result<Option<i64>, sqlx::Error> {
    let user_id = sqlx::query_scalar!(
        r#"
        SELECT id
        FROM users
        WHERE username = $1
        "#,
        username.trim()
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(user_id)
}

pub async fn get_user_id_by_email(
    state: &AppState,
    email: &str,
) -> Result<Option<i64>, sqlx::Error> {
    let user_id = sqlx::query_scalar!(
        r#"
        SELECT id
        FROM users
        WHERE email = $1
        "#,
        email.trim()
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(user_id)
}

pub async fn login(state: &AppState, data: auth::LoginRequest, token: &String) -> Result<String> {
    let expires_at = Utc::now() + Duration::days(365);
    let user_id = get_user_id_by_email(state, &data.email).await?;
    if user_id.is_none() {
        return Err(anyhow!("Invalid credentials"));
    }

    // Instert the token in sessions table and return it
    let token_return: String = sqlx::query_scalar!(
        r#"
        INSERT INTO sessions (user_id, token, expires_at)
        VALUES ($1, $2, $3)
        RETURNING token
        "#,
        user_id,
        token,
        expires_at,
    )
    .fetch_one(&state.db)
    .await?;

    Ok(token_return)
}

pub async fn get_password_hash_by_user_id(
    state: &AppState,
    user_id: &i64,
) -> Result<Option<String>, sqlx::Error> {
    let password_hash = sqlx::query_scalar!(
        r#"
        SELECT password_hash
        FROM users
        WHERE id = $1
        "#,
        user_id
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(password_hash)
}
