mod common;

use common::{cleanup_log, test_state};
use ironbook_api::log::{self, LogInfo};
use std::fs;

#[tokio::test]
async fn write_uppercases_severity_and_persists_message() {
    let (state, path) = test_state();

    log::write(
        LogInfo {
            severity: "warn".to_string(),
            log: "hello test log".to_string(),
        },
        &state,
    )
    .expect("write log entry");

    drop(state);
    let contents = fs::read_to_string(&path).expect("read test log");

    assert!(contents.contains("[WARN] => hello test log"));
    assert!(contents.ends_with('\n'));

    cleanup_log(path);
}

#[tokio::test]
async fn multiple_writes_append_to_the_same_file() {
    let (state, path) = test_state();

    log::write(
        LogInfo {
            severity: "info".to_string(),
            log: "first".to_string(),
        },
        &state,
    )
    .unwrap();
    log::write(
        LogInfo {
            severity: "ERROR".to_string(),
            log: "second".to_string(),
        },
        &state,
    )
    .unwrap();

    drop(state);
    let contents = fs::read_to_string(&path).unwrap();
    let lines: Vec<_> = contents.lines().collect();

    assert_eq!(lines.len(), 2);
    assert!(lines[0].contains("[INFO] => first"));
    assert!(lines[1].contains("[ERROR] => second"));

    cleanup_log(path);
}
