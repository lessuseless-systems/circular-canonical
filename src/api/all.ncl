# Circular Protocol Canonacle - All API Endpoints
# Aggregates all API definitions for use in generators

let wallet = import "./wallet.ncl" in
let transaction = import "./transaction.ncl" in
let asset = import "./asset.ncl" in
let block = import "./block.ncl" in
let domain = import "./domain.ncl" in
let network = import "./network.ncl" in
let contract = import "./contract.ncl" in

{
  # Wallet Operations (6 endpoints)
  wallet = wallet,

  # Transactions (6 endpoints)
  transaction = transaction,

  # Assets (4 endpoints)
  asset = asset,

  # Blocks (4 endpoints)
  block = block,

  # Domains (1 endpoint)
  domain = domain,

  # Network (1 endpoint)
  network = network,

  # Smart Contracts (2 endpoints)
  contract = contract,

  # Flat list of all endpoints (for iteration in generators)
  all_endpoints = wallet & transaction & asset & block & domain & network & contract,
}
