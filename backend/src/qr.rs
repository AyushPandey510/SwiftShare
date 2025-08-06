use qrcode::{QrCode, render::svg};
use serde::{Deserialize, Serialize};
use anyhow::Result;
use tracing::info;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConnectionInfo {
    pub device_id: String,
    pub device_name: String,
    pub ip_address: String,
    pub api_port: u16,
    pub transfer_port: u16,
    pub capabilities: Vec<String>,
    pub version: String,
    pub timestamp: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FileShareInfo {
    pub file_id: String,
    pub filename: String,
    pub size: u64,
    pub checksum: String,
    pub sender_device: String,
    pub timestamp: i64,
    pub encrypted: bool,
}

pub struct QRCodeManager;

impl QRCodeManager {
    pub fn generate_connection_qr(connection_info: &ConnectionInfo) -> Result<String> {
        // Serialize connection info to JSON
        let json_data = serde_json::to_string(connection_info)?;
        
        // Generate QR code
        let code = QrCode::new(json_data)?;
        
        // Convert to SVG
        let svg_string = code.render()
            .min_dimensions(200, 200)
            .dark_color(svg::Color("#000000"))
            .light_color(svg::Color("#ffffff"))
            .build();
        
        Ok(svg_string)
    }

    pub fn generate_file_share_qr(file_info: &FileShareInfo) -> Result<String> {
        // Serialize file info to JSON
        let json_data = serde_json::to_string(file_info)?;
        
        // Generate QR code
        let code = QrCode::new(json_data)?;
        
        // Convert to SVG
        let svg_string = code.render()
            .min_dimensions(200, 200)
            .dark_color(svg::Color("#000000"))
            .light_color(svg::Color("#ffffff"))
            .build();
        
        Ok(svg_string)
    }

    pub fn generate_text_qr(text: &str) -> Result<String> {
        // Generate QR code for plain text
        let code = QrCode::new(text)?;
        
        // Convert to SVG
        let svg_string = code.render()
            .min_dimensions(200, 200)
            .dark_color(svg::Color("#000000"))
            .light_color(svg::Color("#ffffff"))
            .build();
        
        Ok(svg_string)
    }

    pub fn generate_wifi_qr(ssid: &str, password: &str, security: &str) -> Result<String> {
        // Generate WiFi QR code format
        let wifi_data = format!("WIFI:S:{};T:{};P:{};;", ssid, security, password);
        
        let code = QrCode::new(&wifi_data)?;
        
        // Convert to SVG
        let svg_string = code.render()
            .min_dimensions(200, 200)
            .dark_color(svg::Color("#000000"))
            .light_color(svg::Color("#ffffff"))
            .build();
        
        Ok(svg_string)
    }

    pub fn save_qr_to_file(qr_svg: &str, file_path: &std::path::Path) -> Result<()> {
        std::fs::write(file_path, qr_svg)?;
        info!("QR code saved to: {}", file_path.display());
        Ok(())
    }

    pub fn generate_qr_png(text: &str, size: u32) -> Result<Vec<u8>> {
        use image::Rgb;
        
        // Generate QR code
        let code = QrCode::new(text)?;
        
        // Convert to image
        let image = code.render()
            .min_dimensions(size, size)
            .dark_color(Rgb([0u8, 0, 0]))
            .light_color(Rgb([255u8, 255, 255]))
            .build();
        
        // Convert to PNG bytes
        let mut png_bytes = Vec::new();
        image.write_to(&mut std::io::Cursor::new(&mut png_bytes), image::ImageFormat::Png)?;
        
        Ok(png_bytes)
    }

    pub fn parse_connection_qr(qr_data: &str) -> Result<ConnectionInfo> {
        // Try to parse as JSON
        let connection_info: ConnectionInfo = serde_json::from_str(qr_data)?;
        Ok(connection_info)
    }

    pub fn parse_file_share_qr(qr_data: &str) -> Result<FileShareInfo> {
        // Try to parse as JSON
        let file_info: FileShareInfo = serde_json::from_str(qr_data)?;
        Ok(file_info)
    }

    pub fn validate_qr_data(qr_data: &str) -> bool {
        // Try to parse as connection info
        if let Ok(_) = Self::parse_connection_qr(qr_data) {
            return true;
        }
        
        // Try to parse as file share info
        if let Ok(_) = Self::parse_file_share_qr(qr_data) {
            return true;
        }
        
        // Check if it's a valid URL or plain text
        if qr_data.starts_with("http://") || qr_data.starts_with("https://") {
            return true;
        }
        
        // Check if it's a WiFi QR code
        if qr_data.starts_with("WIFI:") {
            return true;
        }
        
        // Assume it's valid plain text
        true
    }

    pub fn create_connection_info(
        device_id: &str,
        device_name: &str,
        ip_address: &str,
        api_port: u16,
        transfer_port: u16,
        capabilities: Vec<String>,
        version: &str,
    ) -> ConnectionInfo {
        ConnectionInfo {
            device_id: device_id.to_string(),
            device_name: device_name.to_string(),
            ip_address: ip_address.to_string(),
            api_port,
            transfer_port,
            capabilities,
            version: version.to_string(),
            timestamp: chrono::Utc::now().timestamp(),
        }
    }

    pub fn create_file_share_info(
        file_id: &str,
        filename: &str,
        size: u64,
        checksum: &str,
        sender_device: &str,
        encrypted: bool,
    ) -> FileShareInfo {
        FileShareInfo {
            file_id: file_id.to_string(),
            filename: filename.to_string(),
            size,
            checksum: checksum.to_string(),
            sender_device: sender_device.to_string(),
            timestamp: chrono::Utc::now().timestamp(),
            encrypted,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_connection_qr_generation() {
        let connection_info = ConnectionInfo {
            device_id: "test-device-123".to_string(),
            device_name: "Test Device".to_string(),
            ip_address: "192.168.1.100".to_string(),
            api_port: 8082,
            transfer_port: 8083,
            capabilities: vec!["file-transfer".to_string(), "encryption".to_string()],
            version: "1.0.0".to_string(),
            timestamp: chrono::Utc::now().timestamp(),
        };
        
        let qr_svg = QRCodeManager::generate_connection_qr(&connection_info).unwrap();
        assert!(qr_svg.contains("svg"));
    }

    #[test]
    fn test_file_share_qr_generation() {
        let file_info = FileShareInfo {
            file_id: "file-123".to_string(),
            filename: "test.txt".to_string(),
            size: 1024,
            checksum: "sha256-hash".to_string(),
            sender_device: "device-123".to_string(),
            timestamp: chrono::Utc::now().timestamp(),
            encrypted: false,
        };
        
        let qr_svg = QRCodeManager::generate_file_share_qr(&file_info).unwrap();
        assert!(qr_svg.contains("svg"));
    }

    #[test]
    fn test_text_qr_generation() {
        let text = "Hello, World!";
        let qr_svg = QRCodeManager::generate_text_qr(text).unwrap();
        assert!(qr_svg.contains("svg"));
    }

    #[test]
    fn test_wifi_qr_generation() {
        let qr_svg = QRCodeManager::generate_wifi_qr("MyWiFi", "password123", "WPA").unwrap();
        assert!(qr_svg.contains("svg"));
    }

    #[test]
    fn test_qr_validation() {
        assert!(QRCodeManager::validate_qr_data("https://example.com"));
        assert!(QRCodeManager::validate_qr_data("WIFI:S:MyWiFi;T:WPA;P:password;;"));
        assert!(QRCodeManager::validate_qr_data("Plain text"));
    }
} 