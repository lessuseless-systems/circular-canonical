# Go .gitignore Generator

{
  gitignore_content = m%"# Go build artifacts
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out

# Go binary files
/bin/
/pkg/

# Go dependency directories
/vendor/

# Go mod cache
go.sum

# IDE files
.idea/
.vscode/
*.swp
*.swo
*~
.DS_Store

# Test coverage
coverage.out
coverage.html
*.coverprofile

# Environment files
.env
.env.local
.env.*.local

# Debug files
__debug_bin

# Temporary files
*.tmp
*.bak
*.log
"%,
}
