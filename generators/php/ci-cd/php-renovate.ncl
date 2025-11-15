# PHP Renovate Configuration Generator
# Outputs renovate.json for PHP SDK

let shared_config = import "../../shared/ci-cd/renovate-config.ncl" in

{
  renovate_json = shared_config.php_config,
}
