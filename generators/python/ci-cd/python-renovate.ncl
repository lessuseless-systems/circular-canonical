# Python Renovate Configuration Generator
# Outputs renovate.json for Python SDK

let shared_config = import "../../shared/ci-cd/renovate-config.ncl" in

{
  renovate_json = shared_config.python_config,
}
