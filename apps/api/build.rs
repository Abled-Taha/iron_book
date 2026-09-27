use std::env;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);

    // Resolve canonical absolute path to root /proto directory
    let root_proto_dir = manifest_dir
        .parent()
        .and_then(|p| p.parent())
        .expect("Failed to locate root workspace directory")
        .join("proto");

    let out_dir = PathBuf::from(env::var("OUT_DIR")?);

    let protos = [
        ("system.proto", "system.bin"),
        ("users.proto", "users.bin"),
        ("auth.proto", "auth.bin"),
    ];

    for (proto_file, bin_file) in protos {
        let proto_path = root_proto_dir.join(proto_file);

        println!("cargo:rerun-if-changed={}", proto_path.display());

        let proto_path_str = proto_path.to_str().expect("Valid UTF-8 path");
        let proto_dir_str = root_proto_dir.to_str().expect("Valid UTF-8 path");

        tonic_prost_build::configure()
            .file_descriptor_set_path(out_dir.join(bin_file))
            .compile_protos(&[proto_path_str], &[proto_dir_str])?;
    }

    Ok(())
}
