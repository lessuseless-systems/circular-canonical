# Cryptographic Helper Functions for SDKs
# Based on circular-js reference implementation
# Provides signing, verification, and key derivation

{
  # TypeScript implementation of crypto helpers
  typescript = {

    # Import statements for TypeScript
    imports = m%"
import { ec as EC } from 'elliptic';
import sha256 from 'sha256';
"%,

    # Sign a message using secp256k1
    signMessage = m%"
  /**
   * Sign a message using secp256k1
   * @param message - Message to sign
   * @param privateKey - Private key in hex format (with or without '0x' prefix)
   * @returns DER-encoded signature as hex string
   */
  signMessage(message: string, privateKey: string): string {
    const ec = new EC('secp256k1');
    const key = ec.keyFromPrivate(this.hexFix(privateKey), 'hex');
    const msgHash = sha256(message);
    const signature = key.sign(msgHash).toDER('hex');
    return signature;
  }
"%,

    # Verify a signature
    verifySignature = m%"
  /**
   * Verify a signature
   * @param publicKey - Public key in hex format
   * @param message - Original message that was signed
   * @param signature - DER-encoded signature in hex format
   * @returns true if signature is valid, false otherwise
   */
  verifySignature(publicKey: string, message: string, signature: string): boolean {
    try {
      const ec = new EC('secp256k1');
      const key = ec.keyFromPublic(this.hexFix(publicKey), 'hex');
      const msgHash = sha256(message);
      return key.verify(msgHash, signature);
    } catch (error) {
      return false;
    }
  }
"%,

    # Derive public key from private key
    getPublicKey = m%"
  /**
   * Derive public key from private key
   * @param privateKey - Private key in hex format (with or without '0x' prefix)
   * @returns Public key in uncompressed hex format
   */
  getPublicKey(privateKey: string): string {
    const ec = new EC('secp256k1');
    const key = ec.keyFromPrivate(this.hexFix(privateKey), 'hex');
    return key.getPublic('hex');
  }
"%,

    # SHA256 hash
    hashString = m%"
  /**
   * Compute SHA256 hash of a string
   * @param str - String to hash
   * @returns SHA256 hash as hex string
   */
  hashString(str: string): string {
    return sha256(str);
  }
"%,

  },

  # Python implementation of crypto helpers
  python = {

    # Import statements for Python
    imports = m%"
from ecdsa import SigningKey, VerifyingKey, SECP256k1
import hashlib
"%,

    # Sign a message
    signMessage = m%"
    def sign_message(self, message: str, private_key: str) -> str:
        """
        Sign a message using secp256k1

        Args:
            message: Message to sign
            private_key: Private key in hex format (with or without '0x' prefix)

        Returns:
            DER-encoded signature as hex string
        """
        private_key_bytes = bytes.fromhex(self.hex_fix(private_key))
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)
        msg_hash = hashlib.sha256(message.encode()).digest()
        signature = sk.sign_digest(msg_hash, sigencode=lambda r, s, order: r.to_bytes(32, 'big') + s.to_bytes(32, 'big'))
        return signature.hex()
"%,

    # Verify signature
    verifySignature = m%"
    def verify_signature(self, public_key: str, message: str, signature: str) -> bool:
        """
        Verify a signature

        Args:
            public_key: Public key in hex format
            message: Original message that was signed
            signature: Signature in hex format

        Returns:
            True if signature is valid, False otherwise
        """
        try:
            public_key_bytes = bytes.fromhex(self.hex_fix(public_key))
            vk = VerifyingKey.from_string(public_key_bytes, curve=SECP256k1)
            msg_hash = hashlib.sha256(message.encode()).digest()
            signature_bytes = bytes.fromhex(signature)
            return vk.verify_digest(signature_bytes, msg_hash)
        except Exception:
            return False
"%,

    # Get public key
    getPublicKey = m%"
    def get_public_key(self, private_key: str) -> str:
        """
        Derive public key from private key

        Args:
            private_key: Private key in hex format (with or without '0x' prefix)

        Returns:
            Public key in uncompressed hex format
        """
        private_key_bytes = bytes.fromhex(self.hex_fix(private_key))
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)
        vk = sk.get_verifying_key()
        return vk.to_string().hex()
"%,

    # Hash string
    hashString = m%"
    def hash_string(self, string: str) -> str:
        """
        Compute SHA256 hash of a string

        Args:
            string: String to hash

        Returns:
            SHA256 hash as hex string
        """
        return hashlib.sha256(string.encode()).hexdigest()
"%,

  },
}
