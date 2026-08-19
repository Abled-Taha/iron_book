use ironbook_api::config;

#[test]
fn get_reads_an_existing_environment_variable() {
    let value =
        config::get("CARGO_PKG_NAME").expect("CARGO_PKG_NAME should be available under Cargo");
    assert_eq!(value, "ironbook_api");
}

#[test]
fn get_returns_an_error_for_a_missing_variable() {
    let key = "IRONBOOK_API_TEST_SHOULD_NOT_EXIST_7D8BCE2A";
    unsafe {
        std::env::remove_var(key);
    }
    assert!(config::get(key).is_err());
}
