/**
 * Simple Helper Functions Test (JavaScript)
 * Tests helper functions without TypeScript compilation complexity
 */

const { CircularProtocolAPI } = require('./dist/typescript/src/index.js');

async function testHelpers() {
  console.log('🧪 Testing Helper Functions\n');

  const api = new CircularProtocolAPI();

  // Test 1: Configuration helpers
  console.log('Test 1: Configuration Helpers');
  const defaultURL = api.getNAGURL();
  console.log(`  Default NAG URL: ${defaultURL}`);

  api.setNAGURL('https://testnet.circularlabs.io/NAG.php?cep=');
  const newURL = api.getNAGURL();
  console.log(`  Updated NAG URL: ${newURL}`);
  console.log(`  ✅ setNAGURL/getNAGURL work\n`);

  // Test 2: Timestamp helper
  console.log('Test 2: Timestamp Helper');
  const timestamp = api.getFormattedTimestamp();
  console.log(`  Timestamp: ${timestamp}`);
  const regex = /^\d{4}:\d{2}:\d{2}-\d{2}:\d{2}:\d{2}$/;
  if (!regex.test(timestamp)) {
    throw new Error(`Invalid timestamp format: ${timestamp}`);
  }
  console.log(`  ✅ getFormattedTimestamp works (YYYY:MM:DD-hh:mm:ss)\n`);

  // Test 3: Hex encoding helpers
  console.log('Test 3: Hex Encoding Helpers');
  const testString = 'Hello Circular Protocol!';
  const encoded = api.stringToHex(testString);
  console.log(`  Original: "${testString}"`);
  console.log(`  Hex: "${encoded}"`);

  const decoded = api.hexToString(encoded);
  console.log(`  Decoded: "${decoded}"`);
  if (decoded !== testString) {
    throw new Error('Hex encoding/decoding failed');
  }
  console.log(`  ✅ stringToHex/hexToString work\n`);

  // Test 4: Hex fix helper
  console.log('Test 4: Hex Fix Helper');
  const hexWith0x = '0x1234abcdEF';
  const hexWithout0x = api.hexFix(hexWith0x);
  console.log(`  Input: "${hexWith0x}"`);
  console.log(`  Output: "${hexWithout0x}"`);
  if (hexWithout0x !== '1234abcdEF') {
    throw new Error('hexFix failed');
  }

  const hexAlready = 'abcd1234';
  const hexUnchanged = api.hexFix(hexAlready);
  if (hexUnchanged !== 'abcd1234') {
    throw new Error('hexFix modified non-prefixed hex');
  }
  console.log(`  ✅ hexFix works\n`);

  // Test 5: Crypto helpers (signing/verification)
  console.log('Test 5: Cryptographic Helpers');
  const message = 'Test transaction data';
  const privateKey = '0f55c0c43496a9c3e1813180bec90e610769e15354771aebe7e28e83b3f89e8a';

  // Derive public key
  const publicKey = api.getPublicKey(privateKey);
  console.log(`  Public key: ${publicKey.substring(0, 40)}...`);
  if (!publicKey || publicKey.length < 64) {
    throw new Error('Invalid public key generated');
  }
  console.log(`  ✅ getPublicKey works`);

  // Sign message
  const signature = api.signMessage(message, privateKey);
  console.log(`  Signature: ${signature.substring(0, 40)}...`);
  if (!signature || signature.length < 64) {
    throw new Error('Invalid signature generated');
  }
  console.log(`  ✅ signMessage works`);

  // Verify signature
  const isValid = api.verifySignature(publicKey, message, signature);
  console.log(`  Signature valid: ${isValid}`);
  if (!isValid) {
    throw new Error('Signature verification failed');
  }
  console.log(`  ✅ verifySignature works`);

  // Test invalid signature
  const invalidSignature = signature.slice(0, -2) + 'FF';
  const isInvalid = api.verifySignature(publicKey, message, invalidSignature);
  console.log(`  Invalid signature check: ${!isInvalid}`);
  if (isInvalid) {
    throw new Error('Invalid signature was verified as valid');
  }
  console.log(`  ✅ verifySignature rejects invalid signatures\n`);

  // Test 6: Hash helper
  console.log('Test 6: Hash Helper');
  const hashInput = 'Circular Protocol';
  const hash = api.hashString(hashInput);
  console.log(`  Input: "${hashInput}"`);
  console.log(`  SHA256: ${hash}`);
  if (hash.length !== 64) {
    throw new Error(`Invalid hash length: ${hash.length}`);
  }
  if (!/^[0-9a-f]+$/.test(hash)) {
    throw new Error('Hash contains non-hex characters');
  }
  console.log(`  ✅ hashString works\n`);

  // Test 7: Error tracking
  console.log('Test 7: Error Tracking');
  const initialError = api.GetError();
  console.log(`  Initial error: "${initialError}"`);
  console.log(`  ✅ GetError works\n`);

  console.log('🎉 All helper function tests passed!');
  console.log('\nSummary:');
  console.log('  ✅ Configuration helpers (setNAGURL, getNAGURL)');
  console.log('  ✅ Timestamp formatting (getFormattedTimestamp)');
  console.log('  ✅ Hex encoding (stringToHex, hexToString, hexFix)');
  console.log('  ✅ Cryptography (getPublicKey, signMessage, verifySignature)');
  console.log('  ✅ Hashing (hashString)');
  console.log('  ✅ Error tracking (GetError)');
}

testHelpers().catch(error => {
  console.error('\n❌ Test failed:', error);
  process.exit(1);
});
