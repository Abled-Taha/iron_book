use axum::extract::{Path, Query};

use crate::structs::SearchFilter;

pub async fn get_by_id(Path(id): Path<u64>) -> String {
    //Should have some actual logic
    format!("Fetching user with ID: {}", id) // This is a text response
}

pub async fn search(Query(filter): Query<SearchFilter>) -> String {
    if let Some(email) = filter.email {
        //Should have some actual logic
        return format!("Searching for user with email: {}", email); // This is a text response
    }
    if let Some(username) = filter.username {
        //Should have some actual logic
        return format!("Searching for user with username: {}", username); // This is a text response
    }
    "No search criteria provided".to_string() // This is a text response
}
