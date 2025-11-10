# PHP .gitignore Generator
# Generates comprehensive .gitignore for PHP Composer projects

let config = import "../../../src/config.ncl" in

{
  gitignore_content = m%"
# PHP .gitignore
# Generated from Nickel specifications

# Composer
/vendor/
composer.phar
composer.lock

# PHPUnit
/phpunit.xml
/phpunit.xml.dist
/.phpunit.result.cache
/phpunit-coverage/

# PHP CS Fixer
.php_cs.cache
.php-cs-fixer.cache

# PHPStan
.phpstan.cache
phpstan.neon

# Psalm
.psalm/
psalm.xml

# Symfony
/var/
/var/cache/
/var/logs/
/var/sessions/

# Laravel
/bootstrap/cache/*
/storage/*.key
/storage/framework/cache/*
/storage/framework/sessions/*
/storage/framework/views/*
/storage/logs/*

# WordPress
wp-config.php
wp-content/uploads/
wp-content/cache/

# PHP Logs
*.log
error_log
php_error.log

# Temporary files
*.tmp
*.temp
*.swp
*.swo
*~

# IDE files
# PhpStorm
.idea/
*.iml

# VS Code
.vscode/
*.code-workspace

# NetBeans
nbproject/

# Eclipse
.settings/
.buildpath
.project

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini

# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# Environment files
.env
.env.local
.env.*.local

# Build artifacts
/build/
/dist/

# Coverage reports
/coverage/
clover.xml
coverage.xml
"%,
}
