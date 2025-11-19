# Cross-Language API Surface Audit Report

**Date:** 2025-11-14
**Auditor:** Automated API surface analysis
**Scope:** All 5 generated SDKs (Python, TypeScript, PHP, Go, Dart)

---

## Executive Summary

**🚨 CRITICAL FINDINGS:**

- **Only Python** has near-complete API coverage (41/42 methods = 98%)
- **TypeScript** is missing 52% of expected methods (24/42 = 57%)
- **PHP** is critically incomplete (1/42 = 2%) - **BROKEN GENERATOR**
- **Dart** is critically incomplete (0/42 = 0%) - **BROKEN GENERATOR**
- **Go** is missing 31% of methods (37/42 = 88%)

**Conclusion:** The canonical source-of-truth pattern is **NOT working** as intended. Each generator is producing different API surfaces, violating the fundamental principle of single-source-of-truth.

---

## API Coverage by Language

| Language   | Methods | Coverage | Status |
|------------|---------|----------|--------|
| Python     | 41/42   | 98%      | ⚠️ Near-complete (missing `get_error`) |
| TypeScript | 24/42   | 57%      | ❌ Missing 52% of methods |
| Go         | 37/42   | 88%      | ⚠️ Missing helper methods |
| PHP        | 1/42    | 2%       | ❌ **BROKEN** - only has `register_wallet` |
| Dart       | 0/42    | 0%       | ❌ **BROKEN** - no methods extracted |

**Expected Total:** 42 methods (23 core endpoints + 13 helpers + 3 utility + 1 convenience + 2 config)

---

## Missing Methods by Language

### Python (41/42 - 98% complete) ✅ BEST

**Missing:**
- `get_error` (1 method)

**Analysis:** Python SDK is nearly complete. Only missing the standalone `get_error` method (though it has `handle_error` which may be equivalent).

---

### TypeScript (24/42 - 57% complete) ⚠️

**Missing 22 methods:**

**Helper/Crypto Methods (13 missing):**
- `get_formatted_timestamp`
- `get_public_key`
- `sign_message`
- `verify_signature`
- `hash_string`
- `hex_fix`
- `hex_to_string`
- `string_to_hex`
- `pad_number`
- `get_error`
- `handle_error`
- `get_transaction_outcome`

**Core API Methods (4 missing):**
- `get_transaction_by_id` (has `getTransactionbyID` - naming issue?)
- `get_transaction_by_node` (has `getTransactionbyNode` - naming issue?)
- `get_transaction_by_address` (has `getTransactionbyAddress` - naming issue?)
- `get_transaction_by_date` (has `getTransactionbyDate` - naming issue?)

**Config/Utility Methods (5 missing):**
- `get_nag_key`
- `set_nag_key`
- `get_nag_url`
- `set_nag_url`
- `get_version`
- `set_node`

**Analysis:** TypeScript has all 23 core endpoints but is missing ALL helper/crypto functions and utility methods. This suggests the generator is only reading API endpoint definitions, not helper/convenience method specs.

---

### PHP (1/42 - 2% complete) ❌ CRITICAL

**Missing 41 methods (almost everything):**

Only has: `register_wallet`

**Analysis:** PHP generator is fundamentally broken. It appears to only have generated 1 convenience method. The generator is not reading from canonical Nickel source correctly.

**Files to investigate:**
- `generators/php/php-client.ncl`
- `generators/php/php-sdk.ncl`

---

### Go (37/42 - 88% complete) ⚠️

**Missing 13 methods:**

**Config Methods (4 missing):**
- `get_nag_key` (has `GetNAGKey` - naming issue?)
- `set_nag_key` (has `SetNAGKey` - naming issue?)
- `get_nag_url` (has `GetNAGURL` - naming issue?)
- `set_nag_url` (has `SetNAGURL` - naming issue?)

**Core API Methods (4 missing):**
- `get_transaction_by_id` (has `GetTransactionbyID` - naming issue?)
- `get_transaction_by_node` (has `GetTransactionbyNode` - naming issue?)
- `get_transaction_by_address` (has `GetTransactionbyAddress` - naming issue?)
- `get_transaction_by_date` (has `GetTransactionbyDate` - naming issue?)

**Helper Methods (3 missing):**
- `hex_fix`
- `pad_number`
- `handle_error`

**Utility Methods (2 missing):**
- `get_version`
- `set_node`

**Analysis:** Go SDK has most API endpoints and crypto functions, but missing some helpers and utility methods. Likely a case normalization issue (PascalCase vs snake_case).

---

### Dart (0/42 - 0% complete) ❌ CRITICAL

**Missing ALL 42 methods**

**Analysis:** Dart generator is completely broken. The audit script found 0 methods, which means either:
1. The generator is not producing method definitions
2. The regex pattern failed to match Dart syntax
3. The generated file structure is different than expected

**Files to investigate:**
- `generators/dart/dart-client.ncl`
- `dist/circular-dart/lib/circular_protocol.dart` (manual inspection needed)

---

## Root Cause Analysis

### Problem 1: Generators Not Reading from Same Source

**Evidence:**
- Python has 41 methods
- TypeScript has 24 methods
- PHP has 1 method
- Dart has 0 methods

**Hypothesis:** Each generator has hardcoded method lists or is reading from different Nickel sources. They are NOT all importing from `src/api/all.ncl` as a single source of truth.

**Action Required:** Verify that ALL generators import from:
```nickel
let api = import "../../src/api/all.ncl" in
let helpers = import "../shared/helpers.ncl" in
let crypto = import "../shared/crypto.ncl" in
```

### Problem 2: Helper Methods Not Consistently Generated

**Evidence:**
- Python has all helpers
- TypeScript has ZERO helpers
- Go has most helpers (missing 3)
- PHP/Dart unknown (too broken)

**Hypothesis:** Helper/crypto method generation is optional or conditional in generators, not mandatory from canonical source.

**Action Required:** Ensure helpers are generated from shared canonical definitions in `generators/shared/`.

### Problem 3: Convenience Methods Incomplete

**Evidence:**
- Python has `register_wallet`
- PHP ONLY has `register_wallet`
- TypeScript missing `register_wallet`

**Hypothesis:** Convenience methods are defined separately from core API endpoints and not all generators read them.

**Action Required:** Verify `src/api/convenience-methods.ncl` is imported by all generators.

### Problem 4: Case Normalization Issues

**Evidence:**
- Go reports missing `get_transaction_by_id` but has `GetTransactionbyID`
- TypeScript reports missing `get_transaction_by_address` but has `getTransactionbyAddress`

**Note:** This is partly a false positive from the audit script's normalization, but it reveals inconsistent naming patterns in the generated code (e.g., `byID` vs `by_id`).

---

## Recommended Actions (Priority Order)

### 🚨 IMMEDIATE (Blocking)

1. **Fix PHP Generator** - Currently only generating 1/42 methods
   - File: `generators/php/php-client.ncl`
   - Verify it imports from `src/api/all.ncl`
   - Regenerate: `just generate-php-package`

2. **Fix Dart Generator** - Currently generating 0/42 methods
   - File: `generators/dart/dart-client.ncl`
   - Manual inspection of `dist/circular-dart/lib/circular_protocol.dart` needed
   - Regenerate: `just generate-dart-package`

### ⚠️ HIGH PRIORITY

3. **Add Helpers to TypeScript** - Missing all 13 helper/crypto methods
   - File: `generators/typescript/typescript-sdk.ncl`
   - Ensure it imports: `let helpers = import "../shared/helpers.ncl"`
   - Regenerate: `just generate-ts-package`

4. **Add Utilities to All SDKs** - Missing `get_version`, `set_node` in most languages
   - Each generator needs to add these 2 utility methods
   - Python already has them (use as reference)

### 📋 MEDIUM PRIORITY

5. **Add Missing Helpers to Go** - Missing `hex_fix`, `pad_number`, `handle_error`
   - File: `generators/go/go-sdk.ncl`

6. **Verify Naming Consistency** - Investigate `byID` vs `by_id` vs `ById` inconsistencies

### 📖 LOW PRIORITY (Documentation)

7. **Update API_COMPATIBILITY_REPORT.md** - Current report claims 100% coverage but audit shows otherwise

8. **Add Cross-Language Tests** - Implement tests that verify all SDKs have same API surface

---

## Verification Steps

After fixing generators, run these commands to verify:

```bash
# Regenerate all SDKs
just generate-packages

# Run audit
nix develop --command python3 /tmp/count_sdk_methods.py

# Expected output:
# Python:      42/42 (100%)
# TypeScript:  42/42 (100%)
# PHP:         42/42 (100%)
# Go:          42/42 (100%)
# Dart:        42/42 (100%)
```

---

## Appendix: Expected Methods (42 total)

### Core API Endpoints (23)

**Wallet (5):**
- check_wallet
- get_wallet
- get_latest_transactions
- get_wallet_balance
- get_wallet_nonce

**Transaction (6):**
- send_transaction / add_transaction (alias)
- get_pending_transaction
- get_transaction_by_id
- get_transaction_by_node
- get_transaction_by_address
- get_transaction_by_date

**Block (4):**
- get_block
- get_block_range
- get_block_count
- get_analytics

**Contract (2):**
- test_contract
- call_contract

**Asset (4):**
- get_asset_list
- get_asset
- get_asset_supply
- get_voucher

**Domain (1):**
- get_domain

**Network (1):**
- get_blockchains

### Helper/Crypto Methods (13)

**Cryptography (5):**
- sign_message
- verify_signature
- get_public_key
- hash_string
- get_formatted_timestamp

**Encoding (4):**
- hex_fix
- string_to_hex
- hex_to_string
- pad_number

**Error Handling (3):**
- get_error
- handle_error
- get_transaction_outcome

**NAG Config (4):**
- get_nag_key
- set_nag_key
- get_nag_url
- set_nag_url

### Convenience/Utility Methods (3)

- register_wallet (convenience)
- get_version (utility)
- set_node (utility)

---

**Generated by:** `scripts/audit_api_surface.py` (enhanced version)
**Command:** `nix develop --command python3 /tmp/count_sdk_methods.py`
