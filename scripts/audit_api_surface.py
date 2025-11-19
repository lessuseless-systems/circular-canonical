#!/usr/bin/env python3
"""
Cross-Language API Surface Audit

Compares all generated SDKs to ensure they have the same API surface.
"""

import re
import json
from pathlib import Path
from typing import Dict, List, Set

SDK_CONFIGS = {
    'python': {
        'file': 'dist/circular-py/src/circular_protocol_api/client.py',
        'pattern': r'^\s+def ([a-z_][a-z0-9_]*)\(self',
        'exclude': {'__init__', '_make_request', '_build_url'},
        'naming': 'snake_case',
    },
    'typescript': {
        'file': 'dist/circular-ts/src/index.ts',
        'pattern': r'^\s+(?:async\s+)?([a-z][a-zA-Z0-9]*)\s*\(',
        'exclude': {'constructor'},
        'naming': 'camelCase',
    },
    'java': {
        'file': 'dist/circular-java/src/main/java/io/circular/protocol/CircularProtocolAPI.java',
        'pattern': r'^\s*public\s+(?:CompletableFuture<[^>]+>|String|void|Map<[^>]+>)\s+([a-z][a-zA-Z0-9]*)\s*\(',
        'exclude': {
            # Exclude JavaBean getters/setters for request fields
            'setBlockchain', 'getBlockchain', 'setVersion', 'getVersion',
            'setStart', 'getStart', 'setEnd', 'getEnd',
            'setNodeID', 'getNodeID', 'setAddress', 'getAddress',
            'setTransactionID', 'getTransactionID', 'setAssetName', 'getAssetName',
            'setBlockNumber', 'getBlockNumber', 'setCode', 'getCode',
            'setDomain', 'getDomain', 'setAsset', 'getAsset',
            'setNode', 'getNode', 'setInitialDate', 'getInitialDate',
            'setFinalDate', 'getFinalDate', 'setProject', 'getProject',
            'setRequest', 'getRequest', 'setTimestamp', 'getTimestamp',
            'setFrom', 'getFrom', 'setTo', 'getTo', 'setType', 'getType',
            'setPayload', 'getPayload', 'setNonce', 'getNonce',
            'setSignature', 'getSignature', 'setTransactionId', 'getTransactionId',
            'setId', 'getId',
        },
        'naming': 'camelCase',
    },
    'php': {
        'file': 'dist/circular-php/src/CircularProtocolAPI.php',
        'pattern': r'^\s*public\s+function\s+([a-z_][a-z0-9_]*)\s*\(',
        'exclude': {'__construct'},
        'naming': 'snake_case',
    },
    'go': {
        'file': 'dist/circular-go/circular_protocol.go',
        'pattern': r'^func\s+\([^)]+\)\s+([A-Z][a-zA-Z0-9]*)\s*\(',
        'exclude': set(),
        'naming': 'PascalCase',
    },
    'dart': {
        'file': 'dist/circular-dart/lib/circular_protocol.dart',
        'pattern': r'^\s+Future<[^>]+>\s+([a-z][a-zA-Z0-9]*)\s*\(',
        'exclude': set(),
        'naming': 'camelCase',
    },
}

def normalize_name(name: str, from_case: str) -> str:
    """Normalize to snake_case for comparison"""
    if from_case == 'snake_case':
        return name
    elif from_case in ['camelCase', 'PascalCase']:
        # camelCase/PascalCase to snake_case
        result = re.sub('([a-z0-9])([A-Z])', r'\1_\2', name)
        return result.lower()
    return name

def extract_methods(lang: str, config: Dict) -> Set[str]:
    """Extract method names from SDK file"""
    file_path = Path(config['file'])
    if not file_path.exists():
        print(f"⚠️  {lang}: File not found - {file_path}")
        return set()

    content = file_path.read_text()
    methods = set()

    for match in re.finditer(config['pattern'], content, re.MULTILINE):
        method = match.group(1)
        if method not in config['exclude'] and not method.startswith('_'):
            # Normalize to snake_case for comparison
            normalized = normalize_name(method, config['naming'])
            methods.add(normalized)

    return methods

def main():
    print("=" * 70)
    print("CROSS-LANGUAGE API SURFACE AUDIT")
    print("=" * 70)
    print()

    # Extract methods from all SDKs
    all_methods = {}
    for lang, config in SDK_CONFIGS.items():
        methods = extract_methods(lang, config)
        all_methods[lang] = methods
        print(f"{lang:12} {len(methods):3} public methods")

    print()
    print("=" * 70)

    # Find union of all methods (expected API surface)
    expected_methods = set()
    for methods in all_methods.values():
        expected_methods.update(methods)

    print(f"Expected API Surface: {len(expected_methods)} methods")
    print("=" * 70)
    print()

    # Check each language for missing methods
    has_issues = False
    for lang in sorted(all_methods.keys()):
        methods = all_methods[lang]
        missing = sorted(expected_methods - methods)

        if missing:
            has_issues = True
            print(f"❌ {lang}: Missing {len(missing)} methods")
            for method in missing[:10]:  # Show first 10
                print(f"     - {method}")
            if len(missing) > 10:
                print(f"     ... and {len(missing) - 10} more")
            print()
        else:
            print(f"✅ {lang}: Complete ({len(methods)} methods)")
            print()

    # Summary
    print("=" * 70)
    if has_issues:
        print("⚠️  API SURFACE INCONSISTENCIES DETECTED")
        print("Action Required: Update generators to ensure all languages have")
        print("the same API surface.")
    else:
        print("✅ ALL LANGUAGES HAVE CONSISTENT API SURFACE")
    print("=" * 70)

    return 1 if has_issues else 0

if __name__ == '__main__':
    import sys
    sys.exit(main())
