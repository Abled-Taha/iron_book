// use anyhow::Result;
// use sqlx::PgPool;

pub struct User {
    pub id: u64,
    pub username: String,
}

// pub async fn get_by_id(pool: &PgPool, id: i64) -> Result<User> {
//     let user = sqlx::query_as!(
//         User,
//         r#"
//         SELECT id, username
//         FROM users
//         WHERE id = $1
//         "#,
//         id
//     )
//     .fetch_one(pool)
//     .await?;

//     Ok(user)
// }
