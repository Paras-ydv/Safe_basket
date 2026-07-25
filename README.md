# Safe Basket — EDC Detection Platform

Safe Basket helps users identify Endocrine Disrupting Chemicals (EDCs) in
everyday products by scanning barcodes, ingredient labels, and free-text queries.

> **Disclaimer:** This application is not medical advice. Consult a qualified
> health professional before making any decisions based on information provided
> by this app.

---

## Repository Structure

```
Safe_basket/
├── edc_matcher/               # Pure-Dart package — EDC models, text matcher, risk classifier
│   └── lib/src/
│       ├── models.dart        # EdcEntry (19 fields)
│       ├── matcher.dart       # Alias-based text matching
│       └── classifier.dart    # Worst-severity ranking
│
├── edc_contracts/             # Shared wire DTOs + normalizeSeverity() — used by backend and frontend
│   └── lib/src/
│       ├── scan_result.dart
│       ├── detected_chemical.dart
│       ├── chemical_detail.dart
│       ├── alternative.dart
│       ├── app_notification.dart
│       ├── scan_job_status.dart
│       └── risk_level.dart    # 4-level enum: low · moderate · high · very_high
│
├── edc_backend/               # Dart Frog REST API (port 8080)
│   ├── main.dart
│   ├── .env.example
│   ├── lib/
│   │   ├── config.dart                         # AppConfig.load() via dotenv
│   │   ├── response_envelope.dart              # okResponse() / errorResponse()
│   │   ├── contracts_mapper.dart               # EdcEntry → contracts DTOs
│   │   ├── scan_store.dart                     # In-memory scanId → result map
│   │   ├── user_id_middleware.dart
│   │   ├── middleware/
│   │   │   ├── rate_limiter.dart
│   │   │   └── structured_logger.dart          # JSON match-event logging
│   │   ├── edc_repository/
│   │   │   ├── edc_repository.dart             # findAll/findById/insert/update/insertAlias/deleteAlias
│   │   │   └── edc_cache.dart                  # In-process EdcEntry snapshot, prime()/refresh()
│   │   ├── ocr/
│   │   │   ├── ocr_service.dart
│   │   │   └── match_service.dart              # matchAndClassify() — exact vs alias logging
│   │   └── product_resolution/
│   │       ├── product_resolution_service.dart # resolveBarcode() — waterfall over Open*Facts APIs
│   │       └── cache_store.dart
│   └── routes/
│       ├── _middleware.dart                    # Global: CORS + requestLogger + AppConfig + userId
│       ├── index.dart                          # GET /
│       ├── history.dart                        # GET /history
│       ├── scan/
│       │   ├── _middleware.dart                # Provides OcrService + EdcCache (primed from DB)
│       │   ├── manual.dart                     # POST /scan/manual
│       │   ├── barcode.dart                    # POST /scan/barcode
│       │   ├── water.dart                      # POST /scan/water
│       │   ├── [scanId].dart                   # GET /scan/:scanId
│       │   └── image/
│       │       ├── index.dart                  # POST /scan/image
│       │       └── [jobId].dart                # GET /scan/image/:jobId
│       ├── chemicals/
│       │   ├── _middleware.dart                # Provides EdcCache (primed from DB)
│       │   └── [id]/
│       │       ├── index.dart                  # GET /chemicals/:id
│       │       └── alternatives.dart           # GET /chemicals/:id/alternatives
│       └── admin/
│           ├── _middleware.dart                # Admin auth + EdcRepository + EdcCache
│           └── edc/
│               ├── index.dart                  # POST /admin/edc
│               └── [id]/
│                   ├── index.dart              # PUT /admin/edc/:id
│                   └── aliases/
│                       ├── index.dart          # POST /admin/edc/:id/aliases
│                       └── [aliasId].dart      # DELETE /admin/edc/:id/aliases/:aliasId
│
└── edc_frontend/              # Flutter app (Riverpod + GoRouter + Dio)
    └── lib/
        ├── core/
        │   ├── models/        # ScanResult, DetectedChemical (freezed, fromJson)
        │   ├── enums/         # RiskLevel
        │   ├── network/       # ApiConfig, DioProvider, EnvelopeInterceptor
        │   └── router/        # GoRouter config + RouteNames
        └── features/
            ├── scan/          # Manual, barcode, water, image capture + result screen
            ├── chemical/      # Chemical detail + alternatives screens
            ├── history/       # Scan history
            └── notifications/ # In-app notification inbox
```

---

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0
- [Flutter SDK](https://flutter.dev/docs/get-started/install) >= 3.0.0
- [Dart Frog CLI](https://dartfrog.vgv.dev) — `dart pub global activate dart_frog_cli`
- PostgreSQL >= 14
- `psql` CLI available in PATH

---

## Backend Setup

### 1. Environment config

```bash
cd edc_backend
cp .env.example .env
```

Edit `.env`:

```
DB_CONNECTION_STRING=postgres://user:password@localhost:5432/edc_db
OCR_API_KEY=your_google_cloud_vision_api_key
OCR_API_URL=https://vision.googleapis.com/v1/images:annotate
PORT=8080
ADMIN_ALLOWLIST=admin-user-id-1,admin-user-id-2
```

### 2. Install dependencies

```bash
cd edc_backend && dart pub get
```

### 3. Run database migration

```bash
psql $DB_CONNECTION_STRING -f db/migrations/0002_recreate_edc_tables.sql
```

### 4. Seed EDC reference data

```bash
dart run db/seeds/seed_edc.dart
```

Idempotent — safe to run multiple times. Seeds 51 EDC entries.

### 5. Start the dev server

```bash
dart_frog dev
```

Server starts on port `8080` (or `PORT` from `.env`).

To kill the port if needed:
```bash
lsof -ti:8080 | xargs kill -9
```

---

## Frontend Setup

```bash
cd edc_frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

For offline/dev work with fake data:
```bash
flutter run --dart-define=USE_FAKES=true
```

---

## API

All responses use a standard envelope:

```json
{ "data": <payload>, "disclaimer": "This is not medical advice...", "error": null }
```

Errors:
```json
{ "data": null, "disclaimer": null, "error": { "code": "...", "message": "..." } }
```

### Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/` | None | Health check |
| `POST` | `/scan/manual` | None | Free-text EDC lookup |
| `POST` | `/scan/barcode` | None | Barcode → product → EDC match |
| `POST` | `/scan/water` | None | Water source EDC check |
| `POST` | `/scan/image` | None | Async image OCR → EDC match (enqueue) |
| `GET` | `/scan/image/:jobId` | None | Poll async OCR job status |
| `GET` | `/scan/:scanId` | None | Fetch a stored scan result |
| `GET` | `/history` | User | This user's scan history |
| `GET` | `/chemicals/:id` | None | Full chemical detail |
| `GET` | `/chemicals/:id/alternatives` | None | Safer alternatives (lower-risk entries) |
| `POST` | `/admin/edc` | Admin | Create EDC entry |
| `PUT` | `/admin/edc/:id` | Admin | Update EDC entry fields |
| `POST` | `/admin/edc/:id/aliases` | Admin | Add alias to entry |
| `DELETE` | `/admin/edc/:id/aliases/:aliasId` | Admin | Remove alias |

#### POST /scan/manual

```json
{ "query": "BPA" }
```

Response:
```json
{
  "data": {
    "scan_id": "manual-178668473",
    "product_name": "BPA",
    "scanned_at": "2026-07-25T16:03:12.380Z",
    "overall_risk": "high",
    "detected_chemicals": [
      {
        "id": "bpa",
        "name": "Bisphenol A",
        "risk": "high",
        "severity": "High",
        "evidence_tier": "Strong",
        "message": "High EDC risk — estrogenic chemical detected"
      }
    ],
    "disclaimer": null
  }
}
```

#### GET /chemicals/:id

```json
{
  "data": {
    "id": "methylparaben",
    "name": "Methylparaben",
    "risk": "moderate",
    "chemical_class": "Paraben",
    "regulatory_status": "...",
    "health_effects": ["Weak estrogenic activity"],
    "exposure_routes": []
  }
}
```

#### GET /chemicals/:id/alternatives

Returns up to 5 entries with strictly lower risk than the requested chemical.

```json
{
  "data": [
    { "id": "bht", "name": "Butylated Hydroxytoluene", "risk": "low", "note": "..." }
  ]
}
```

#### Admin routes

All admin routes require `X-User-Id` in `ADMIN_ALLOWLIST`, returning `403` otherwise.

`POST /admin/edc/:id/aliases`:
```json
{ "alias": "new-alias-string" }
```

After every write, `EdcCache` is refreshed so scan routes immediately see updated data.

---

## Authentication

Routes read the `X-User-Id` header injected by an upstream auth gateway.
Admin routes return `403 forbidden` if the header is absent or not in `ADMIN_ALLOWLIST`.

> TODO: Replace allowlist check with JWT role claims before production.

---

## Structured Logging

Every scan request emits a JSON log line to stdout:

```json
{
  "timestamp": "2026-07-25T16:03:12.000Z",
  "event": "match_result",
  "request_id": "-",
  "token_count": 1,
  "match_count": 1,
  "worst_severity": "High",
  "matched_ratio": "2.0",
  "matches": [
    {
      "id": "bpa",
      "name": "Bisphenol A",
      "match_type": "alias",
      "matched_token": "bpa",
      "severity": "High",
      "evidence_tier": "Strong"
    }
  ]
}
```

`match_type` is `exactName` or `alias`. Persistent `match_count: 0` on known chemicals means aliases need expanding via `POST /admin/edc/:id/aliases`.

---

## Running Tests

```bash
cd edc_backend && dart test
```

---

## EDC Reference Data

51 entries in `edc_database.json` covering BPA, phthalates, parabens, heavy metals, microplastics and more. Each entry maps to `EdcEntry` in `edc_matcher` and the `edc_entries` Postgres table.

Severity values (`High`, `Moderate-High`, `Moderate`, `Low-Moderate`, `Dose-dependent`, `Low`, `Emerging`, `Acute`, `Non-EDC`) are normalized to the 4-level wire enum by `normalizeSeverity()` in `edc_contracts`.

---

## Known Gaps / To Do

- [ ] **Notifications** — no `notifications` table yet. Needs schema + generation logic (e.g. triggered on high-risk scan).
- [ ] **Chemical exposure routes** — `EdcEntry` doesn't model dermal/ingestion/inhalation. `/chemicals/:id` returns `[]` for now.
- [ ] **Alternatives data** — currently derived from lower-severity entries in the same DB. A curated `safer_alternatives` field or join table would give better results.
- [ ] **Scan persistence** — `scanResultStore` is in-memory; restarting the server clears it. Needs a `scans` DB table for `/scan/:scanId` and `/history` to work reliably.
- [ ] **Rate limiter** — currently in-process (per-isolate). Move to Redis for multi-instance correctness.
- [ ] **Auth** — `X-User-Id` device ID today. Replace with JWT / Google Sign-In when identity lands.
