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

        // Tell Cargo to re-run build.rs if proto files change
        println!("cargo:rerun-if-changed={}", proto_path.display());

        tonic_prost_build::configure()
            .file_descriptor_set_path(out_dir.join(bin_file))
            .compile_protos(&[&proto_path], &[&proto_dir])?;
    }

    Ok(())
}
