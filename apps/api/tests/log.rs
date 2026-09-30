use tracing::info;
use tracing_subscriber::fmt::TestWriter;

#[test]
fn test_tracing_log_emission() {
    let subscriber = tracing_subscriber::fmt()
        .with_writer(TestWriter::new())
        .with_max_level(tracing::Level::INFO)
        .finish();

    tracing::subscriber::with_default(subscriber, || {
        info!("hello test log");
    });
}
