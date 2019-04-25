FROM rust:latest

RUN cargo build --release

COPY target/release/rust-cache /usr/local/
COPY ruby.sh /usr/local/

ENTRYPOINT ["/usr/local/ruby.sh"]
