# Rust Cargo.toml Generator

let config = import "../../../src/config.ncl" in

{
  cargo_toml = m%"[package]
name = "circular-protocol"
version = "%{config.version}"
edition = "2021"
rust-version = "1.70"
authors = ["Circular Protocol <dev@circular.org>"]
description = "Official Rust SDK for Circular Protocol blockchain"
license = "MIT"
repository = "https://github.com/circular-protocol/circular-canonical"
homepage = "https://circular.org"
documentation = "https://docs.rs/circular-protocol"
keywords = ["blockchain", "api", "sdk", "circular", "protocol"]
categories = ["api-bindings", "asynchronous", "web-programming::http-client"]

[dependencies]
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.0", features = ["full"] }
thiserror = "1.0"

[dev-dependencies]
tokio-test = "0.4"
mockito = "1.0"

[lib]
name = "circular_protocol"
path = "src/lib.rs"
"%,
}
