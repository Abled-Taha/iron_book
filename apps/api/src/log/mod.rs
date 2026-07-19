use anyhow::{Context, Result};
use chrono::Local;
use std::fs::{self, File, OpenOptions};
use std::io::{self, Write};
use std::path::PathBuf;
use std::sync::{Arc, Mutex};

use crate::state::AppState;

pub struct LogInfo {
    pub severity: String, // "INFO", "WARN", "ERROR", "CRITICAL"
    pub log: String,
}

// Dynamically resolves the project root, ensures the `logs` directory exists,
// and returns an opened handle to the target timestamped log file.
pub fn get_log_file() -> Result<Arc<Mutex<File>>> {
    // Target the workspace root directory safely
    let mut path = PathBuf::from(".");
    path.push("apps");
    path.push("api");
    path.push("logs");

    // Ensure the "logs" directory physically exists inside the root folder
    fs::create_dir_all(&path).context("Failed to ensure logs/ directory exists")?;

    // Format the specific filename: YYYY-MM-DD_HH-MM-SS.log
    let timestamp = Local::now().format("%Y-%m-%d_%H-%M-%S").to_string();
    path.push(format!("{}.log", timestamp));

    // Open file descriptor with persistent appending permissions
    let file = OpenOptions::new()
        .create(true)
        .write(true)
        .append(true)
        .open(path)
        .context("Failed to open or initialize systemic log file target")?;

    Ok(Arc::new(Mutex::new(file)))
}

// Consumes log data, outputs structured strings onto the console,
// and mirrors outputs safely onto local files.
pub fn write(log_info: LogInfo, state: &AppState) -> Result<()> {
    let current_time = Local::now().format("%H:%M:%S").to_string();
    let formatted_log = format!(
        "[{}][{}] => {}\n",
        current_time,
        log_info.severity.to_uppercase(),
        log_info.log
    );

    // Write instantly to CLI stream
    print!("{}", formatted_log);
    io::stdout()
        .flush()
        .context("Failed to flush stdout stream")?;

    // Lock file handle exclusively across working threads and apply outputs
    let mut file = state
        .log
        .lock()
        .map_err(|_| anyhow::anyhow!("Log mutex poisoned due to a panic in another thread"))?;

    file.write_all(formatted_log.as_bytes())
        .context("Failed writing bytes into persistent log volumes")?;
    file.flush()
        .context("Failed flushing buffers securely to persistent log storage disks")?;

    Ok(())
}
