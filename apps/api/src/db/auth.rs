use crate::services::auth;
use crate::state::AppState;
use anyhow::Result;
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
        INSERT INTO users (username, email, password_hash, salt)
        VALUES ($1, $2, $3, $4)
        RETURNING id
        "#,
        data.username,
        data.email,
        data.password_hash,
        data.salt
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
