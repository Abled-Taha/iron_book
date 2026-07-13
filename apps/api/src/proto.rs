pub mod system {
    tonic::include_proto!("system");

    pub const FILE_DESCRIPTOR_SET: &[u8] = tonic::include_file_descriptor_set!("system");
}

pub mod auth {
    tonic::include_proto!("auth");

    pub const FILE_DESCRIPTOR_SET: &[u8] = tonic::include_file_descriptor_set!("auth");
}

pub mod users {
    tonic::include_proto!("users");

    pub const FILE_DESCRIPTOR_SET: &[u8] = tonic::include_file_descriptor_set!("users");
}
