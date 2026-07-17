use tonic::{Request, Response, Status};

use crate::proto::auth::{
    LoginRequest, LoginResponse, RegisterRequest, RegisterResponse,
    auth_service_server::AuthService,
};

use crate::services::auth;
use crate::state::AppState;

pub struct AuthGrpcService {
    pub state: AppState,
}

#[tonic::async_trait]
impl AuthService for AuthGrpcService {
    async fn register(
        &self,
        request: Request<RegisterRequest>,
    ) -> Result<Response<RegisterResponse>, Status> {
        let req = request.into_inner();
        let data = auth::RegisterRequest {
            email: req.email,
            username: req.username,
            password_hash: req.password_hash,
            salt: req.salt,
        };

        let resp = auth::register(&self.state, data)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;

        Ok(Response::new(RegisterResponse { token: resp.token }))
    }

    async fn login(
        &self,
        _request: Request<LoginRequest>,
    ) -> Result<Response<LoginResponse>, Status> {
        let resp = auth::login(&self.state)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;

        Ok(Response::new(LoginResponse { token: resp.token }))
    }
}
