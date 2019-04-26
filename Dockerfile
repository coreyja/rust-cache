FROM rust:latest

RUN mkdir /app
COPY . /app/
WORKDIR /app
RUN cargo build --release

RUN cp target/release/rust-cache /usr/local/
COPY ruby.sh /usr/local/

ENTRYPOINT ["/usr/local/ruby.sh"]
