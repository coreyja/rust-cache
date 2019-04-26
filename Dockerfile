FROM rust:latest as build

RUN USER=root cargo new --bin rust-cache
WORKDIR /rust-cache
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
RUN cargo build --release

RUN rm src/*.rs
COPY ./src ./src

RUN rm ./target/release/deps/rust_cache* && cargo build --release

FROM buildpack-deps:stretch
COPY --from=build /rust-cache/target/release/rust-cache /usr/local/

COPY ruby.sh /usr/local/
ENTRYPOINT ["/usr/local/ruby.sh"]
