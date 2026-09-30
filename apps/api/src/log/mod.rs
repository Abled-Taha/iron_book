use anyhow::{Context, Result};
use std::fs;
use std::path::PathBuf;
use tracing_appender::non_blocking::WorkerGuard;
use tracing_subscriber::{EnvFilter, fmt, prelude::*};

/// Initializes the non-blocking subscriber for application telemetry.
///
/// Returns a `WorkerGuard` that MUST be held in `main()` for the lifetime of
/// the application. When the guard drops, it flushes remaining log buffers.
pub fn init_tracing() -> Result<WorkerGuard> {
    let mut log_dir = PathBuf::from(".");
    log_dir.push("logs");

    // Ensure directory exists
    fs::create_dir_all(&log_dir).context("Failed to ensure logs/ directory exists")?;

    // Set up rolling daily log file appender (non-blocking thread pool worker)
    let file_appender = tracing_appender::rolling::daily(log_dir, "app.log");
    let (non_blocking_file, guard) = tracing_appender::non_blocking(file_appender);

    // Standard output layer (Human-readable / compact console output)
    let stdout_layer = fmt::layer().compact().with_writer(std::io::stdout);

    // Persistent file layer (Structured JSON format for analysis/parsing)
    let file_layer = fmt::layer().json().with_writer(non_blocking_file);

    // Combine layers into subscriber with environment filter (RUST_LOG or defaults to INFO)
    let filter = EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| EnvFilter::new("info,ironbook_api=debug"));

    tracing_subscriber::registry()
        .with(filter)
        .with(stdout_layer)
        .with(file_layer)
        .init();

    tracing::info!("Tracing framework initialized with non-blocking daily file writer");

    Ok(guard)
}
