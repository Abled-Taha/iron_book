use sqlx::query_scalar;
use sqlx::{Postgres, Transaction};

use crate::errors::AppError;
use crate::services::system;
use crate::state::AppState;

pub async fn is_first_start(state: &AppState) -> Result<bool, AppError> {
    let count = query_scalar!(
        r#"
        SELECT COUNT(*) FROM clients
        "#
    )
    .fetch_one(&state.db)
    .await?;

    Ok(count.unwrap_or(0) == 0)
}

pub async fn get_api_token_by_name(
    state: &AppState,
    name: &str,
) -> Result<Option<String>, AppError> {
    let api_token = sqlx::query_scalar!(
        r#"
        SELECT api_token
        FROM clients
        WHERE name = $1
        "#,
        name.trim()
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(api_token)
}

pub async fn get_api_token_by_owner_email(
    state: &AppState,
    owner_email: &str,
) -> Result<Option<String>, AppError> {
    let api_token = sqlx::query_scalar!(
        r#"
        SELECT api_token
        FROM clients
        WHERE owner_email = $1
        "#,
        owner_email.trim()
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(api_token)
}

pub async fn store_api_token(
    state: &AppState,
    data: system::ApiTokenRequest,
    api_token: &String,
) -> Result<bool, AppError> {
    let mut tx: Transaction<'_, Postgres> = state.db.begin().await?;

    // Insert the client into the database
    sqlx::query!(
        r#"
        INSERT INTO clients (name, owner_email, api_token)
        VALUES ($1, $2, $3)
        "#,
        data.name,
        data.owner_email,
        api_token,
    )
    .execute(&mut *tx)
    .await?;

    // Commit the transaction to finalize the insertions
    tx.commit().await?;

    Ok(true)
}
