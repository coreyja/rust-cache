FROM rust:latest as build

WORKDIR /rust-cache
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
COPY ./src ./src

RUN cargo build --release

FROM buildpack-deps:stretch
COPY --from=build /rust-cache/target/release/rust-cache /usr/local/

ENTRYPOINT ["/usr/local/rust-cache"]
