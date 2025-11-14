# Circular Protocol Canonical - Convenience Methods
# Convenience methods are SDK helpers that wrap underlying API calls
# They simplify common workflows by handling transaction construction internally

let types = import "../schemas/types.ncl" in

{
  # registerWallet - Register wallet on blockchain
  #
  # This is the ONLY convenience method in the reference circular-js SDK.
  # It wraps sendTransaction with Type="C_TYPE_REGISTERWALLET"
  #
  # Reference implementation (circular-js):
  #   async function registerWallet(blockchain, publicKey) {
  #     let From = sha256(publicKey);
  #     let To = From;
  #     let Nonce = '0';
  #     let Type = 'C_TYPE_REGISTERWALLET';
  #     let PayloadObj = { "Action": "CP_REGISTERWALLET", "PublicKey": publicKey };
  #     let Payload = stringToHex(JSON.stringify(PayloadObj));
  #     let Timestamp = getFormattedTimestamp();
  #     let ID = sha256(blockchain + From + To + Payload + Nonce + Timestamp);
  #     let Signature = "";
  #     return await sendTransaction(ID, From, To, Timestamp, Type, Payload, Nonce, Signature, blockchain);
  #   }
  #
  registerWallet = {
    type = "convenience_method",
    wraps = "sendTransaction",
    summary = "Register wallet on blockchain",
    description = m%"
      Registers a wallet on the specified blockchain by creating and sending
      a C_TYPE_REGISTERWALLET transaction. This convenience method handles all
      transaction construction internally:

      - Derives From/To addresses from public key (sha256)
      - Builds Payload: hex(JSON.stringify({Action: "CP_REGISTERWALLET", PublicKey: publicKey}))
      - Calculates transaction ID: sha256(blockchain + from + to + payload + nonce + timestamp)
      - Sets Nonce to "0" and Signature to "" (empty for registration)
      - Calls sendTransaction with constructed parameters

      Without registration, the wallet will not be reachable on the blockchain.
      The same wallet can be registered on multiple blockchains.
    "%,

    # Parameters accepted by the convenience method
    parameters = {
      blockchain = {
        type = "string",
        required = true,
        description = "Blockchain where the wallet will be registered (e.g., 'MainNet', '0x8a20...')",
      },

      publicKey = {
        type = "string",
        required = true,
        description = "Wallet public key (128 hex characters, uncompressed secp256k1)",
      },
    },

    # Implementation pattern for SDK generators
    # Generators should transform this into language-specific code
    implementation = {
      # Derive addresses from public key
      derive_from = "sha256(publicKey)",  # Address = sha256 of public key
      derive_to = "sha256(publicKey)",    # Same as From for registration

      # Transaction metadata
      transaction_type = "C_TYPE_REGISTERWALLET",
      nonce = "0",                         # Always "0" for registration
      signature = "",                      # Empty string for registration

      # Payload structure (will be JSON stringified then hex encoded)
      payload_structure = {
        Action = "CP_REGISTERWALLET",
        PublicKey = "publicKey",           # Placeholder - generators replace with actual parameter
      },

      # Transaction ID calculation
      # SDK generators should produce: sha256(blockchain + from + to + payload + nonce + timestamp)
      transaction_id_formula = "sha256(blockchain + from + to + payload + nonce + timestamp)",

      # Timestamp format
      timestamp_format = "YYYY:MM:DD-HH:mm:ss",
    },

    # Return type (same as sendTransaction)
    returns = {
      Result = "number",
      Response = {
        TransactionID = "string",
        Status = "string",
      },
    },

    # Example usage (for documentation generation)
    example = {
      typescript = m%"
        const publicKey = api.getPublicKey(privateKey);
        const result = await api.registerWallet('MainNet', publicKey);
        console.log('Transaction ID:', result.Response.TransactionID);
      "%,

      python = m%"
        from circular_protocol_api._crypto import get_public_key

        public_key = get_public_key(private_key)
        result = api.register_wallet('MainNet', public_key)
        print(f'Transaction ID: {result["Response"]["TransactionID"]}')
      "%,

      java = m%"
        String publicKey = api.getPublicKey(privateKey);
        Map<String, Object> result = api.registerWallet("MainNet", publicKey).get();
        System.out.println("Transaction ID: " + ((Map) result.get("Response")).get("TransactionID"));
      "%,

      php = m%"
        $publicKey = $api->getPublicKey($privateKey);
        $result = $api->registerWallet('MainNet', $publicKey);
        echo 'Transaction ID: ' . $result['Response']['TransactionID'];
      "%,
    },
  },

  # Future convenience methods can be added here
  # Examples from other blockchain SDKs (NOT in circular-js reference):
  #
  # sendCoin = { ... }          # C_TYPE_COIN wrapper
  # certifyData = { ... }       # C_TYPE_CERTIFICATE wrapper
  # deployContract = { ... }    # C_TYPE_HC_DEPLOYMENT wrapper
  # callContractMethod = { ...} # C_TYPE_HC_REQUEST wrapper
  #
  # For now, we only implement registerWallet to match the reference SDK.
  # Users call sendTransaction directly for other transaction types.
}
