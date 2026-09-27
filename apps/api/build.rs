use std::env;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let manifest_dir = PathBuf::from(env::var("CARGO_MANIFEST_DIR")?);
    let proto_dir = manifest_dir.join("proto");
    let out_dir = PathBuf::from(env::var("OUT_DIR")?);

    let protos = [
        ("system.proto", "system.bin"),
        ("users.proto", "users.bin"),
        ("auth.proto", "auth.bin"),
    ];

    for (proto_file, bin_file) in protos {
        let proto_path = proto_dir.join(proto_file);

        // Standardize paths to string slices for cross-platform protoc invocation
        let proto_path_str = proto_path.to_str().expect("Valid UTF-8 path");
        let proto_dir_str = proto_dir.to_str().expect("Valid UTF-8 path");

        println!("cargo:rerun-if-changed={}", proto_path_str);

        tonic_prost_build::configure()
            .file_descriptor_set_path(out_dir.join(bin_file))
            .compile_protos(&[proto_path_str], &[proto_dir_str])?;
    }

    Ok(())
}
