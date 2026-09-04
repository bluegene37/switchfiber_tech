# TODOS

## Completed Tasks

### [COMPLETED] Offload Photo Proofs and Signatures from SQLite to File System
- **What:** Save photo proofs and signatures as `.jpg` / `.png` files in `path_provider` application documents directory and store local file paths in SQLite instead of raw base64 data URLs.
- **Why:** Storing 7 uncompressed base64 images per record causes single SQLite rows to exceed 9MB (duplicated in `rawJson`), risking `CursorWindowAllocationException` and high memory overhead in `watchAllJobs()`.
- **Status:** **Completed** via `PhotoStorageService`. SQLite stores discrete file paths (`/photos/id_...jpg` / `.png`) with fallback support, synchronous binary resolution for UI widgets (`resolveBytes`), and on-demand data URL reconstruction for API payloads (`resolveToDataUrl`, `toApiJsonAsync()`).

### [COMPLETED] Drift SQLite Offline Persistence for Service Orders (Repairs)
- **What:** Implement a `ServiceOrders` Drift SQLite table, DAO, and offline `SyncWorker` for the Repairs tab.
- **Why:** Service Orders were previously in-memory only. Technicians working in dead zones could not view repair orders or submit repairs offline.
- **Status:** **Completed** via `ServiceOrders` Drift table (schema v7), `ServiceOrdersDao`, `ServiceOrdersSyncWorker`, and full offline-first reactive binding in `ServiceOrdersSignals`.
