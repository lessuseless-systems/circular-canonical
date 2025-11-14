# Python Models Generator
# Generates TypedDict response types for Circular Protocol API

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in

# Helper: Convert path to PascalCase type name
let path_to_type_name = fun path =>
  # Remove leading slash
  let name = std.string.substring 1 (std.string.length path) path in
  let first_char = std.string.substring 0 1 name in
  let rest = std.string.substring 1 (std.string.length name) name in
  "%{std.string.uppercase first_char}%{rest}"
in

# Helper: Convert Nickel type to Python type
let rec nickel_type_to_python = fun type_str parent_name =>
  if type_str == "string" then "str"
  else if type_str == "number" then "int"
  else if type_str == "boolean" then "bool"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      # Array type - recursively convert items
      let items_type = nickel_type_to_python type_str.items "%{parent_name}Item" in
      "List[%{items_type}]"
    else
      # Nested object - return class name to be generated
      parent_name
  else "Any"
in

# Helper: Generate TypedDict class for nested object
let rec generate_typeddict = fun class_name schema =>
  if std.is_record schema then
    if std.record.has_field "type" schema && schema.type == "array" then
      # For arrays, generate the item type
      generate_typeddict "%{class_name}Item" schema.items
    else
      # Generate class for object
      let fields = std.record.map
        (fun field type_str =>
          let python_type = nickel_type_to_python type_str "%{class_name}%{field}" in
          "    %{field}: %{python_type}")
        schema
      in
      let fields_list = std.record.values fields in
      let fields_str = if fields_list == [] then
        "    pass"  # Empty TypedDict needs pass statement
      else
        std.string.join "\n" fields_list
      in
      "class %{class_name}(TypedDict):\n    \"\"\"TypedDict for %{class_name}.\"\"\"\n%{fields_str}\n"
  else
    ""
in

# Helper: Generate all nested TypedDict classes for a schema
let rec collect_nested_typedicts = fun class_name schema =>
  if std.is_record schema then
    if std.record.has_field "type" schema && schema.type == "array" then
      # Recursively collect from array items
      collect_nested_typedicts "%{class_name}Item" schema.items
    else
      # Collect TypedDicts for all nested objects
      let nested_list = std.record.map
        (fun field type_str =>
          if std.is_record type_str then
            if std.record.has_field "type" type_str && type_str.type == "array" then
              # Nested array
              let item_class = "%{class_name}%{field}Item" in
              let item_typedicts = collect_nested_typedicts item_class type_str.items in
              let array_typedef = generate_typeddict "%{class_name}%{field}Item" type_str.items in
              if item_typedicts == "" then
                "%{array_typedef}\n"
              else
                "%{item_typedicts}%{array_typedef}\n"
            else
              # Nested object
              let nested_class = "%{class_name}%{field}" in
              let nested_typedicts = collect_nested_typedicts nested_class type_str in
              let typedef = generate_typeddict nested_class type_str in
              "%{nested_typedicts}%{typedef}\n"
          else
            "")
        schema
      in
      let nested_values = std.record.values nested_list in
      std.string.join "" nested_values
  else
    ""
in

# Collect all endpoints
let all_endpoints = [
  wallet.checkWallet,
  wallet.getWallet,
  wallet.getLatestTransactions,
  wallet.getWalletBalance,
  wallet.getWalletNonce,
  # Note: registerWallet removed - it's now a convenience method, not an endpoint
  transaction.sendTransaction,
  transaction.getPendingTransaction,
  transaction.getTransactionbyID,
  transaction.getTransactionbyNode,
  transaction.getTransactionbyAddress,
  transaction.getTransactionbyDate,
  block.getBlock,
  block.getBlockRange,
  block.getBlockCount,
  block.getAnalytics,
  contract.testContract,
  contract.callContract,
  asset.getAssetList,
  asset.getAsset,
  asset.getAssetSupply,
  asset.getVoucher,
  domain.getDomain,
  network.getBlockchains,
] in

# Generate TypedDict classes for all endpoints
let generate_response_typedicts = fun endpoint =>
  let type_name = path_to_type_name endpoint.path in
  let response_class = "%{type_name}Response" in
  let response_schema = endpoint.response_schema in

  # Collect nested TypedDicts from Response field
  let response_field = response_schema.Response in
  let response_data_class = "%{response_class}Data" in

  # Determine if Response field is an array
  let is_array = std.is_record response_field && std.record.has_field "type" response_field && response_field.type == "array" in

  # For arrays, generate Item TypedDict
  let response_data_typedef = if is_array then
    generate_typeddict "%{response_data_class}Item" response_field.items
  else if std.is_record response_field then
    # For objects, generate the data TypedDict
    generate_typeddict response_data_class response_field
  else
    # For primitives (string, number, etc), no typedef needed
    ""
  in

  # Collect nested TypedDicts (for nested objects within the Response)
  let nested_typedicts = if is_array then
    collect_nested_typedicts "%{response_data_class}Item" response_field.items
  else
    collect_nested_typedicts response_data_class response_field
  in

  # Get the type for Response field
  let response_type = nickel_type_to_python response_field response_data_class in

  # Generate main response TypedDict
  let main_typedef = "class %{response_class}(TypedDict):
    \"\"\"Response type for %{endpoint.summary}.\"\"\"
    Result: int
    Response: %{response_type}
" in

  "%{nested_typedicts}%{response_data_typedef}%{main_typedef}"
in

let all_typedicts = std.array.map generate_response_typedicts all_endpoints in
let typedicts_code = std.string.join "\n" all_typedicts in

{
  models_code = "\"\"\"
Response type definitions for Circular Protocol API.

This module contains TypedDict classes for all API response types,
providing static type checking and IDE autocompletion support.
\"\"\"

from typing import List, TypedDict, Any


%{typedicts_code}",
}
