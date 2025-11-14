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
import hashlib
from ecdsa import SigningKey, SECP256k1
from ecdsa.util import sigencode_der, sigdecode_der
"%,

    # Sign a message
    signMessage = m%"
    def sign_message(self, message: str, private_key: str) -> str:
        """
        Sign a message using secp256k1 with DER encoding

        Args:
            message: Message to sign (will be SHA256 hashed)
            private_key: Private key in hex format (with or without '0x' prefix)

        Returns:
            DER-encoded signature as hex string
        """
        # Remove 0x prefix if present
        clean_key = self.hex_fix(private_key)

        # Create signing key
        private_key_bytes = bytes.fromhex(clean_key)
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

        # Hash the message
        message_hash = hashlib.sha256(message.encode()).digest()

        # Sign with DER encoding (matching circular-js behavior)
        signature_bytes = sk.sign_digest(message_hash, sigencode=sigencode_der)
        return signature_bytes.hex()
"%,

    # Verify signature
    verifySignature = m%"
    def verify_signature(self, public_key: str, message: str, signature: str) -> bool:
        """
        Verify a DER-encoded signature

        Args:
            public_key: Public key in hex format (uncompressed, 64 bytes without 0x04 prefix)
            message: Original message that was signed
            signature: DER-encoded signature in hex format

        Returns:
            True if signature is valid, False otherwise
        """
        try:
            from ecdsa import VerifyingKey

            # Parse public key
            public_key_bytes = bytes.fromhex(self.hex_fix(public_key))
            # Add uncompressed point prefix if needed (0x04)
            if len(public_key_bytes) == 64:
                public_key_bytes = b'\x04' + public_key_bytes

            vk = VerifyingKey.from_string(public_key_bytes[1:], curve=SECP256k1)

            # Hash the message
            message_hash = hashlib.sha256(message.encode()).digest()

            # Verify DER-encoded signature
            signature_bytes = bytes.fromhex(self.hex_fix(signature))
            vk.verify_digest(signature_bytes, message_hash, sigdecode=sigdecode_der)
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
        # Remove 0x prefix if present
        clean_key = self.hex_fix(private_key)

        # Create signing key
        private_key_bytes = bytes.fromhex(clean_key)
        sk = SigningKey.from_string(private_key_bytes, curve=SECP256k1)

        # Get public key
        vk = sk.get_verifying_key()
        public_key_bytes = vk.to_string()  # Returns 64 bytes without 0x04 prefix

        return public_key_bytes.hex()
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

  # Java implementation of crypto helpers
  java = {

    # Import statements for Java
    imports = m%"
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.jce.ECNamedCurveTable;
import org.bouncycastle.jce.spec.ECParameterSpec;
import org.bouncycastle.jce.spec.ECPrivateKeySpec;
import org.bouncycastle.jce.spec.ECPublicKeySpec;
import org.bouncycastle.math.ec.ECPoint;
import java.math.BigInteger;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import javax.xml.bind.DatatypeConverter;
"%,

    # Sign a message
    signMessage = m%"
    /**
     * Sign a message using secp256k1 with DER encoding
     *
     * @param message Message to sign (will be SHA256 hashed)
     * @param privateKey Private key in hex format (with or without '0x' prefix)
     * @return DER-encoded signature as hex string
     */
    public String signMessage(String message, String privateKey) throws Exception {
        // Register BouncyCastle provider
        Security.addProvider(new BouncyCastleProvider());

        // Remove 0x prefix if present
        String cleanKey = hexFix(privateKey);

        // Parse private key
        ECParameterSpec ecSpec = ECNamedCurveTable.getParameterSpec("secp256k1");
        BigInteger privateKeyInt = new BigInteger(cleanKey, 16);
        ECPrivateKeySpec privateKeySpec = new ECPrivateKeySpec(privateKeyInt, ecSpec);
        KeyFactory keyFactory = KeyFactory.getInstance("ECDSA", "BC");
        PrivateKey privKey = keyFactory.generatePrivate(privateKeySpec);

        // Hash the message
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] messageHash = digest.digest(message.getBytes("UTF-8"));

        // Sign with DER encoding (default format in Java)
        Signature signature = Signature.getInstance("SHA256withECDSA", "BC");
        signature.initSign(privKey);
        signature.update(messageHash);
        byte[] signatureBytes = signature.sign();

        // Convert to hex
        return DatatypeConverter.printHexBinary(signatureBytes).toLowerCase();
    }
"%,

    # Verify signature
    verifySignature = m%"
    /**
     * Verify a DER-encoded signature
     *
     * @param publicKey Public key in hex format (uncompressed, 64 bytes without 0x04 prefix)
     * @param message Original message that was signed
     * @param signatureHex DER-encoded signature in hex format
     * @return true if signature is valid, false otherwise
     */
    public boolean verifySignature(String publicKey, String message, String signatureHex) {
        try {
            // Register BouncyCastle provider
            Security.addProvider(new BouncyCastleProvider());

            // Parse public key
            String cleanPubKey = hexFix(publicKey);
            byte[] pubKeyBytes = DatatypeConverter.parseHexBinary(cleanPubKey);

            // Add uncompressed point prefix if needed (0x04)
            if (pubKeyBytes.length == 64) {
                byte[] withPrefix = new byte[65];
                withPrefix[0] = 0x04;
                System.arraycopy(pubKeyBytes, 0, withPrefix, 1, 64);
                pubKeyBytes = withPrefix;
            }

            // Reconstruct public key
            ECParameterSpec ecSpec = ECNamedCurveTable.getParameterSpec("secp256k1");
            ECPoint point = ecSpec.getCurve().decodePoint(pubKeyBytes);
            ECPublicKeySpec publicKeySpec = new ECPublicKeySpec(point, ecSpec);
            KeyFactory keyFactory = KeyFactory.getInstance("ECDSA", "BC");
            PublicKey pubKey = keyFactory.generatePublic(publicKeySpec);

            // Hash the message
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] messageHash = digest.digest(message.getBytes("UTF-8"));

            // Verify DER-encoded signature
            byte[] signatureBytes = DatatypeConverter.parseHexBinary(hexFix(signatureHex));
            Signature signature = Signature.getInstance("SHA256withECDSA", "BC");
            signature.initVerify(pubKey);
            signature.update(messageHash);

            return signature.verify(signatureBytes);
        } catch (Exception e) {
            return false;
        }
    }
"%,

    # Get public key
    getPublicKey = m%"
    /**
     * Derive public key from private key
     *
     * @param privateKey Private key in hex format (with or without '0x' prefix)
     * @return Public key in uncompressed hex format (64 bytes, without 0x04 prefix)
     */
    public String getPublicKey(String privateKey) throws Exception {
        // Register BouncyCastle provider
        Security.addProvider(new BouncyCastleProvider());

        // Remove 0x prefix if present
        String cleanKey = hexFix(privateKey);

        // Parse private key
        ECParameterSpec ecSpec = ECNamedCurveTable.getParameterSpec("secp256k1");
        BigInteger privateKeyInt = new BigInteger(cleanKey, 16);

        // Calculate public key point
        ECPoint publicPoint = ecSpec.getG().multiply(privateKeyInt).normalize();

        // Get X and Y coordinates (each 32 bytes)
        byte[] x = publicPoint.getAffineXCoord().getEncoded();
        byte[] y = publicPoint.getAffineYCoord().getEncoded();

        // Combine to 64 bytes (without 0x04 prefix)
        byte[] publicKey = new byte[64];
        System.arraycopy(x, 0, publicKey, 0, 32);
        System.arraycopy(y, 0, publicKey, 32, 32);

        return DatatypeConverter.printHexBinary(publicKey).toLowerCase();
    }
"%,

    # Hash string
    hashString = m%"
    /**
     * Compute SHA256 hash of a string
     *
     * @param str String to hash
     * @return SHA256 hash as hex string
     */
    public String hashString(String str) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(str.getBytes("UTF-8"));
        return DatatypeConverter.printHexBinary(hash).toLowerCase();
    }
"%,

  },

  # Go implementation of crypto helpers
  go = {

    # Import statements for Go
    imports = m%"
import (
	"crypto/ecdsa"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/btcsuite/btcd/btcec/v2"
)
"%,

    # Sign a message
    signMessage = m%"
// SignMessage signs a message using secp256k1 with DER encoding
// message: Message to sign (will be SHA256 hashed)
// privateKey: Private key in hex format (with or without '0x' prefix)
// Returns: DER-encoded signature as hex string
func (c *Client) SignMessage(message string, privateKey string) (string, error) {
	// Remove 0x prefix if present
	cleanKey := hexFix(privateKey)

	// Parse private key
	privKeyBytes, err := hex.DecodeString(cleanKey)
	if err != nil {
		return "", fmt.Errorf("invalid private key hex: %w", err)
	}

	privKey, _ := btcec.PrivKeyFromBytes(privKeyBytes)

	// Hash the message
	msgHash := sha256.Sum256([]byte(message))

	// Sign with compact signature (Bitcoin-style)
	signature, err := ecdsa.SignASN1(rand.Reader, privKey.ToECDSA(), msgHash[:])
	if err != nil {
		return "", fmt.Errorf("signing failed: %w", err)
	}

	return hex.EncodeToString(signature), nil
}
"%,

    # Verify signature
    verifySignature = m%"
// VerifySignature verifies a DER-encoded signature
// publicKey: Public key in hex format (uncompressed, 64 bytes without 0x04 prefix)
// message: Original message that was signed
// signatureHex: DER-encoded signature in hex format
// Returns: true if signature is valid, false otherwise
func (c *Client) VerifySignature(publicKey string, message string, signatureHex string) bool {
	// Parse public key
	cleanPubKey := hexFix(publicKey)
	pubKeyBytes, err := hex.DecodeString(cleanPubKey)
	if err != nil {
		return false
	}

	// Add uncompressed point prefix if needed (0x04)
	if len(pubKeyBytes) == 64 {
		pubKeyBytes = append([]byte{0x04}, pubKeyBytes...)
	}

	// Parse public key
	pubKey, err := btcec.ParsePubKey(pubKeyBytes)
	if err != nil {
		return false
	}

	// Hash the message
	msgHash := sha256.Sum256([]byte(message))

	// Parse signature
	signatureBytes, err := hex.DecodeString(hexFix(signatureHex))
	if err != nil {
		return false
	}

	// Verify DER-encoded signature
	return ecdsa.VerifyASN1(pubKey.ToECDSA(), msgHash[:], signatureBytes)
}
"%,

    # Get public key
    getPublicKey = m%"
// GetPublicKey derives public key from private key
// privateKey: Private key in hex format (with or without '0x' prefix)
// Returns: Public key in uncompressed hex format (64 bytes, without 0x04 prefix)
func (c *Client) GetPublicKey(privateKey string) (string, error) {
	// Remove 0x prefix if present
	cleanKey := hexFix(privateKey)

	// Parse private key
	privKeyBytes, err := hex.DecodeString(cleanKey)
	if err != nil {
		return "", fmt.Errorf("invalid private key hex: %w", err)
	}

	privKey, pubKey := btcec.PrivKeyFromBytes(privKeyBytes)
	if privKey == nil {
		return "", fmt.Errorf("failed to derive public key")
	}

	// Get uncompressed public key bytes (65 bytes with 0x04 prefix)
	pubKeyBytes := pubKey.SerializeUncompressed()

	// Remove 0x04 prefix to return 64 bytes
	return hex.EncodeToString(pubKeyBytes[1:]), nil
}
"%,

    # Hash string
    hashString = m%"
// HashString computes SHA256 hash of a string
// str: String to hash
// Returns: SHA256 hash as hex string
func (c *Client) HashString(str string) string {
	hash := sha256.Sum256([]byte(str))
	return hex.EncodeToString(hash[:])
}
"%,

    # Get formatted timestamp
    getFormattedTimestamp = m%%"
// GetFormattedTimestamp returns current timestamp in Circular Protocol format
// Format: YYYY:MM:DD-hh:mm:ss (UTC)
// Returns: Formatted timestamp string
func (c *Client) GetFormattedTimestamp() string {
	now := time.Now().UTC()
	return fmt.Sprintf("%d:%02d:%02d-%02d:%02d:%02d",
		now.Year(),
		now.Month(),
		now.Day(),
		now.Hour(),
		now.Minute(),
		now.Second())
}
"%%,

  },

  # PHP implementation of crypto helpers
  php = {

    # Import/require statements for PHP
    imports = m%"
use phpseclib3\Crypt\EC;
use phpseclib3\Math\BigInteger;
"%,

    # Sign a message
    signMessage = m%"
    /**
     * Sign a message using secp256k1 with DER encoding
     *
     * @param string $message Message to sign (will be SHA256 hashed)
     * @param string $privateKey Private key in hex format (with or without '0x' prefix)
     * @return string DER-encoded signature as hex string
     */
    public function signMessage(string $message, string $privateKey): string {
        // Remove 0x prefix if present
        $cleanKey = $this->hexFix($privateKey);

        // Create private key
        $privateKeyObj = EC::loadPrivateKey([
            'curve' => 'secp256k1',
            'secret' => new BigInteger($cleanKey, 16)
        ]);

        // Hash the message
        $messageHash = hash('sha256', $message, true);

        // Sign with DER encoding (default format in phpseclib)
        $signature = $privateKeyObj->sign($messageHash);

        // Return hex-encoded signature
        return bin2hex($signature);
    }
"%,

    # Verify signature
    verifySignature = m%"
    /**
     * Verify a DER-encoded signature
     *
     * @param string $publicKey Public key in hex format (uncompressed, 64 bytes without 0x04 prefix)
     * @param string $message Original message that was signed
     * @param string $signatureHex DER-encoded signature in hex format
     * @return bool true if signature is valid, false otherwise
     */
    public function verifySignature(string $publicKey, string $message, string $signatureHex): bool {
        try {
            // Parse public key
            $cleanPubKey = $this->hexFix($publicKey);
            $pubKeyBytes = hex2bin($cleanPubKey);

            // Add uncompressed point prefix if needed (0x04)
            if (strlen($pubKeyBytes) === 64) {
                $pubKeyBytes = "\x04" . $pubKeyBytes;
            }

            // Extract X and Y coordinates
            $x = substr($pubKeyBytes, 1, 32);
            $y = substr($pubKeyBytes, 33, 32);

            // Create public key
            $publicKeyObj = EC::loadPublicKey([
                'curve' => 'secp256k1',
                'QA' => [
                    'x' => new BigInteger(bin2hex($x), 16),
                    'y' => new BigInteger(bin2hex($y), 16)
                ]
            ]);

            // Hash the message
            $messageHash = hash('sha256', $message, true);

            // Verify DER-encoded signature
            $signatureBytes = hex2bin($this->hexFix($signatureHex));

            return $publicKeyObj->verify($messageHash, $signatureBytes);
        } catch (\Exception $e) {
            return false;
        }
    }
"%,

    # Get public key
    getPublicKey = m%"
    /**
     * Derive public key from private key
     *
     * @param string $privateKey Private key in hex format (with or without '0x' prefix)
     * @return string Public key in uncompressed hex format (64 bytes, without 0x04 prefix)
     */
    public function getPublicKey(string $privateKey): string {
        // Remove 0x prefix if present
        $cleanKey = $this->hexFix($privateKey);

        // Create private key
        $privateKeyObj = EC::loadPrivateKey([
            'curve' => 'secp256k1',
            'secret' => new BigInteger($cleanKey, 16)
        ]);

        // Get public key
        $publicKeyObj = $privateKeyObj->getPublicKey();
        $point = $publicKeyObj->getEncodedCoordinates();

        // Extract X and Y coordinates (remove 0x04 prefix)
        $publicKeyBytes = hex2bin($point);
        if ($publicKeyBytes[0] === "\x04") {
            $publicKeyBytes = substr($publicKeyBytes, 1);
        }

        return bin2hex($publicKeyBytes);
    }
"%,

    # Hash string
    hashString = m%"
    /**
     * Compute SHA256 hash of a string
     *
     * @param string $str String to hash
     * @return string SHA256 hash as hex string
     */
    public function hashString(string $str): string {
        return hash('sha256', $str);
    }
"%,

  },
}
