FROM clux/muslrust as build

WORKDIR /rust-cache
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
COPY ./src ./src

RUN cargo build --release

FROM alpine:latest
COPY --from=build /rust-cache/target/x86_64-unknown-linux-musl/release/rust-cache /usr/local/

ENTRYPOINT ["/usr/local/rust-cache"]
