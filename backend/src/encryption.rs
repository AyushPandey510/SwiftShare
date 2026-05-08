use aes_gcm::{
    aead::{Aead, KeyInit},
    Aes256Gcm, Key, Nonce,
};
use anyhow::Result;
use rand::{Rng, RngCore};
use serde::{Deserialize, Serialize};
use tracing::{error, info};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedData {
    pub nonce: Vec<u8>,
    pub ciphertext: Vec<u8>,
    pub tag: Vec<u8>,
}

pub struct EncryptionManager {
    key: Key<Aes256Gcm>,
}

impl EncryptionManager {
    pub fn new(encryption_key: &str) -> Result<Self> {
        // Generate or derive key from provided string
        let key_bytes = Self::derive_key_from_string(encryption_key);
        let key = Key::<Aes256Gcm>::from_slice(&key_bytes);

        Ok(Self { key: *key })
    }

    pub fn encrypt(&self, data: &[u8]) -> Result<EncryptedData> {
        let cipher = Aes256Gcm::new(&self.key);

        // Generate random nonce
        let mut nonce_bytes = [0u8; 12];
        rand::thread_rng().fill_bytes(&mut nonce_bytes);
        let nonce = Nonce::from_slice(&nonce_bytes);

        // Encrypt data
        let ciphertext = cipher
            .encrypt(nonce, data)
            .map_err(|e| anyhow::anyhow!("Encryption failed: {}", e))?;

        // Split ciphertext into data and tag
        let tag_size = 16; // GCM tag size
        let data_size = ciphertext.len() - tag_size;

        let encrypted_data = ciphertext[..data_size].to_vec();
        let tag = ciphertext[data_size..].to_vec();

        Ok(EncryptedData {
            nonce: nonce_bytes.to_vec(),
            ciphertext: encrypted_data,
            tag: tag,
        })
    }

    pub fn decrypt(&self, encrypted_data: &EncryptedData) -> Result<Vec<u8>> {
        let cipher = Aes256Gcm::new(&self.key);

        // Reconstruct nonce
        let nonce = Nonce::from_slice(&encrypted_data.nonce);

        // Reconstruct ciphertext with tag
        let mut ciphertext = encrypted_data.ciphertext.clone();
        ciphertext.extend_from_slice(&encrypted_data.tag);

        // Decrypt data
        let plaintext = cipher
            .decrypt(nonce, ciphertext.as_slice())
            .map_err(|e| anyhow::anyhow!("Decryption failed: {}", e))?;

        Ok(plaintext)
    }

    pub fn generate_key() -> String {
        let mut key_bytes = [0u8; 32];
        rand::thread_rng().fill_bytes(&mut key_bytes);
        base64::encode(key_bytes)
    }

    fn derive_key_from_string(key_string: &str) -> [u8; 32] {
        use sha2::{Digest, Sha256};

        let mut hasher = Sha256::new();
        hasher.update(key_string.as_bytes());
        let result = hasher.finalize();

        let mut key = [0u8; 32];
        key.copy_from_slice(&result);
        key
    }

    pub fn encrypt_file(
        &self,
        input_path: &std::path::Path,
        output_path: &std::path::Path,
    ) -> Result<()> {
        // Read input file
        let input_data = std::fs::read(input_path)?;

        // Encrypt data
        let encrypted = self.encrypt(&input_data)?;

        // Write encrypted data
        let output_data = serde_json::to_vec(&encrypted)?;
        std::fs::write(output_path, output_data)?;

        info!(
            "File encrypted: {} -> {}",
            input_path.display(),
            output_path.display()
        );
        Ok(())
    }

    pub fn decrypt_file(
        &self,
        input_path: &std::path::Path,
        output_path: &std::path::Path,
    ) -> Result<()> {
        // Read encrypted file
        let encrypted_json = std::fs::read(input_path)?;
        let encrypted_data: EncryptedData = serde_json::from_slice(&encrypted_json)?;

        // Decrypt data
        let decrypted_data = self.decrypt(&encrypted_data)?;

        // Write decrypted data
        std::fs::write(output_path, decrypted_data)?;

        info!(
            "File decrypted: {} -> {}",
            input_path.display(),
            output_path.display()
        );
        Ok(())
    }

    pub fn encrypt_stream(&self, data: &[u8]) -> Result<Vec<u8>> {
        let encrypted = self.encrypt(data)?;
        Ok(serde_json::to_vec(&encrypted)?)
    }

    pub fn decrypt_stream(&self, encrypted_bytes: &[u8]) -> Result<Vec<u8>> {
        let encrypted_data: EncryptedData = serde_json::from_slice(encrypted_bytes)?;
        self.decrypt(&encrypted_data)
    }

    pub fn verify_key(&self, test_data: &[u8]) -> Result<bool> {
        let encrypted = self.encrypt(test_data)?;
        let decrypted = self.decrypt(&encrypted)?;

        Ok(test_data == decrypted.as_slice())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::NamedTempFile;

    #[test]
    fn test_encryption_decryption() {
        let key = "test-encryption-key-32-bytes-long";
        let manager = EncryptionManager::new(key).unwrap();

        let test_data = b"Hello, World! This is a test message.";

        // Test basic encryption/decryption
        let encrypted = manager.encrypt(test_data).unwrap();
        let decrypted = manager.decrypt(&encrypted).unwrap();

        assert_eq!(test_data, decrypted.as_slice());
    }

    #[test]
    fn test_file_encryption() {
        let key = "test-encryption-key-32-bytes-long";
        let manager = EncryptionManager::new(key).unwrap();

        let test_data = b"This is test file content for encryption testing.";

        // Create temporary files
        let input_file = NamedTempFile::new().unwrap();
        let encrypted_file = NamedTempFile::new().unwrap();
        let decrypted_file = NamedTempFile::new().unwrap();

        // Write test data to input file
        std::fs::write(&input_file, test_data).unwrap();

        // Encrypt file
        manager
            .encrypt_file(input_file.path(), encrypted_file.path())
            .unwrap();

        // Decrypt file
        manager
            .decrypt_file(encrypted_file.path(), decrypted_file.path())
            .unwrap();

        // Verify decrypted content
        let decrypted_data = std::fs::read(decrypted_file.path()).unwrap();
        assert_eq!(test_data, decrypted_data.as_slice());
    }

    #[test]
    fn test_stream_encryption() {
        let key = "test-encryption-key-32-bytes-long";
        let manager = EncryptionManager::new(key).unwrap();

        let test_data = b"Stream encryption test data.";

        // Test stream encryption/decryption
        let encrypted = manager.encrypt_stream(test_data).unwrap();
        let decrypted = manager.decrypt_stream(&encrypted).unwrap();

        assert_eq!(test_data, decrypted.as_slice());
    }

    #[test]
    fn test_key_verification() {
        let key = "test-encryption-key-32-bytes-long";
        let manager = EncryptionManager::new(key).unwrap();

        let test_data = b"Key verification test.";

        assert!(manager.verify_key(test_data).unwrap());
    }
}
