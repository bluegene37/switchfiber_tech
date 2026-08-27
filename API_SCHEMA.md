# Switch Fiber - API & Technical Schema Specification

This document provides the extracted API endpoints, payload schemas, authentication workflows, on-site technical completion reporting requirements, and design tokens based on the **Switch Fiber** system (`switchfiber`).

---

## 1. Brand Identity & Design Tokens

### Company Identity
- **Company / Brand Name:** Switch Fiber
- **Tagline:** Distributed Fiber Network Management / Field Operations
- **Logo Asset:** Located at `assets/images/logo.png` (Spherical geometric globe with fiber arcs).

### Color Palette (Hex & RGB)
| Token | Hex Code | RGB | Usage |
|---|---|---|---|
| **Primary (Warm Rose Red)** | `#E74C5A` | `rgb(231, 76, 90)` | Primary buttons, active tabs, brand accents, focus rings |
| **Primary Hover / Dark** | `#D63A48` | `rgb(214, 58, 72)` | Button press states, dark borders |
| **Primary Active** | `#C02E3C` | `rgb(192, 46, 60)` | Deep active states, emphasis badges |
| **Primary Subtle Background**| `#FEF2F3` | `rgb(254, 242, 243)` | Light badge backgrounds, selected row highlights |
| **Primary Subtle Border** | `#FDCFD3` | `rgb(253, 207, 211)` | Chip outlines, light input borders |
| **Dark Surface / Slate** | `#212529` | `rgb(33, 37, 41)` | Main dark text, dark mode body background |
| **Dark Slate Elevated** | `#2B3035` | `rgb(43, 48, 53)` | Dark mode cards and sheet modals |
| **Success (Green)** | `#10B981` | `rgb(16, 185, 129)` | Activated/Completed status, good optical power readings |
| **Warning (Amber)** | `#F59E0B` | `rgb(245, 158, 11)` | In-progress jobs, marginal optical power (-25 to -27 dBm) |
| **Danger (Red)** | `#EF4444` | `rgb(239, 68, 68)` | Failed/Cancelled jobs, optical power out of spec (<-27 dBm) |
| **Info (Sky Blue)** | `#0EA5E9` | `rgb(14, 165, 233)` | Pending jobs, network information cards |
| **Background (Light)** | `#F8F9FA` | `rgb(248, 249, 250)` | App screen background |

---

## 2. Authentication & Session Management

### Base URL Configuration
- **Production Base URL:** `https://api.switchfiber.ph/api`
- **Development/Proxy:** `/api` (configurable in mobile settings)
- **Timeout:** 60,000 ms (60 seconds)

### 2.1 Technician Login
- **Endpoint:** `POST /api/Users/login`
- **Headers:**
  - `Content-Type: application/json`
  - `Accept: application/json`

#### Request Payload:
```json
{
  "username": "tech_username_or_email",
  "password": "password123"
}
```

#### Successful Response (`200 OK`):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 104,
    "username": "tech_marcos",
    "fname": "Marcos",
    "lname": "Dela Cruz",
    "email": "marcos.tech@switchfiber.ph",
    "accesslevel_id": 2,
    "active": true,
    "menus": [
      "JobOrders",
      "LcpNapLocations"
    ]
  }
}
```

#### Token Storage & Session Rules:
1. **Bearer Token:** Requests must include `Authorization: Bearer <token>` header.
2. **Mobile Secure Storage:** Token is stored using `flutter_secure_storage` under the key `jwt_token`.
3. **User Profile:** Stored as serialized JSON under the key `user_profile`.
4. **401 Unauthorized:** If the backend responds with `401 Unauthorized`, clear stored credentials and route to the login screen.

### 2.2 Password Reset
- **Endpoint:** `POST /api/Auth/request-password-reset`
- **Payload:**
  ```json
  {
    "email": "technician@switchfiber.ph"
  }
  ```

---

### 2.3 Google Sign-In

- **Endpoint:** `POST /api/Auth/google`
- **Request:** `{ "idToken": "<Google OpenID Connect ID token>" }`
- **Success:** `200` with a body **byte-identical** to `POST /api/Users/login`
  (`{ "token": ..., "user": { ... } }`). The client shares one parser between
  both endpoints, so any divergence breaks Google sign-in.

The server MUST perform all of the following before issuing a token:

1. Verify the RS256 signature against Google's JWKS
   (`https://www.googleapis.com/oauth2/v3/certs`), cached per `Cache-Control`.
2. `iss` is `accounts.google.com` or `https://accounts.google.com`.
3. `aud` is one of our own OAuth client IDs (the Web client ID the app passes as
   `serverClientId`). This is what prevents replay of a token minted for a
   different application.
4. `exp` is in the future.
5. `email_verified` is `true`.
6. Match `Users.email` case-insensitively, trimmed.

Then:

| Condition | Response |
|---|---|
| No matching `Users` row | `403` `{"code": "ACCOUNT_NOT_PROVISIONED"}` |
| Row exists but `active` is false | `403` `{"code": "ACCOUNT_INACTIVE"}` |
| Row has no `google_sub` | store the token's `sub`, return `200` |
| Row's `google_sub` matches the token's `sub` | return `200` |
| Row's `google_sub` differs | `403` `{"code": "ACCOUNT_MISMATCH"}` |

Error bodies are `{ "message": <human readable>, "code": <CODE> }`. The client
keys its copy on `code` and falls back to `message` for unknown codes.

Requires a new nullable `Users.google_sub` column with a unique index. The
endpoint accepts any verified Google account: there is no domain restriction, so
the accuracy of `Users.email` is what secures a first sign-in.

## 3. Job Orders Specification

### 3.1 List Job Orders
- **Endpoint:** `GET /api/JobOrders`
- **Filtered by Status:** `GET /api/JobOrders/status/{status}`
  - Example: `GET /api/JobOrders/status/inprogress`
- **Query Parameters (Optional):**
  - `fromDate`: `YYYY-MM-DD`
  - `toDate`: `YYYY-MM-DD`
  - `search`: Subscriber name, ticket #, or barangay

#### Response Item Schema (`JobOrderDto`):
| Field | Type | Description |
|---|---|---|
| `id` | integer | Unique job order primary key |
| `accountNo` | string | Subscriber account number |
| `firstName` | string | Customer first name |
| `middleInitial` | string | Customer middle initial |
| `lastName` | string | Customer last name |
| `contactNumber` | string | Customer primary contact |
| `secondContactNumber` | string | Alternate contact |
| `applicantEmailAddress` | string | Customer email |
| `address` | string | Street address |
| `barangay` | string | Barangay name |
| `city` | string | City / Municipality |
| `region` | string | Region |
| `addressCoordinates` | string | GPS coordinates (e.g. `"14.5995, 120.9842"`) |
| `installationLandmark` | string | Physical landmark |
| `planId` | integer | Subscribed Plan ID |
| `status` | string | Status: `pending`, `inprogress`, `completed`, `activated` |
| `onsiteStatus` | string | Field status (`Dispatched`, `In-Progress`, `Completed`, `Failed`) |
| `onsiteRemarks` | string | Technician on-site notes |
| `modemRouterSN` | string | ONT/Router Serial Number |
| `routerModel` | string | Router make/model (e.g., `"Huawei EG8145V5"`) |
| `ip` | string | Assigned Static/CGNAT IP |
| `lcpId` | integer | Local Convergence Point ID |
| `napId` | integer | Network Access Point ID |
| `portId` | string | Port number in NAP |
| `vlanId` | integer | VLAN assignment |
| `dateInstalled` | string | ISO timestamp of installation |
| `startTimeStamp` | string | Work start time |
| `endTimeStamp` | string | Work completion time |
| `duration` | string | Work duration (e.g., `"1h 45m"`) |
| `boxReadingImage` | string | Optical power reading photo at NAP box (URL / Base64) |
| `routerReadingImage` | string | Optical power reading photo at subscriber ONT (URL / Base64) |
| `setupImage` | string | Installed setup photo |
| `speedtestImage` | string | Speedtest screenshot |
| `portLabelImage` | string | Photo of labeled NAP port |
| `clientSignature` | string | Customer electronic signature (Data URL / Base64) |
| `signedContractImage` | string | Signed service contract photo |
| `itemName1`..`itemName10` | string | Material item names (Drop cable, connectors, fasteners) |
| `itemQuantity1`..`itemQuantity10` | string | Quantity of each material used |

---

## 4. Field Technician On-Site Completion Report

### 4.1 Update / Complete Job Order
- **Endpoint:** `PUT /api/JobOrders/{id}`
- **Content-Type:** `application/json`

#### Payload for Completion:
```json
{
  "id": 482,
  "status": "completed",
  "onsiteStatus": "Completed",
  "onsiteRemarks": "Fiber link calibrated. Power at NAP -18.2 dBm, at ONT -19.4 dBm. Speedtest verified 100Mbps symmetrical.",
  "modemRouterSN": "HWTC12345678",
  "routerModel": "EG8145V5",
  "ip": "100.64.12.84",
  "lcpId": 3,
  "napId": 12,
  "portId": "Port 4",
  "vlanId": 100,
  "dateInstalled": "2026-08-24T14:30:00Z",
  "startTimeStamp": "2026-08-24T13:00:00Z",
  "endTimeStamp": "2026-08-24T14:30:00Z",
  "duration": "1h 30m",
  "boxReadingImage": "data:image/jpeg;base64,...",
  "routerReadingImage": "data:image/jpeg;base64,...",
  "setupImage": "data:image/jpeg;base64,...",
  "speedtestImage": "data:image/jpeg;base64,...",
  "portLabelImage": "data:image/jpeg;base64,...",
  "clientSignature": "data:image/png;base64,...",
  "itemName1": "Drop Cable (Meters)",
  "itemQuantity1": "65",
  "itemName2": "SC/APC Fast Connectors",
  "itemQuantity2": "2",
  "itemName3": "Fiber Wall Plate",
  "itemQuantity3": "1"
}
```

### 4.2 Optical Power dBm Thresholds (GPON Standard)
The mobile app performs validation on the optical power meter input:
- **Optimal / Good (Green):** `-12.0 dBm` to `-24.0 dBm`
- **Marginal / Acceptable (Amber):** `-24.1 dBm` to `-27.0 dBm`
- **Out of Spec / Danger (Red):** `< -27.0 dBm` (High attenuation / dirty connector) or `> -8.0 dBm` (Receiver saturation)

---

## 5. Offline Sync & Conflict Resolution
1. **Local Writes First:** When a technician updates a Job Order or submits a Completion Report offline, the Drift database updates immediately with `isSynced = 0` and records the pending action in the local sync queue.
2. **Reactive UI:** Signals update instantly from the Drift reactive stream (`watchAllJobs()`).
3. **Background Sync:** The Sync Worker monitors network connectivity. When connection is established:
   - Queries all rows with `isSynced == 0`.
   - Sends `PUT /api/JobOrders/{id}` sequentially.
   - Upon `200 OK`, updates `isSynced = 1` and `lastSyncedAt = DateTime.now()`.
