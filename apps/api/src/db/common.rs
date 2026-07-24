use crate::{errors::AppError, log, state::AppState};

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
) -> Result<Option<u64>, AppError> {
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

    // Convert i64 -> u64
    let id_u64 = user_id
        .map(|id| id.try_into())
        .transpose()
        .map_err(|_| AppError::Internal(anyhow::anyhow!("Database returned negative user ID")))?;

    Ok(id_u64)
}

pub async fn get_username_by_id(state: &AppState, id: &u64) -> Result<Option<String>, AppError> {
    // Convert u64 -> i64
    let id_i64: i64 = match (*id).try_into() {
        Ok(num) => num,
        Err(_) => {
            log::write(
                log::LogInfo {
                    severity: "ERROR".to_string(),
                    log: format!("Provided u64 value ({id}) is too large for i64 database ID"),
                },
                state,
            )
            .map_err(AppError::Internal)?;
            return Ok(None);
        }
    };

    let username = sqlx::query_scalar!(
        r#"
        SELECT username
        FROM users
        WHERE id = $1
        "#,
        id_i64
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(username)
}

pub async fn get_user_id_by_email(state: &AppState, email: &str) -> Result<Option<u64>, AppError> {
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

    // Convert i64 -> u64
    let id_u64 = user_id
        .map(|id| id.try_into())
        .transpose()
        .map_err(|_| AppError::Internal(anyhow::anyhow!("Database returned negative user ID")))?;

    Ok(id_u64)
}

pub async fn get_password_hash_by_user_id(
    state: &AppState,
    user_id: &u64,
) -> Result<Option<String>, AppError> {
    // Convert u64 -> i64
    let id_i64: i64 = match (*user_id).try_into() {
        Ok(num) => num,
        Err(_) => return Ok(None),
    };

    let password_hash = sqlx::query_scalar!(
        r#"
        SELECT password_hash
        FROM users
        WHERE id = $1
        "#,
        id_i64
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(password_hash)
}
