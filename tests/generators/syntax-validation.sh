#!/bin/bash
# TEMPORARY: Manual file until Sprint 3 Phase 2 generator is created
# Will be replaced by: generators/shared/test-runners/syntax-validator.ncl → dist/tests/syntax-validation.sh
# Generator Syntax Validation Script
# Validates that generated code is syntactically correct

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Generator Syntax Validation${NC}"
echo "============================"
echo ""

PASSED=0
FAILED=0

# Create temp directory for outputs
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo "Generating artifacts to $TEMP_DIR..."
echo ""

# TypeScript Validation
echo -n "TypeScript SDK... "
if [ -f "generators/typescript-sdk.ncl" ]; then
    if nickel export generators/typescript-sdk.ncl > "$TEMP_DIR/client.ts" 2>/dev/null; then
        # Check if TypeScript compiler is available
        if command -v npx &> /dev/null; then
            if npx typescript $TEMP_DIR/client.ts --noEmit --skipLibCheck 2>/dev/null; then
                echo -e "${GREEN}✓ Valid TypeScript${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ Invalid TypeScript syntax${NC}"
                npx typescript $TEMP_DIR/client.ts --noEmit --skipLibCheck 2>&1 | head -10
                FAILED=$((FAILED + 1))
            fi
        else
            echo -e "${YELLOW}⚠ TypeScript not installed (npx not found)${NC}"
            echo "  Generated but not validated"
        fi
    else
        echo -e "${RED}✗ Generation failed${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠ Generator not found${NC}"
fi

# Python Validation
echo -n "Python SDK... "
if [ -f "generators/python-sdk.ncl" ]; then
    if nickel export generators/python-sdk.ncl > "$TEMP_DIR/client.py" 2>/dev/null; then
        # Check if Python is available
        if command -v python3 &> /dev/null; then
            if python3 -m py_compile "$TEMP_DIR/client.py" 2>/dev/null; then
                echo -e "${GREEN}✓ Valid Python${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ Invalid Python syntax${NC}"
                python3 -m py_compile "$TEMP_DIR/client.py" 2>&1 | head -10
                FAILED=$((FAILED + 1))
            fi
        else
            echo -e "${YELLOW}⚠ Python not installed${NC}"
            echo "  Generated but not validated"
        fi
    else
        echo -e "${RED}✗ Generation failed${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠ Generator not found${NC}"
fi

# Java Validation
echo -n "Java SDK... "
if [ -f "generators/java-sdk.ncl" ]; then
    if nickel export generators/java-sdk.ncl > "$TEMP_DIR/Client.java" 2>/dev/null; then
        # Check if Java compiler is available
        if command -v javac &> /dev/null; then
            if javac -d "$TEMP_DIR" "$TEMP_DIR/Client.java" 2>/dev/null; then
                echo -e "${GREEN}✓ Valid Java${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ Invalid Java syntax${NC}"
                javac -d "$TEMP_DIR" "$TEMP_DIR/Client.java" 2>&1 | head -10
                FAILED=$((FAILED + 1))
            fi
        else
            echo -e "${YELLOW}⚠ Java not installed${NC}"
            echo "  Generated but not validated"
        fi
    else
        echo -e "${RED}✗ Generation failed${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠ Generator not found${NC}"
fi

# PHP Validation
echo -n "PHP SDK... "
if [ -f "generators/php-sdk.ncl" ]; then
    if nickel export generators/php-sdk.ncl > "$TEMP_DIR/Client.php" 2>/dev/null; then
        # Check if PHP is available
        if command -v php &> /dev/null; then
            if php -l "$TEMP_DIR/Client.php" &>/dev/null; then
                echo -e "${GREEN}✓ Valid PHP${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ Invalid PHP syntax${NC}"
                php -l "$TEMP_DIR/Client.php" 2>&1 | head -10
                FAILED=$((FAILED + 1))
            fi
        else
            echo -e "${YELLOW}⚠ PHP not installed${NC}"
            echo "  Generated but not validated"
        fi
    else
        echo -e "${RED}✗ Generation failed${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠ Generator not found${NC}"
fi

# OpenAPI Validation
echo -n "OpenAPI Spec... "
if [ -f "generators/openapi.ncl" ]; then
    if nickel export generators/openapi.ncl --format yaml > "$TEMP_DIR/openapi.yaml" 2>/dev/null; then
        # Check if swagger-cli is available
        if command -v npx &> /dev/null; then
            if npx @apidevtools/swagger-cli validate "$TEMP_DIR/openapi.yaml" 2>/dev/null; then
                echo -e "${GREEN}✓ Valid OpenAPI 3.0${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ Invalid OpenAPI spec${NC}"
                npx @apidevtools/swagger-cli validate "$TEMP_DIR/openapi.yaml" 2>&1 | head -10
                FAILED=$((FAILED + 1))
            fi
        else
            echo -e "${YELLOW}⚠ swagger-cli not installed${NC}"
            echo "  Generated but not validated"
        fi
    else
        echo -e "${RED}✗ Generation failed${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠ Generator not found${NC}"
fi

# MCP Server Schema Validation
echo -n "MCP Server Schema... "
if [ -f "generators/mcp-server.ncl" ]; then
    if nickel export generators/mcp-server.ncl --format json > "$TEMP_DIR/mcp-tools.json" 2>/dev/null; then
        # Just validate it's valid JSON
        if command -v jq &> /dev/null; then
            if jq empty "$TEMP_DIR/mcp-tools.json" 2>/dev/null; then
                echo -e "${GREEN}✓ Valid JSON${NC}"
                PASSED=$((PASSED + 1))
            else
                echo -e "${RED}✗ Invalid JSON${NC}"
                jq empty "$TEMP_DIR/mcp-tools.json" 2>&1 | head -10
                FAILED=$((FAILED + 1))
            fi
        else
            echo -e "${YELLOW}⚠ jq not installed${NC}"
            echo "  Generated but not validated"
        fi
    else
        echo -e "${RED}✗ Generation failed${NC}"
        FAILED=$((FAILED + 1))
    fi
else
    echo -e "${YELLOW}⚠ Generator not found${NC}"
fi

# Summary
echo ""
echo "============================"
TOTAL=$((PASSED + FAILED))
if [ $TOTAL -eq 0 ]; then
    echo -e "${YELLOW}No generators validated${NC}"
    echo "  Create generators in generators/*.ncl"
    exit 0
fi

echo -e "Syntax Validation: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}"

if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Some generators produced invalid syntax${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}✓ All generated code is syntactically valid!${NC}"
    exit 0
fi
