use ironbook_api::services::{auth, system, users};

#[test]
fn register_request_deserializes() {
    let request: auth::RegisterRequest =
        serde_json::from_str(r#"{"email":"test@example.com","username":"test","password":"hash"}"#)
            .expect("deserialize register request");

    assert_eq!(request.email, "test@example.com");
    assert_eq!(request.username, "test");
    assert_eq!(request.password, "hash");
}

#[test]
fn login_request_deserializes() {
    let request: auth::LoginRequest =
        serde_json::from_str(r#"{"email":"test@example.com","password":"hash"}"#)
            .expect("deserialize login request");

    assert_eq!(request.email, "test@example.com");
    assert_eq!(request.password, "hash");
}

#[test]
fn search_filter_supports_optional_fields() {
    let email_filter: users::SearchFilter =
        serde_json::from_str(r#"{"email":"a@example.com"}"#).expect("deserialize email filter");
    assert_eq!(email_filter.email.as_deref(), Some("a@example.com"));
    assert!(email_filter.username.is_none());

    let username_filter: users::SearchFilter =
        serde_json::from_str(r#"{"username":"alice"}"#).expect("deserialize username filter");
    assert_eq!(username_filter.username.as_deref(), Some("alice"));
    assert!(username_filter.email.is_none());
}

#[test]
fn api_token_request_deserializes() {
    let request: system::ApiTokenRequest =
        serde_json::from_str(r#"{"name":"my-client","owner_email":"owner@example.com"}"#)
            .expect("deserialize API token request");

    assert_eq!(request.name, "my-client");
    assert_eq!(request.owner_email, "owner@example.com");
}
