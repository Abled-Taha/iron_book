use crate::state::AppState;

pub async fn verify_api_token(
    state: &AppState,
    api_token: &str,
) -> Result<Option<String>, sqlx::Error> {
    let api_token_return = sqlx::query_scalar!(
        r#"
        SELECT api_token
        FROM clients
        WHERE api_token = $1
        "#,
        api_token
    )
    .fetch_optional(&state.db)
    .await?;

    Ok(api_token_return)
}
