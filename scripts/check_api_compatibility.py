#!/usr/bin/env python3
"""
Check API compatibility between reference (circular-js.xml) and generated Python SDK.

Ensures no breaking changes by verifying:
1. All reference methods exist in generated code
2. Method signatures are consistent (parameters match)
3. No methods removed from reference
"""

import re
import sys
from pathlib import Path
from typing import Dict, List, Set, Tuple

def extract_js_methods(xml_file: Path) -> Dict[str, List[str]]:
    """Extract method signatures from circular-js.xml reference."""
    content = xml_file.read_text()
    methods = {}

    # Look for method definitions in the XML
    # Pattern: method_name(...parameters...)
    # We'll parse the actual JS code sections

    # Find all function/method definitions
    patterns = [
        r'async\s+(\w+)\s*\((.*?)\)',  # async function_name(params)
        r'(\w+)\s*:\s*async\s+function\s*\((.*?)\)',  # name: async function(params)
        r'(\w+)\s*\((.*?)\)\s*{',  # Regular function name(params) {
    ]

    for pattern in patterns:
        for match in re.finditer(pattern, content):
            method_name = match.group(1)
            params = match.group(2).strip()

            # Skip constructors and private methods
            if method_name in ['constructor', '__init__'] or method_name.startswith('_'):
                continue

            if method_name not in methods:
                methods[method_name] = []
            methods[method_name].append(params)

    return methods

def extract_python_methods(sdk_file: Path) -> Dict[str, List[str]]:
    """Extract method signatures from generated Python SDK."""
    content = sdk_file.read_text()
    methods = {}

    # Match Python method definitions: def method_name(self, params):
    pattern = r'def\s+(\w+)\s*\(self(?:,\s*(.*?))?\)\s*(?:->.*?)?:'

    for match in re.finditer(pattern, content, re.MULTILINE):
        method_name = match.group(1)
        params = match.group(2) if match.group(2) else ""

        # Skip private methods and __init__
        if method_name.startswith('_'):
            continue

        if method_name not in methods:
            methods[method_name] = []
        methods[method_name].append(params.strip())

    return methods

def js_to_python_name(js_name: str) -> str:
    """Convert JavaScript camelCase to Python snake_case."""
    # Handle special cases first
    name = js_name

    # Insert underscore before capitals
    result = re.sub('([a-z0-9])([A-Z])', r'\1_\2', name)
    return result.lower()

def compare_apis(js_methods: Dict[str, List[str]], py_methods: Dict[str, List[str]]) -> Tuple[List[str], List[str], List[str]]:
    """
    Compare JS and Python API surfaces.

    Returns:
        (missing_methods, extra_methods, signature_mismatches)
    """
    # Convert JS method names to expected Python names
    expected_py_methods = {js_to_python_name(name): params for name, params in js_methods.items()}

    js_method_names = set(expected_py_methods.keys())
    py_method_names = set(py_methods.keys())

    missing = sorted(list(js_method_names - py_method_names))
    extra = sorted(list(py_method_names - js_method_names))

    # Check signature compatibility (parameter counts)
    mismatches = []
    for method in js_method_names & py_method_names:
        js_params = expected_py_methods[method]
        py_params_list = py_methods[method]

        # Simple check: compare parameter count
        for js_param_str in js_params:
            js_param_count = len([p for p in js_param_str.split(',') if p.strip()]) if js_param_str else 0

            for py_param_str in py_params_list:
                # Remove type hints for comparison
                py_param_clean = re.sub(r':\s*[^,=]+', '', py_param_str)
                py_param_count = len([p for p in py_param_clean.split(',') if p.strip()]) if py_param_clean else 0

                if js_param_count != py_param_count:
                    mismatches.append(
                        f"{method}: JS has {js_param_count} params, Python has {py_param_count} params"
                    )

    return missing, extra, mismatches

def main():
    """Main comparison logic."""
    repo_root = Path(__file__).parent.parent

    # Paths to compare
    js_xml = repo_root / "circular-js.xml"
    py_sdk = repo_root / "dist/circular-py/src/circular_protocol_api/client.py"

    if not js_xml.exists():
        print(f"❌ Reference file not found: {js_xml}")
        return 1

    if not py_sdk.exists():
        print(f"❌ Generated SDK not found: {py_sdk}")
        return 1

    print("🔍 Checking API compatibility...")
    print(f"📘 Reference: {js_xml.name}")
    print(f"🐍 Generated: {py_sdk.relative_to(repo_root)}")
    print()

    js_methods = extract_js_methods(js_xml)
    py_methods = extract_python_methods(py_sdk)

    print(f"📊 Reference methods found: {len(js_methods)}")
    print(f"📊 Generated methods found: {len(py_methods)}")
    print()

    missing, extra, mismatches = compare_apis(js_methods, py_methods)

    # Report results
    has_issues = False

    if missing:
        has_issues = True
        print("❌ MISSING METHODS (in reference but not in generated):")
        for method in missing:
            print(f"   - {method}")
        print()

    if extra:
        print("ℹ️  EXTRA METHODS (in generated but not in reference):")
        for method in extra:
            print(f"   + {method}")
        print()

    if mismatches:
        has_issues = True
        print("⚠️  SIGNATURE MISMATCHES:")
        for mismatch in mismatches:
            print(f"   ! {mismatch}")
        print()

    if not has_issues:
        print("✅ API compatibility check passed!")
        print("   All reference methods are present with compatible signatures.")
        return 0
    else:
        print("❌ API compatibility issues found!")
        print("   Please review the missing methods and mismatches above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
