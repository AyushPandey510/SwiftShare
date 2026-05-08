use anyhow::Result;
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::{
    sqlite::{SqliteConnectOptions, SqlitePool},
    Row,
};
use std::path::PathBuf;
use std::str::FromStr;
use tracing::info;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransferRecord {
    pub id: Uuid,
    pub filename: String,
    pub size: u64,
    pub status: String,
    pub start_time: DateTime<Utc>,
    pub end_time: Option<DateTime<Utc>>,
    pub source_device: Option<String>,
    pub target_device: Option<String>,
    pub speed: Option<f64>,
    pub error_message: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DeviceRecord {
    pub id: Uuid,
    pub name: String,
    pub device_type: String,
    pub ip_address: String,
    pub port: u16,
    pub api_port: u16,
    pub last_seen: DateTime<Utc>,
    pub is_online: bool,
    pub capabilities: String, // JSON string
    pub version: Option<String>,
}

pub struct TransferDatabase {
    pool: SqlitePool,
}

impl TransferDatabase {
    pub async fn new(database_path: &PathBuf) -> Result<Self> {
        // Ensure database directory exists
        if let Some(parent) = database_path.parent() {
            tokio::fs::create_dir_all(parent).await?;
        }

        let options = if database_path.to_string_lossy() == ":memory:" {
            SqliteConnectOptions::from_str("sqlite::memory:")?
        } else {
            SqliteConnectOptions::from_str(&format!("sqlite:{}", database_path.display()))?
                .create_if_missing(true)
        };

        let pool = SqlitePool::connect_with(options).await?;

        // Create tables
        Self::create_tables(&pool).await?;

        Ok(Self { pool })
    }

    async fn create_tables(pool: &SqlitePool) -> Result<()> {
        // Create transfers table
        sqlx::query(
            r#"
            CREATE TABLE IF NOT EXISTS transfers (
                id TEXT PRIMARY KEY,
                filename TEXT NOT NULL,
                size INTEGER NOT NULL,
                status TEXT NOT NULL,
                start_time TEXT NOT NULL,
                end_time TEXT,
                source_device TEXT,
                target_device TEXT,
                speed REAL,
                error_message TEXT
            )
            "#,
        )
        .execute(pool)
        .await?;

        // Create devices table
        sqlx::query(
            r#"
            CREATE TABLE IF NOT EXISTS devices (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                device_type TEXT NOT NULL,
                ip_address TEXT NOT NULL,
                port INTEGER NOT NULL,
                api_port INTEGER NOT NULL,
                last_seen TEXT NOT NULL,
                is_online BOOLEAN NOT NULL,
                capabilities TEXT NOT NULL,
                version TEXT
            )
            "#,
        )
        .execute(pool)
        .await?;

        info!("Database tables created successfully");
        Ok(())
    }

    pub async fn save_transfer(&self, transfer: &TransferRecord) -> Result<()> {
        sqlx::query(
            r#"
            INSERT OR REPLACE INTO transfers 
            (id, filename, size, status, start_time, end_time, source_device, target_device, speed, error_message)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            "#
        )
        .bind(transfer.id.to_string())
        .bind(&transfer.filename)
        .bind(transfer.size as i64)
        .bind(&transfer.status)
        .bind(transfer.start_time.to_rfc3339())
        .bind(transfer.end_time.map(|t| t.to_rfc3339()))
        .bind(&transfer.source_device)
        .bind(&transfer.target_device)
        .bind(transfer.speed)
        .bind(&transfer.error_message)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    pub async fn get_transfer(&self, transfer_id: Uuid) -> Result<Option<TransferRecord>> {
        let row = sqlx::query("SELECT * FROM transfers WHERE id = ?")
            .bind(transfer_id.to_string())
            .fetch_optional(&self.pool)
            .await?;

        if let Some(row) = row {
            Ok(Some(Self::row_to_transfer_record(row)?))
        } else {
            Ok(None)
        }
    }

    pub async fn get_all_transfers(&self, limit: Option<i64>) -> Result<Vec<TransferRecord>> {
        let query = if let Some(limit) = limit {
            sqlx::query("SELECT * FROM transfers ORDER BY start_time DESC LIMIT ?").bind(limit)
        } else {
            sqlx::query("SELECT * FROM transfers ORDER BY start_time DESC")
        };

        let rows = query.fetch_all(&self.pool).await?;

        let mut transfers = Vec::new();
        for row in rows {
            transfers.push(Self::row_to_transfer_record(row)?);
        }

        Ok(transfers)
    }

    pub async fn get_transfers_by_status(&self, status: &str) -> Result<Vec<TransferRecord>> {
        let rows = sqlx::query("SELECT * FROM transfers WHERE status = ? ORDER BY start_time DESC")
            .bind(status)
            .fetch_all(&self.pool)
            .await?;

        let mut transfers = Vec::new();
        for row in rows {
            transfers.push(Self::row_to_transfer_record(row)?);
        }

        Ok(transfers)
    }

    pub async fn update_transfer_status(&self, transfer_id: Uuid, status: &str) -> Result<()> {
        sqlx::query("UPDATE transfers SET status = ? WHERE id = ?")
            .bind(status)
            .bind(transfer_id.to_string())
            .execute(&self.pool)
            .await?;

        Ok(())
    }

    pub async fn update_transfer_progress(
        &self,
        transfer_id: Uuid,
        end_time: Option<DateTime<Utc>>,
        speed: Option<f64>,
    ) -> Result<()> {
        sqlx::query("UPDATE transfers SET end_time = ?, speed = ? WHERE id = ?")
            .bind(end_time.map(|t| t.to_rfc3339()))
            .bind(speed)
            .bind(transfer_id.to_string())
            .execute(&self.pool)
            .await?;

        Ok(())
    }

    pub async fn save_device(&self, device: &DeviceRecord) -> Result<()> {
        sqlx::query(
            r#"
            INSERT OR REPLACE INTO devices 
            (id, name, device_type, ip_address, port, api_port, last_seen, is_online, capabilities, version)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            "#
        )
        .bind(device.id.to_string())
        .bind(&device.name)
        .bind(&device.device_type)
        .bind(&device.ip_address)
        .bind(device.port as i64)
        .bind(device.api_port as i64)
        .bind(device.last_seen.to_rfc3339())
        .bind(device.is_online)
        .bind(&device.capabilities)
        .bind(&device.version)
        .execute(&self.pool)
        .await?;

        Ok(())
    }

    pub async fn get_device(&self, device_id: Uuid) -> Result<Option<DeviceRecord>> {
        let row = sqlx::query("SELECT * FROM devices WHERE id = ?")
            .bind(device_id.to_string())
            .fetch_optional(&self.pool)
            .await?;

        if let Some(row) = row {
            Ok(Some(Self::row_to_device_record(row)?))
        } else {
            Ok(None)
        }
    }

    pub async fn get_all_devices(&self) -> Result<Vec<DeviceRecord>> {
        let rows = sqlx::query("SELECT * FROM devices ORDER BY last_seen DESC")
            .fetch_all(&self.pool)
            .await?;

        let mut devices = Vec::new();
        for row in rows {
            devices.push(Self::row_to_device_record(row)?);
        }

        Ok(devices)
    }

    pub async fn get_online_devices(&self) -> Result<Vec<DeviceRecord>> {
        let rows =
            sqlx::query("SELECT * FROM devices WHERE is_online = true ORDER BY last_seen DESC")
                .fetch_all(&self.pool)
                .await?;

        let mut devices = Vec::new();
        for row in rows {
            devices.push(Self::row_to_device_record(row)?);
        }

        Ok(devices)
    }

    pub async fn update_device_status(&self, device_id: Uuid, is_online: bool) -> Result<()> {
        sqlx::query("UPDATE devices SET is_online = ?, last_seen = ? WHERE id = ?")
            .bind(is_online)
            .bind(Utc::now().to_rfc3339())
            .bind(device_id.to_string())
            .execute(&self.pool)
            .await?;

        Ok(())
    }

    pub async fn cleanup_old_records(&self, days: i64) -> Result<usize> {
        let cutoff = Utc::now() - chrono::Duration::days(days);

        // Clean up old transfers
        let transfer_result = sqlx::query("DELETE FROM transfers WHERE start_time < ?")
            .bind(cutoff.to_rfc3339())
            .execute(&self.pool)
            .await?;

        // Clean up old devices
        let device_result = sqlx::query("DELETE FROM devices WHERE last_seen < ?")
            .bind(cutoff.to_rfc3339())
            .execute(&self.pool)
            .await?;

        let total_deleted = transfer_result.rows_affected() + device_result.rows_affected();
        info!("Cleaned up {} old records", total_deleted);

        Ok(total_deleted as usize)
    }

    pub async fn get_transfer_stats(&self) -> Result<TransferStats> {
        // Total transfers
        let total_transfers: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM transfers")
            .fetch_one(&self.pool)
            .await?;

        // Completed transfers
        let completed_transfers: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM transfers WHERE status = 'completed'")
                .fetch_one(&self.pool)
                .await?;

        // Failed transfers
        let failed_transfers: i64 =
            sqlx::query_scalar("SELECT COUNT(*) FROM transfers WHERE status = 'failed'")
                .fetch_one(&self.pool)
                .await?;

        // Total bytes transferred
        let total_bytes: i64 = sqlx::query_scalar(
            "SELECT COALESCE(SUM(size), 0) FROM transfers WHERE status = 'completed'",
        )
        .fetch_one(&self.pool)
        .await?;

        // Average transfer speed
        let avg_speed: Option<f64> = sqlx::query_scalar(
            "SELECT AVG(speed) FROM transfers WHERE speed IS NOT NULL AND status = 'completed'",
        )
        .fetch_one(&self.pool)
        .await?;

        Ok(TransferStats {
            total_transfers: total_transfers as u64,
            completed_transfers: completed_transfers as u64,
            failed_transfers: failed_transfers as u64,
            total_bytes,
            average_speed: avg_speed,
        })
    }

    fn row_to_transfer_record(row: sqlx::sqlite::SqliteRow) -> Result<TransferRecord> {
        Ok(TransferRecord {
            id: Uuid::parse_str(&row.try_get::<String, _>("id")?)?,
            filename: row.try_get("filename")?,
            size: row.try_get::<i64, _>("size")? as u64,
            status: row.try_get("status")?,
            start_time: DateTime::parse_from_rfc3339(&row.try_get::<String, _>("start_time")?)?
                .with_timezone(&Utc),
            end_time: row.try_get::<Option<String>, _>("end_time")?.map(|s| {
                DateTime::parse_from_rfc3339(&s)
                    .unwrap()
                    .with_timezone(&Utc)
            }),
            source_device: row.try_get("source_device")?,
            target_device: row.try_get("target_device")?,
            speed: row.try_get("speed")?,
            error_message: row.try_get("error_message")?,
        })
    }

    fn row_to_device_record(row: sqlx::sqlite::SqliteRow) -> Result<DeviceRecord> {
        Ok(DeviceRecord {
            id: Uuid::parse_str(&row.try_get::<String, _>("id")?)?,
            name: row.try_get("name")?,
            device_type: row.try_get("device_type")?,
            ip_address: row.try_get("ip_address")?,
            port: row.try_get::<i64, _>("port")? as u16,
            api_port: row.try_get::<i64, _>("api_port")? as u16,
            last_seen: DateTime::parse_from_rfc3339(&row.try_get::<String, _>("last_seen")?)?
                .with_timezone(&Utc),
            is_online: row.try_get("is_online")?,
            capabilities: row.try_get("capabilities")?,
            version: row.try_get("version")?,
        })
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransferStats {
    pub total_transfers: u64,
    pub completed_transfers: u64,
    pub failed_transfers: u64,
    pub total_bytes: i64,
    pub average_speed: Option<f64>,
}
