# Dart pubspec.yaml Generator
# Generates Dart package manifest file

let config = import "../../../src/config.ncl" in

{
  pubspec_yaml = m%"
name: circular_protocol
description: Official Dart SDK for the Circular Protocol blockchain API
version: %{config.version}
homepage: https://github.com/circular-protocol/circular-dart
repository: https://github.com/circular-protocol/circular-dart
issue_tracker: https://github.com/circular-protocol/circular-dart/issues
documentation: https://github.com/circular-protocol/circular-dart#readme

environment:
  sdk: '>=2.19.0 <4.0.0'

dependencies:
  http: ^1.1.0
  crypto: ^3.0.3
  pointycastle: ^3.9.1
  asn1lib: ^1.5.3
  intl: ^0.19.0
  convert: ^3.1.1

dev_dependencies:
  test: ^1.24.0
  lints: ^2.1.0

# Topics help users discover your package
topics:
  - blockchain
  - api
  - sdk
  - circular-protocol

# Platforms supported
platforms:
  android:
  ios:
  linux:
  macos:
  web:
  windows:
"%,

  # Metadata
  metadata = {
    version = config.version,
    language = "Dart",
    package_manager = "pub",
  },
}
