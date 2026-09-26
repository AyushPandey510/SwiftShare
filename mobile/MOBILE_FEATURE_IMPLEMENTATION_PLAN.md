# SwiftShare Mobile Feature Implementation Plan

This is the living implementation document for making the mobile app fully useful, synced with the web app, and ready for LAN/direct-device sharing. As work is completed, checkboxes should be updated in this file so future sessions can continue without guessing.

## Goal

The mobile app should support all major SwiftShare flows:

- Upload from phone and access on web using the same code/link/QR.
- Upload from web and access/download on phone using the same code/link/QR.
- Keep LAN/direct device discovery and transfer as a local sharing mode.
- Keep QR scanning useful for both shared file links and device connection.
- Add Bluetooth only as a real implemented transport, not a fake UI label.

## Current Reality

### What Already Works Or Mostly Exists

- Web upload/share flow exists in `web-frontend/src/lib/api.ts`.
- Backend already exposes the web-compatible sharing API:
  - `POST /api/upload`
  - `GET /api/file/{code}`
  - `GET /api/download/{code}`
  - `GET /api/qr/{code}`
- Backend also exposes LAN/device-transfer-related routes:
  - `GET /api/devices`
  - `POST /api/transfer`
  - `GET /api/transfer/{id}`
  - `GET /api/transfers`
  - `GET /ws`
- Mobile has Flutter structure, screens, providers, file picker, QR scanner, storage permissions, and LAN device UI.
- Mobile has `DeviceProvider`, `TransferProvider`, and `FileTransferService` for nearby/device-style transfers.

### What Is Broken Or Incomplete

- Mobile and web are not using the same main sharing flow.
  - Web uses `/api/upload` and code-based download.
  - Mobile uses `/api/transfer`, which is a different LAN/device-transfer flow.
- Mobile default backend URL is wrong for the current backend default.
  - Mobile default: `http://192.168.1.100:8080`
  - Backend default: `http://localhost:3001`
- Mobile auto-detection scans common ports like `8080`, `3000`, `8000`, `5000`, but not the backend default `3001`.
- Mobile upload does not currently return or display the web-compatible file code/link/QR.
- Mobile does not have a proper "enter code and download" screen equivalent to the web access page.
- Mobile QR scanner currently treats HTTP QR codes as generic URLs instead of resolving SwiftShare file links/codes.
- Mobile QR display currently uses fake/test device data.
- Devices screen has TODO actions for sending files/folders.
- Some device discovery fallback data is mock data, which can make the app look like it found devices when it did not.
- Bluetooth is not actually implemented.
  - No Bluetooth Flutter dependency is present.
  - Android Bluetooth permissions are missing.
  - No BLE discovery/pairing/transfer service exists.
- Backend uploaded file metadata is mostly in memory.
  - File bytes are stored on disk.
  - Metadata like `downloadCount`, `maxDownloads`, content type, and expiry can reset after backend restart.
- Public web/mobile sync requires both clients to point at the same reachable backend.
  - Local LAN backend works only when phone and web are on the same network.
  - Public web sync needs a public backend URL and persistent storage.

## Target Product Modes

### Mode 1: Share By Code, Link, And QR

This should be the main mobile experience because it matches the web app.

Expected flow:

1. User selects a file on phone.
2. Mobile calls `POST /api/upload`.
3. Backend returns file metadata with `code`, `url`, `qrUrl`, expiry, and download limits.
4. Mobile shows:
   - filename
   - size
   - six-character code
   - download/share link
   - QR code
   - copy/share actions
5. User can open the same code/link on web and download the file.
6. Mobile can also enter/scan a code/link from web and download the file.

### Mode 2: Nearby/LAN Direct Transfer

This can remain as a separate tab or secondary mode.

Expected flow:

1. Mobile discovers backend-visible devices over LAN.
2. User selects a device.
3. User sends a file using `/api/transfer`.
4. Transfer progress/history appears in the Transfers tab.

Important: LAN transfer should not be confused with the web sync flow. It is local-network sharing, not the same as public code/link sharing.

### Mode 3: Bluetooth

Bluetooth should be added only after the web-sync and LAN paths are stable.

Expected flow:

1. Add a real Bluetooth dependency.
2. Add Android/iOS permissions.
3. Scan nearby Bluetooth/BLE devices.
4. Pair/connect.
5. Exchange either:
   - a SwiftShare link/code over Bluetooth, or
   - small files directly over Bluetooth if the chosen library supports it.

Recommended first Bluetooth implementation: exchange SwiftShare codes/links over BLE, because large direct file transfer over BLE is slower and more complex.

## Implementation Checklist

### Phase 0: Documentation And Tracking

- [x] Create this implementation plan.
- [x] Keep this file updated after each meaningful change.
- [x] Add a short completion note under "Progress Log" after each phase.

### Phase 1: Align Mobile Config With Backend

- [x] Change mobile default backend URL to match backend default development port `3001`.
- [x] Update mobile backend auto-detection to scan `3001`.
- [x] Update websocket URL generation to handle both `http://` and `https://`.
- [x] Update visible startup/backend status text that still assumes `192.168.1.100:8080`.
- [x] Make backend URL configurable from Settings and persist it.
- [x] Make "Test Connection" call `/health`, not only raw socket connection.

### Phase 2: Add Shared File API To Mobile

- [x] Add a `SharedFile` model matching `web-frontend/src/types/file.ts`.
- [x] Add a `ShareApiService` or equivalent mobile service for:
  - [x] `POST /api/upload`
  - [x] `GET /api/file/{code}`
  - [x] `GET /api/download/{code}`
  - [x] `GET /api/qr/{code}` or local QR generation from `url`
- [x] Add mobile error handling for:
  - [x] file too large
  - [x] file not found
  - [x] expired file
  - [x] download limit reached
  - [x] backend unavailable
- [x] Make max upload size consistent with web/backend: 250 MB.

### Phase 3: Build Main Mobile Share UI

- [x] Add or replace main Home upload UI with web-equivalent flow:
  - [x] file upload
  - [x] paste text as file
  - [x] max downloads selector, 1 to 10
  - [x] upload loading state
  - [x] upload success result
  - [x] upload failure state
- [x] Show result after upload:
  - [x] file name
  - [x] file size
  - [x] code
  - [x] link
  - [x] QR
  - [x] expiry
  - [x] downloads remaining
- [ ] Add copy/share actions:
  - [x] copy code
  - [x] copy link
  - [ ] system share link
- [x] Keep the UI visually aligned with the web app style.

### Phase 4: Build Mobile Access/Download Flow

- [x] Add an "Access file" screen.
- [x] Allow entering a six-character code.
- [x] Lookup file using `GET /api/file/{code}`.
- [x] Display metadata before download.
- [x] Download file using `GET /api/download/{code}`.
- [x] Save downloaded file into an app-accessible downloads directory.
- [x] Show download success/failure.
- [x] Add this flow to navigation and quick actions.

### Phase 5: Fix QR Behavior

- [x] Update QR scanner to detect SwiftShare file URLs.
- [x] Extract code from URLs like `/api/download/{code}`.
- [x] Extract code from URLs like `/access?code={code}` if used.
- [x] Treat raw six-character text as a file code.
- [x] Navigate scanner results to the Access/Download screen.
- [x] Keep `swiftshare://` device QR handling for LAN mode.
- [ ] Replace fake QR display with either:
  - [x] uploaded file QR after share-by-code upload, or
  - [ ] real device connection QR with actual local device/backend info.

### Phase 6: Make LAN/Nearby Device Flow Realer

- [x] Remove mock device fallback or clearly label it as offline demo data.
- [x] Ensure `/api/devices` returns real useful device data from backend.
- [x] Wire Devices screen "Send File" action to `TransferProvider.pickAndSendFile(device.id)`.
- [x] Wire Home/device bottom sheet send action to real transfer.
- [x] Make `/api/transfer` response and mobile transfer IDs consistent.
- [ ] Show real progress if backend emits it.
- [x] If backend cannot emit progress yet, show deterministic upload progress or completed/failed status honestly.
- [ ] Decide whether folder sharing is supported.
  - [x] If not supported, remove "Send Folder" or keep it disabled with clear copy.
  - [ ] If supported, zip folders before upload/transfer.

### Phase 7: Bluetooth Support

- [ ] Choose Bluetooth approach:
  - [ ] BLE code/link exchange first, recommended.
  - [ ] Direct file transfer later, optional and harder.
- [ ] Add Flutter Bluetooth package.
- [ ] Add Android Bluetooth permissions:
  - [ ] `BLUETOOTH`
  - [ ] `BLUETOOTH_ADMIN`
  - [ ] `BLUETOOTH_SCAN`
  - [ ] `BLUETOOTH_CONNECT`
  - [ ] `ACCESS_FINE_LOCATION` where required for scanning.
- [ ] Add iOS Bluetooth permission descriptions if iOS is targeted.
- [ ] Build Bluetooth scan screen or tab section.
- [ ] Exchange SwiftShare code/link over Bluetooth.
- [ ] Add Bluetooth status/error UI.
- [ ] Test on real Android devices.

### Phase 8: Backend Persistence And Production Sync

- [x] Persist uploaded file metadata in database instead of only in memory.
- [x] Persist:
  - [x] code
  - [x] filename
  - [x] size
  - [x] content type
  - [x] file path or object key
  - [x] uploaded at
  - [x] expires at
  - [x] download count
  - [x] max downloads
- [x] Add cleanup task for expired files.
- [ ] Make storage production-safe:
  - [ ] persistent Render disk, or
  - [ ] S3-compatible object storage.
- [ ] Ensure `PUBLIC_BASE_URL` is correct in production.
- [ ] Ensure web `VITE_API_BASE_URL` points to the same backend.
- [ ] Ensure mobile default/setting points to the same backend for public sync.

### Phase 9: Testing

- [ ] Backend tests:
  - [ ] upload returns file metadata
  - [ ] lookup by code works
  - [ ] download increments download count
  - [ ] expired file cannot be downloaded
  - [ ] max downloads is enforced
- [x] Mobile static analysis:
  - [x] `flutter analyze --no-pub` runs through Snap with permission
  - [x] `flutter analyze --no-pub` reports no issues
- [ ] Mobile unit/widget tests where practical.
- [ ] Manual mobile/web integration tests:
  - [ ] phone upload, web download
  - [ ] web upload, phone download by code
  - [ ] web upload, phone scan QR
  - [ ] phone upload, another phone download
  - [ ] LAN device discovery
  - [ ] LAN direct send
  - [ ] backend unavailable state
  - [ ] wrong code state
  - [ ] expired/download-limit state

## Proposed File Changes

Likely mobile files to add:

- `mobile/lib/models/shared_file.dart`
- `mobile/lib/services/share_api_service.dart`
- `mobile/lib/providers/share_provider.dart`
- `mobile/lib/screens/share_screen.dart`
- `mobile/lib/screens/share_result_screen.dart`
- `mobile/lib/screens/access_file_screen.dart`

Likely mobile files to edit:

- `mobile/lib/config/app_config.dart`
- `mobile/lib/utils/network_utils.dart`
- `mobile/lib/main.dart`
- `mobile/lib/screens/home_screen.dart`
- `mobile/lib/screens/qr_scanner_screen.dart`
- `mobile/lib/screens/qr_display_screen.dart`
- `mobile/lib/screens/devices_screen.dart`
- `mobile/lib/widgets/quick_actions.dart`
- `mobile/lib/providers/transfer_provider.dart`
- `mobile/android/app/src/main/AndroidManifest.xml`
- `mobile/pubspec.yaml`

Likely backend files to edit later:

- `backend/src/main.rs`
- `backend/src/database.rs`
- `backend/src/config.rs`

## Implementation Notes For Future Sessions

- Do not remove LAN/direct-transfer code while adding web sync. Keep it as a separate feature.
- Do not label Bluetooth as working until real Bluetooth scanning/connection code exists.
- Prefer making the web-compatible sharing path the primary mobile UI.
- Keep generated codes and API response shapes compatible with the web frontend.
- Avoid hardcoded IP addresses in final mobile UX.
- Do not rely on mock devices except in an explicitly labeled demo/offline mode.

## Progress Log

### 2026-09-21

- Created this plan after analyzing the existing backend, web frontend, and mobile app.
- Confirmed the web-compatible backend API exists.
- Confirmed mobile currently uses the separate `/api/transfer` flow for uploads.
- Confirmed Bluetooth is not actually implemented yet.
- Implemented Phase 1 config alignment: default backend is now `http://localhost:3001`, auto-detection scans `3001`, websocket URLs support `ws://` and `wss://`, Settings can persist backend URL, and connection tests call `/health`.
- Implemented Phase 2 shared file layer: added `SharedFile`, `ShareApiService`, and `ShareProvider` for upload, lookup, download, QR/link-code extraction, and user-facing errors.
- Implemented most of Phases 3-5: added the main `ShareScreen`, added `AccessFileScreen`, made the first bottom tab the web-compatible Share flow, added file/text upload UI, result QR/link/code UI, code lookup, app-directory download, and QR scanner routing for shared file links/codes.
- Updated the existing LAN `FileTransferService` to use the current `AppConfig` backend URL instead of stale static URL fields.
- Fixed auto-detection so only a confirmed backend URL is persisted, and failed scans restore the original backend URL.
- Enabled Android cleartext HTTP traffic for local/LAN development backends and fixed an existing QR scanner layout issue caused by returning `Positioned` from inside `AnimatedBuilder`.
- Implemented much of Phase 6: removed mock device fallback, added explicit mobile discovery error state, fixed backend discovery probing from `/api/status` to `/status`, added useful backend status metadata, parsed backend device JSON fields correctly on mobile, wired Devices/Home "Send File" to real transfer calls using device id, disabled folder sharing with clear copy, and made completed `/api/transfer` responses mark transfers completed instead of leaving them stuck in progress.
- Verification note: Snap tools can run when permission is requested. `/snap/bin/cargo check` completed successfully for the backend with warnings only.
- Verification note: `/snap/bin/flutter analyze --no-pub` initially completed with 42 info-level lint/deprecation issues, mostly `avoid_print`, `use_build_context_synchronously`, and one QR `foregroundColor` deprecation.
- Implemented most of Phase 8 backend persistence: added an `uploaded_files` SQLite table, save/load/delete/increment methods, DB-backed upload metadata, DB-first lookup/download/QR resolution, persistent download counts, periodic expired file cleanup, and changed the default backend database path from `:memory:` to a real local data file. `/snap/bin/cargo check` passes with warnings only after these changes.

### 2026-09-26

- Cleaned mobile analyzer issues: replaced development `print` logging with `debugPrint`, fixed async `BuildContext` guards in Settings, and replaced deprecated QR `foregroundColor` usage with QR style objects.
- Verification note: `/snap/bin/flutter analyze --no-pub` now reports `No issues found`.
- Confirmed Flutter/Gradle metadata churn was not left in `mobile/pubspec.lock` or `mobile/android/gradle.properties`.
- Remaining incomplete areas are intentionally unchecked: Bluetooth requires adding a real BLE package and testing on physical devices; production sync still needs deployment-specific backend/public URL/object storage configuration; manual phone/web/LAN integration tests still need real devices and a reachable backend.
