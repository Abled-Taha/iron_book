use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let out_dir = PathBuf::from(std::env::var("OUT_DIR")?);

    tonic_prost_build::configure()
        .file_descriptor_set_path(out_dir.join("system.bin"))
        .compile_protos(&["proto/system.proto"], &["proto"])?;

    tonic_prost_build::configure()
        .file_descriptor_set_path(out_dir.join("users.bin"))
        .compile_protos(&["proto/users.proto"], &["proto"])?;

    tonic_prost_build::configure()
        .file_descriptor_set_path(out_dir.join("auth.bin"))
        .compile_protos(&["proto/auth.proto"], &["proto"])?;

    Ok(())
}
