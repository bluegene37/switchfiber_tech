# TODOS

## Offline & Storage

### Offload Photo Proofs and Signatures from SQLite to File System

**What:** Save photo proofs and signatures as `.jpg` / `.png` files in `path_provider` application documents directory and store local file paths in SQLite instead of raw base64 data URLs.

**Why:** Storing 7 uncompressed base64 images per record causes single SQLite rows to exceed 9MB (duplicated in `rawJson`), risking `CursorWindowAllocationException` and high memory overhead in `watchAllJobs()`.

**Context:** Discovered during `/plan-eng-review` on `feature/toolkit-lcp-nap`. Photo proofs are currently compressed to 1600px JPEG and stored as data URLs in `JobOrders` table. Offloading to files keeps SQLite queries lightweight and fast.

**Effort:** M
**Priority:** P1
**Depends on:** None

### Drift SQLite Offline Persistence for Service Orders (Repairs)

**What:** Implement a `ServiceOrders` Drift SQLite table, DAO, and offline `SyncWorker` for the Repairs tab.

**Why:** Service Orders are currently in-memory only. Technicians working in dead zones cannot view repair orders or submit repairs offline.

**Context:** Discovered during `/plan-eng-review` on `feature/toolkit-lcp-nap`. Job Orders have full offline capabilities; Service Orders should be brought to parity for reliable field operations.

**Effort:** L
**Priority:** P1
**Depends on:** None
