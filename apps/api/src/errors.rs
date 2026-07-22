use axum::{
    Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};
use serde_json::json;
use thiserror::Error;
use tonic::Status;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("API token does not exist")]
    InvalidApiToken,

    #[error("Username already exists")]
    UsernameAlreadyExists,

    #[error("Email already exists")]
    EmailAlreadyExists,

    #[error("Invalid credentials")]
    InvalidCredentials,

    #[error("Invalid name")]
    InvalidName,

    #[error("Invalid owner email")]
    InvalidOwnerEmail,

    #[error("API token name already exists")]
    ApiTokenNameAlreadyExists,

    #[error("API token owner email already exists")]
    ApiTokenOwnerEmailAlreadyExists,

    #[error("Database error: {0}")]
    DatabaseError(#[from] sqlx::Error),

    #[error("Internal error: {0}")]
    Internal(#[from] anyhow::Error),
}

impl AppError {
    pub fn code(&self) -> u32 {
        match self {
            AppError::InvalidApiToken => 1001,
            AppError::UsernameAlreadyExists => 1002,
            AppError::EmailAlreadyExists => 1003,
            AppError::InvalidCredentials => 1004,
            AppError::InvalidName => 1005,
            AppError::InvalidOwnerEmail => 1006,
            AppError::ApiTokenNameAlreadyExists => 1007,
            AppError::ApiTokenOwnerEmailAlreadyExists => 1008,
            AppError::DatabaseError(_) => 5000,
            AppError::Internal(_) => 5001,
        }
    }

    pub fn to_grpc_status(&self) -> Status {
        let grpc_code = match self {
            AppError::InvalidApiToken | AppError::InvalidCredentials => {
                tonic::Code::Unauthenticated
            }
            AppError::UsernameAlreadyExists | AppError::EmailAlreadyExists => {
                tonic::Code::AlreadyExists
            }
            AppError::InvalidName
            | AppError::InvalidOwnerEmail
            | AppError::ApiTokenNameAlreadyExists
            | AppError::ApiTokenOwnerEmailAlreadyExists => tonic::Code::InvalidArgument,
            AppError::DatabaseError(_) | AppError::Internal(_) => tonic::Code::Internal,
        };

        Status::new(
            grpc_code,
            format!("[code: {}] {}", self.code(), self.to_string()),
        )
    }

    pub fn http_status(&self) -> StatusCode {
        match self {
            AppError::InvalidApiToken | AppError::InvalidCredentials => StatusCode::UNAUTHORIZED,
            AppError::UsernameAlreadyExists | AppError::EmailAlreadyExists => StatusCode::CONFLICT,
            AppError::InvalidName
            | AppError::InvalidOwnerEmail
            | AppError::ApiTokenNameAlreadyExists
            | AppError::ApiTokenOwnerEmailAlreadyExists => StatusCode::BAD_REQUEST,
            AppError::DatabaseError(_) | AppError::Internal(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let status = self.http_status();
        let body = Json(json!({
            "error": self.to_string(),
            "code": self.code()
        }));
        (status, body).into_response()
    }
}
