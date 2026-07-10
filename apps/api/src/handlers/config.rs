use std::env;

pub fn get(key: &str) -> Result<String, env::VarError> {
    // Get the directory where this specific crate's Cargo.toml lives
    if let Ok(manifest_dir) = env::var("CARGO_MANIFEST_DIR") {
        let dotenv_path = std::path::PathBuf::from(manifest_dir).join(".env");
        // Explicitly load the .env file from that specific path
        dotenvy::from_path(dotenv_path).ok();
    } else {
        // Fallback to standard directory traversal if not running via Cargo
        dotenvy::dotenv().ok();
    }

    env::var(key)
}
