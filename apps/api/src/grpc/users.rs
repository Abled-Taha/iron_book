use tonic::{Request, Response, Status};

use crate::proto::users::{
    GetByIdRequest, GetByIdResponse, SearchRequest, SearchResponse,
    users_service_server::UsersService,
};

use crate::services::users::{self, SearchFilter};
use crate::state::AppState;

pub struct UsersGrpcService {
    pub state: AppState,
}

#[tonic::async_trait]
impl UsersService for UsersGrpcService {
    async fn get_by_id(
        &self,
        request: Request<GetByIdRequest>,
    ) -> Result<Response<GetByIdResponse>, Status> {
        let req = request.into_inner();

        let resp = users::get_by_id(&self.state, req.id)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;

        Ok(Response::new(GetByIdResponse {
            id: resp.id,
            username: resp.username,
        }))
    }

    async fn search(
        &self,
        request: Request<SearchRequest>,
    ) -> Result<Response<SearchResponse>, Status> {
        let req = request.into_inner();
        let filter = SearchFilter {
            email: req.email,
            username: req.username,
        };
        let resp = users::search(&self.state, filter)
            .await
            .map_err(|e| Status::internal(e.to_string()))?;

        Ok(Response::new(SearchResponse {
            id: resp.id,
            username: resp.username,
        }))
    }
}
