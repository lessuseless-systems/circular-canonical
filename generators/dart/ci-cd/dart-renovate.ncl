# Dart Renovate Configuration Generator
# Outputs renovate.json for Dart SDK

let shared_config = import "../../shared/ci-cd/renovate-config.ncl" in

{
  renovate_json = shared_config.dart_config,
}
