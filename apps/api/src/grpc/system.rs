use tonic::{Request, Response, Status};

use crate::proto::system::{
    ApiTokenRequest, ApiTokenResponse, GreetRequest, GreetResponse, HealthReportRequest,
    HealthReportResponse, system_service_server::SystemService,
};

use crate::services::system;
use crate::state::AppState;

pub struct SystemGrpcService {
    pub state: AppState,
}

#[tonic::async_trait]
impl SystemService for SystemGrpcService {
    async fn greet(
        &self,
        _request: Request<GreetRequest>,
    ) -> Result<Response<GreetResponse>, Status> {
        let greeting = system::greet(&self.state)
            .await
            .map_err(|e| e.to_grpc_status())?;

        Ok(Response::new(GreetResponse {
            message: greeting.message,
            status: greeting.status,
        }))
    }

    async fn health_report(
        &self,
        _request: Request<HealthReportRequest>,
    ) -> Result<Response<HealthReportResponse>, Status> {
        let health_report = system::health_report(&self.state)
            .await
            .map_err(|e| e.to_grpc_status())?;

        Ok(Response::new(HealthReportResponse {
            overall: health_report.overall,
        }))
    }

    async fn generate_api_token(
        &self,
        request: Request<ApiTokenRequest>,
    ) -> Result<Response<ApiTokenResponse>, Status> {
        let req = request.into_inner();
        let data = system::ApiTokenRequest {
            name: req.name,
            owner_email: req.owner_email,
        };

        let api_token = system::generate_api_token(&self.state, req.api_token, data)
            .await
            .map_err(|e| e.to_grpc_status())?;

        Ok(Response::new(ApiTokenResponse {
            token: api_token.token,
        }))
    }
}
