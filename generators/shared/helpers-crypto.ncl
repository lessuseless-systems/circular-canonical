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
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend
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
            Signature as hex string (r||s format, 64 bytes)
        """
        private_key_bytes = bytes.fromhex(self.hex_fix(private_key))
        private_key_int = int.from_bytes(private_key_bytes, byteorder='big')
        sk = ec.derive_private_key(private_key_int, ec.SECP256K1(), default_backend())

        # Hash message once (matching TypeScript sha256 behavior)
        msg_hash = hashlib.sha256(message.encode()).digest()

        # Sign with Prehashed to avoid double-hashing (sk.sign would hash again otherwise)
        from cryptography.hazmat.primitives.asymmetric.utils import Prehashed, decode_dss_signature
        signature_der = sk.sign(msg_hash, ec.ECDSA(Prehashed(hashes.SHA256())))

        # Convert DER to raw r||s format for consistency with TypeScript
        r, s = decode_dss_signature(signature_der)
        signature_bytes = r.to_bytes(32, 'big') + s.to_bytes(32, 'big')
        return signature_bytes.hex()
"%,

    # Verify signature
    verifySignature = m%"
    def verify_signature(self, public_key: str, message: str, signature: str) -> bool:
        """
        Verify a signature

        Args:
            public_key: Public key in hex format (uncompressed, 64 bytes)
            message: Original message that was signed
            signature: Signature in hex format (r||s format, 64 bytes)

        Returns:
            True if signature is valid, False otherwise
        """
        try:
            public_key_bytes = bytes.fromhex(self.hex_fix(public_key))
            # Add uncompressed point prefix if needed (0x04)
            if len(public_key_bytes) == 64:
                public_key_bytes = b'\x04' + public_key_bytes

            vk = ec.EllipticCurvePublicKey.from_encoded_point(ec.SECP256K1(), public_key_bytes)

            # Hash message once (matching TypeScript sha256 behavior)
            msg_hash = hashlib.sha256(message.encode()).digest()

            # Convert r||s format to DER
            signature_bytes = bytes.fromhex(signature)
            r = int.from_bytes(signature_bytes[:32], 'big')
            s = int.from_bytes(signature_bytes[32:], 'big')

            from cryptography.hazmat.primitives.asymmetric.utils import Prehashed, encode_dss_signature
            signature_der = encode_dss_signature(r, s)

            # Verify with Prehashed to match signing behavior
            vk.verify(signature_der, msg_hash, ec.ECDSA(Prehashed(hashes.SHA256())))
            return True
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
            Public key in uncompressed hex format (64 bytes, without 0x04 prefix)
        """
        private_key_bytes = bytes.fromhex(self.hex_fix(private_key))
        private_key_int = int.from_bytes(private_key_bytes, byteorder='big')
        sk = ec.derive_private_key(private_key_int, ec.SECP256K1(), default_backend())
        vk = sk.public_key()
        public_key_bytes = vk.public_bytes(
            encoding=serialization.Encoding.X962,
            format=serialization.PublicFormat.UncompressedPoint
        )
        # Remove the 0x04 prefix to match TypeScript output
        return public_key_bytes[1:].hex()
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
