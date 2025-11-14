# Dart SDK Generator for Circular Protocol
# Transforms Nickel API definitions into Dart SDK code
# Follows Dart idioms: async/await, Future types, camelCase methods

let config = import "../../src/config.ncl" in
let wallet = import "../../src/api/wallet.ncl" in
let transaction = import "../../src/api/transaction.ncl" in
let block = import "../../src/api/block.ncl" in
let contract = import "../../src/api/contract.ncl" in
let asset = import "../../src/api/asset.ncl" in
let domain = import "../../src/api/domain.ncl" in
let network = import "../../src/api/network.ncl" in
let convenience_methods = import "../../src/api/convenience-methods.ncl" in
let helpers_encoding = import "../shared/helpers-encoding.ncl" in
let helpers_advanced = import "../shared/helpers-advanced.ncl" in

# Helper: Convert Nickel type to Dart type
let nickel_type_to_dart = fun type_str =>
  if type_str == "string" then "String"
  else if type_str == "number" then "int"
  else if type_str == "boolean" then "bool"
  else if std.is_record type_str then
    if std.record.has_field "type" type_str && type_str.type == "array" then
      "List<dynamic>"
    else
      "Map<String, dynamic>"
  else "dynamic"
in

# Helper: Convert PascalCase to camelCase
let to_camel_case = fun str =>
  let first_char = std.string.substring 0 1 str in
  let rest = std.string.substring 1 (std.string.length str) str in
  "%{std.string.lowercase first_char}%{rest}"
in

# Helper: Extract endpoint name from path
let endpoint_name_from_path = fun path =>
  std.string.substring 1 (std.string.length path) path
in

# Helper: Convert path to NAG endpoint name (CheckWallet not checkWallet)
let path_to_endpoint_name = fun path =>
  let without_slash = if std.string.substring 0 1 path == "/" then
    std.string.substring 1 (std.string.length path) path
  else
    path
  in
  # Capitalize first letter
  let first_char = std.string.substring 0 1 without_slash in
  let rest = std.string.substring 1 (std.string.length without_slash) without_slash in
  (std.string.uppercase first_char) ++ rest
in

# Helper: Format multi-line description as Dart doc comments
let format_doc_comment = fun description =>
  let lines = std.string.split "\n" description in
  std.string.join "\n/// " lines
in

# Helper: Generate method from endpoint
let generate_method = fun endpoint =>
  let method_name = to_camel_case (endpoint_name_from_path endpoint.path) in
  let formatted_desc = format_doc_comment endpoint.description in

  m%"
  /// %{endpoint.summary}
  /// %{formatted_desc}
  Future<Map<String, dynamic>> %{method_name}(Map<String, dynamic> request) async {
    return _makeRequest('%{path_to_endpoint_name endpoint.path}', request);
  }
"%
in

# Helper: Generate convenience method (wraps API calls)
let generate_convenience_method = fun method_name spec =>
  m%"
  /// %{spec.summary} (Convenience Method)
  /// %{spec.description}
  ///
  /// This is a convenience method that wraps %{spec.wraps}().
  /// It handles transaction construction internally.
  ///
  /// [blockchain] Blockchain where the wallet will be registered
  /// [publicKey] Wallet public key (128 hex characters)
  /// Returns: Same as sendTransaction response
  Future<Map<String, dynamic>> %{method_name}(String blockchain, String publicKey) async {
    // Derive addresses from public key
    final from = hashString(publicKey);
    final to = from;
    final nonce = '%{spec.implementation.nonce}';
    final type = '%{spec.implementation.transaction_type}';

    // Build payload
    final payloadObj = {
      'Action': '%{spec.implementation.payload_structure.Action}',
      'PublicKey': publicKey,
    };
    final payload = stringToHex(jsonEncode(payloadObj));
    final timestamp = getFormattedTimestamp();

    // Calculate transaction ID
    final id = hashString(blockchain + from + to + payload + nonce + timestamp);
    final signature = '%{spec.implementation.signature}';

    // Build request
    final request = {
      'ID': id,
      'From': from,
      'To': to,
      'Timestamp': timestamp,
      'Type': type,
      'Payload': payload,
      'Nonce': nonce,
      'Signature': signature,
      'Blockchain': blockchain,
      'Version': '%{config.version}',
    };

    // Call sendTransaction
    return sendTransaction(request);
  }
"%
in

# Collect all endpoints
let all_endpoints = [
  wallet.checkWallet,
  wallet.getWallet,
  wallet.getLatestTransactions,
  wallet.getWalletBalance,
  wallet.getWalletNonce,
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

# Generate all methods
let methods = std.array.map generate_method all_endpoints in

# Generate convenience methods
let convenience_method_specs = [
  { name = "registerWallet", spec = convenience_methods.registerWallet },
  # Future convenience methods can be added here
] in
let convenience_methods_code = std.array.map
  (fun item => generate_convenience_method item.name item.spec)
  convenience_method_specs
in

# Assemble the complete SDK
{
  sdk_code = m%"
/// Circular Protocol Dart SDK
/// Official Dart SDK for the Circular Protocol blockchain API
/// Version: %{config.version}
///
/// Example usage:
/// ```dart
/// final client = CircularProtocolAPI(
///   nagUrl: 'https://nag.circularlabs.io/NAG.php?cep=',
///   nagKey: 'your-api-key',
/// );
///
/// final result = await client.checkWallet({
///   'Address': '0x...',
///   'Blockchain': '714d2ac07a826b66ac56752eebd7c77b58d2ee842e523d913fd0ef06e6bdfcae',
///   'Version': '%{config.version}',
/// });
/// print(result);
/// ```
library circular_protocol;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';
import 'package:asn1lib/asn1lib.dart';
import 'package:intl/intl.dart';

/// API client for Circular Protocol blockchain
class CircularProtocolAPI {
  /// NAG endpoint URL
  String nagUrl;

  /// NAG API key (optional)
  String nagKey;

  /// HTTP client for making requests
  final http.Client _httpClient;

  /// Custom headers to include in requests
  final Map<String, String> _headers;

  /// Request timeout duration
  final Duration timeout;

%{helpers_advanced.dart.errorField}

  /// Constructor
  CircularProtocolAPI({
    String? nagUrl,
    this.nagKey = '',
    http.Client? httpClient,
    Map<String, String>? headers,
    this.timeout = const Duration(seconds: 30),
  })  : nagUrl = nagUrl ?? 'https://nag.circularlabs.io/NAG.php?cep=',
        _httpClient = httpClient ?? http.Client(),
        _headers = headers ?? {};

  /// Update NAG endpoint URL
  void setNagUrl(String url) {
    nagUrl = url;
  }

  /// Get current NAG endpoint URL
  String getNagUrl() => nagUrl;

  /// Update NAG API key
  void setNagKey(String key) {
    nagKey = key;
  }

  /// Get current NAG API key
  String getNagKey() => nagKey;

  /// Set custom HTTP header
  void setHeader(String key, String value) {
    _headers[key] = value;
  }

  /// Make HTTP request to NAG API
  Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('${nagUrl}Circular_${endpoint}_');

    // Build headers
    final headers = {
      'Content-Type': 'application/json',
      ..._headers,
    };
    if (nagKey.isNotEmpty) {
      headers['X-NAG-Key'] = nagKey;
    }

    try {
      // Make POST request
      final response = await _httpClient
          .post(
            url,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(timeout);

      // Check HTTP status
      if (response.statusCode != 200) {
        throw CircularAPIException(
          'HTTP error: ${response.statusCode} ${response.reasonPhrase}',
          statusCode: response.statusCode,
          endpoint: endpoint,
        );
      }

      // Parse JSON response
      final Map<String, dynamic> result = jsonDecode(response.body) as Map<String, dynamic>;

      // Check API-level errors
      final resultCode = result['Result'] as int?;
      if (resultCode == null || resultCode != 200) {
        final errorMessage = (result['Response'] as String?) ?? 'API request failed';
        throw CircularAPIException(
          errorMessage,
          statusCode: resultCode ?? 0,
          endpoint: endpoint,
        );
      }

      // Return full response (with Result and Response fields)
      return result;
    } on TimeoutException {
      throw CircularAPIException(
        'Request timeout after ${timeout.inSeconds}s',
        statusCode: 0,
        endpoint: endpoint,
      );
    } on http.ClientException catch (e) {
      throw CircularAPIException(
        'Network error: ${e.message}',
        statusCode: 0,
        endpoint: endpoint,
      );
    } catch (e) {
      if (e is CircularAPIException) rethrow;
      throw CircularAPIException(
        'Unexpected error: $e',
        statusCode: 0,
        endpoint: endpoint,
      );
    }
  }

  // ============================================================================
  // API Methods
  // ============================================================================
%{std.string.join "\n" methods}

  // ============================================================================
  // Convenience Methods
  // ============================================================================
  // These methods wrap underlying API calls to simplify common workflows

%{std.string.join "\n" convenience_methods_code}

  // ============================================================================
  // Cryptographic Helper Functions
  // ============================================================================

  /// Get formatted UTC timestamp in Circular Protocol format
  /// Returns timestamp as "YYYY:MM:DD-HH:mm:ss"
  String getFormattedTimestamp() {
    final now = DateTime.now().toUtc();
    final formatter = DateFormat('yyyy:MM:dd-HH:mm:ss');
    return formatter.format(now);
  }

  /// Remove "0x" prefix from hex string if present
  String _hexFix(String hex) {
    return hex.startsWith("0x") ? hex.substring(2) : hex;
  }

  /// Convert Uint8List to hex string
  String _uint8ListToHex(Uint8List input) {
    return hex.encode(input);
  }

  /// Convert hex string to Uint8List
  static Uint8List _hexToBytes(String hexStr) {
    return Uint8List.fromList(hex.decode(hexStr));
  }

  /// Convert BigInt to bytes
  static Uint8List _bigIntToBytes(BigInt bigInt) {
    return _hexToBytes(bigInt.toRadixString(16).padLeft(32, "0"));
  }

  /// Decode bytes to BigInt
  static BigInt _decodeBigInt(List<int> bytes) {
    BigInt result = BigInt.from(0);
    for (int i = 0; i < bytes.length; i++) {
      result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
    }
    return result;
  }

  /// Convert bytes to BigInt
  static BigInt _byteToBigInt(Uint8List bigIntBytes) {
    return _decodeBigInt(bigIntBytes);
  }

  /// Pad bytes to 32 bytes
  List<int> _pad(List<int> data) {
    if (data.length < 32) data = Uint8List(32 - data.length) + data;
    return data;
  }

  /// Convert ECDSA signature to IEEE P1363 format
  Uint8List _convertToIEEE1363(BigInt rBI, BigInt sBI) {
    return Uint8List.fromList(
        _pad(_bigIntToBytes(rBI)) + _pad(_bigIntToBytes(sBI)));
  }

  /// Hash a string using SHA256
  /// Returns hex-encoded hash
  String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return _uint8ListToHex(Uint8List.fromList(digest.bytes));
  }

  /// Get public key from private key
  /// Returns uncompressed public key (128 hex characters, no 0x04 prefix)
  String getPublicKey(String privateKey) {
    final String remove0x = _hexFix(privateKey);

    // Create private key object from hex string
    final Uint8List key = Uint8List.fromList(hex.decode(remove0x));
    final ECPrivateKey pk = ECPrivateKey(
      _byteToBigInt(key),
      ECDomainParameters("secp256k1"),
    );

    // Derive public key
    final ECDomainParameters params = ECDomainParameters('secp256k1');
    final ECPublicKey publicKey = ECPublicKey(params.G * pk.d!, params);

    // Return uncompressed public key without 0x04 prefix
    final String publicKeyHex = _uint8ListToHex(publicKey.Q!.getEncoded(false));
    return publicKeyHex.substring(2); // Remove 0x04 prefix
  }

  /// Sign a message with a private key
  /// Returns DER-encoded ECDSA signature as hex string
  String signMessage(String plainMessage, String privateKey) {
    if (privateKey.length < 64) {
      throw Exception("Invalid private key length");
    }
    if (privateKey.length > 66) {
      throw Exception("Invalid private key length");
    }

    final String remove0x = _hexFix(privateKey);

    // Hash the message with SHA256
    final Uint8List msgHash =
        Uint8List.fromList(sha256.convert(utf8.encode(plainMessage)).bytes);

    // Create private key object
    final Uint8List key = Uint8List.fromList(hex.decode(remove0x));
    final ECPrivateKey pk =
        ECPrivateKey(_byteToBigInt(key), ECDomainParameters("secp256k1"));

    // Create and initialize signer
    final ECDSASigner ecdsaSigner = ECDSASigner(null, HMac(SHA256Digest(), 64));
    final NormalizedECDSASigner necdsaSigner = NormalizedECDSASigner(ecdsaSigner);
    necdsaSigner.init(true, PrivateKeyParameter(pk));

    // Generate signature
    final ECSignature signature =
        necdsaSigner.generateSignature(msgHash) as ECSignature;

    // Encode signature to DER format
    final ASN1Sequence seq = ASN1Sequence();
    seq.add(ASN1Integer(signature.r));
    seq.add(ASN1Integer(signature.s));
    final Uint8List derEncodedSignature = seq.encodedBytes;

    // Return hex string
    return hex.encode(derEncodedSignature);
  }

  /// Generate keys from seed phrase
  /// Returns map with publicKey, privateKey, address, and seed
  Map<String, String> getKeysFromString(String seedPhrase) {
    final String seed = seedPhrase.split(' ').join(' ');

    // Calculate SHA-256 hash of seed phrase
    final Uint8List seedHash =
        Uint8List.fromList(sha256.convert(utf8.encode(seed)).bytes);

    // Generate private key from secp256k1 curve
    final ECDomainParameters params = ECDomainParameters('secp256k1');
    final ECPrivateKey privateKey = ECPrivateKey(
      BigInt.parse(_uint8ListToHex(seedHash), radix: 16),
      params,
    );

    // Derive public key
    final ECPublicKey publicKey = ECPublicKey(params.G * privateKey.d!, params);

    // Get public key hex (uncompressed, no 0x04 prefix)
    final String publicKeyHex = _uint8ListToHex(publicKey.Q!.getEncoded(false));
    final String publicKeyWithoutPrefix = publicKeyHex.substring(2);
    final String privateKeyHex = _uint8ListToHex(seedHash);

    // Calculate address from public key using SHA-256
    final Uint8List addressHash =
        Uint8List.fromList(sha256.convert(utf8.encode(publicKeyWithoutPrefix)).bytes);

    return {
      'publicKey': publicKeyWithoutPrefix,
      'privateKey': privateKeyHex,
      'address': _uint8ListToHex(addressHash),
      'seed': seed,
    };
  }

  // ============================================================================
  // Helper Methods - Encoding
  // ============================================================================

%{helpers_encoding.dart.hexFix}

%{helpers_encoding.dart.stringToHex}

%{helpers_encoding.dart.hexToString}

%{helpers_encoding.dart.padNumber}

%{helpers_encoding.dart.getFormattedTimestamp}

  // ============================================================================
  // Helper Methods - Advanced
  // ============================================================================

%{helpers_advanced.dart.GetError}

%{helpers_advanced.dart.handleError}

%{helpers_advanced.dart.getTransactionOutcome}

  /// Close HTTP client
  void dispose() {
    _httpClient.close();
  }
}

/// Exception thrown by Circular Protocol API
class CircularAPIException implements Exception {
  /// Error message
  final String message;

  /// HTTP or API status code
  final int statusCode;

  /// Endpoint that caused the error
  final String endpoint;

  /// Constructor
  CircularAPIException(
    this.message, {
    required this.statusCode,
    required this.endpoint,
  });

  @override
  String toString() =>
      'CircularAPIException: $message (endpoint: $endpoint, code: $statusCode)';
}
"%,

  # Metadata
  metadata = {
    version = config.version,
    endpoints_count = std.array.length all_endpoints,
    language = "Dart",
    target = "Dart 2.19+",
  },
}
