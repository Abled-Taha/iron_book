use crate::{errors::AppError, state::AppState};

pub async fn verify_api_token(state: &AppState, api_token: &str) -> Result<bool, AppError> {
    let api_token_opt = sqlx::query_scalar!(
        r#"
        SELECT api_token
        FROM clients
        WHERE api_token = $1
        "#,
        api_token
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(api_token_opt.is_some())
}

pub async fn get_user_id_by_username(
    state: &AppState,
    username: &str,
) -> Result<Option<i64>, AppError> {
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

pub async fn get_username_by_id(state: &AppState, id: &i64) -> Result<Option<String>, AppError> {
    if *id < 0 {
        return Err(AppError::InvalidCredentials);
    }
    let username = sqlx::query_scalar!(
        r#"
        SELECT username
        FROM users
        WHERE id = $1
        "#,
        id
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(username)
}

pub async fn get_user_id_by_email(state: &AppState, email: &str) -> Result<Option<i64>, AppError> {
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

pub async fn get_password_hash_by_user_id(
    state: &AppState,
    user_id: &i64,
) -> Result<Option<String>, AppError> {
    if *user_id < 0 {
        return Err(AppError::InvalidCredentials);
    }
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
