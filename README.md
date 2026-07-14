# Safe Basket — EDC Detection Platform

Safe Basket helps users identify Endocrine Disrupting Chemicals (EDCs) in
everyday products by scanning barcodes and ingredient labels.

> **Disclaimer:** This application is not medical advice. Consult a qualified
> health professional before making any decisions based on information provided
> by this app.

---

## Repository Structure

```
Safe_basket/
├── edc_matcher/               # Pure-Dart package — EDC data models, text matcher, risk classifier
│   └── lib/
│       ├── edc_matcher.dart   # Barrel export
│       └── src/
│           ├── models.dart    # EdcEntry (19 fields), severity as free-form text
│           ├── matcher.dart   # EdcMatcher — alias-based text matching
│           └── classifier.dart# RiskClassifier — worst-severity ranking
│
├── edc_backend/               # Dart Frog REST API
│   ├── main.dart              # Entry point — reads PORT from .env
│   ├── pubspec.yaml
│   ├── .env.example           # Config template — copy to .env and fill in
│   ├── lib/
│   │   ├── config.dart                        # AppConfig.load() via dotenv
│   │   ├── response_envelope.dart             # okResponse() / errorResponse()
│   │   ├── user_id_middleware.dart            # X-User-Id header injection
│   │   ├── middleware/
│   │   │   ├── rate_limiter.dart              # Sliding-window rate limiter
│   │   │   └── structured_logger.dart         # JSON structured logging + MatchDetail
│   │   ├── edc_repository/
│   │   │   ├── edc_repository.dart            # findAll/findById/insert/update/insertAlias/deleteAlias
│   │   │   └── edc_cache.dart                 # In-process EdcEntry snapshot, prime()/refresh()
│   │   ├── ocr/
│   │   │   ├── ocr_service.dart               # Google Cloud Vision TEXT_DETECTION
│   │   │   └── match_service.dart             # matchAndClassify() — exact vs alias logging
│   │   └── product_resolution/
│   │       ├── product_resolution.dart        # ProductResolution model
│   │       ├── product_resolution_service.dart# resolveBarcode() — waterfall over 3 OFF APIs
│   │       └── cache_store.dart               # CacheStore interface + InMemoryCacheStore (TTL-ready)
│   ├── routes/
│   │   ├── middleware.dart                    # Global: requestLogger + AppConfig + userId
│   │   ├── index.dart                         # GET / — health check
│   │   ├── scan/
│   │   │   ├── middleware.dart                # Provides ProductResolutionService + OcrService
│   │   │   ├── barcode.dart                   # POST /scan/barcode
│   │   │   └── photo.dart                     # POST /scan/photo — OCR + EDC match
│   │   └── admin/
│   │       ├── middleware.dart                # Admin auth gate + EdcRepository + EdcCache
│   │       ├── edc.dart                       # POST /admin/edc
│   │       └── edc/
│   │           ├── [id].dart                  # PUT /admin/edc/:id
│   │           └── [id]/
│   │               ├── aliases.dart           # POST /admin/edc/:id/aliases
│   │               └── aliases/
│   │                   └── [aliasId].dart     # DELETE /admin/edc/:id/aliases/:aliasId
│   ├── db/
│   │   ├── migrations/
│   │   │   ├── 0001_create_edc_tables.sql     # Placeholder (superseded)
│   │   │   └── 0002_recreate_edc_tables.sql   # Current schema
│   │   └── seeds/
│   │       ├── edc_database.json              # 51 real EDC entries
│   │       └── seed_edc.dart                  # One-time idempotent seed script
│   └── test/
│       ├── product_resolution_service_test.dart
│       └── ocr_service_test.dart
│──── gateway/                   # Node/Express auth gateway — sits between Flutter app and edc_backend
│   ├── src/
│   │   ├── index.js           # Entry point — Express app, health check
│   │   ├── routes.js          # All proxied routes, all behind JWT auth
│   │   ├── authMiddleware.js  # Verifies Bearer JWT, sets req.userId
│   │   └── proxy.js           # Forwards to Dart backend, injects X-User-Id, unwraps envelope
│   ├── package.json
│   └── .env.example
│ 
└── edc_database.json          # Authoritative EDC reference data (source of truth)
```

---

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0
- [Dart Frog CLI](https://dartfrog.vgv.dev) — `dart pub global activate dart_frog_cli`
- PostgreSQL >= 14
- `psql` CLI available in PATH
- Node.js >= 18 (for the gateway)

---

## Setup

### 1. Environment config

```bash
cd edc_backend
copy .env.example .env   # Windows
# cp .env.example .env   # macOS/Linux
```

Edit `.env` and fill in real values:

```
DB_CONNECTION_STRING=postgres://user:password@localhost:5432/edc_db
OCR_API_KEY=your_google_cloud_vision_api_key
OCR_API_URL=https://vision.googleapis.com/v1/images:annotate
PORT=8080
# Comma-separated X-User-Id values allowed to call /admin/* routes
# TODO: replace with real role-based auth before production
ADMIN_ALLOWLIST=admin-user-id-1,admin-user-id-2
```

### 2. Install dependencies

```bash
cd edc_backend
dart pub get
```

### 3. Run database migration

```bash
# from edc_backend/
psql $DB_CONNECTION_STRING -f db/migrations/0002_recreate_edc_tables.sql
```

### 4. Seed EDC reference data

```bash
# from edc_backend/
dart run db/seeds/seed_edc.dart
```

The seed script is idempotent — safe to run multiple times.

### 5. Start the dev server

```bash
# from edc_backend/
dart_frog dev
```

Server starts on the port defined in `.env` (default `8080`).

---

### Gateway setup

```bash
cd gateway
cp .env.example .env


## API

All responses are wrapped in a standard envelope:

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
| `POST` | `/scan/barcode` | JWT | Resolve a product barcode via Open Food/Beauty/Products Facts |
| `POST` | `/scan/photo` | JWT | OCR image upload → EDC match + risk assessment |
| `POST` | `/admin/edc` | Admin | Create a new EDC entry |
| `PUT` | `/admin/edc/:id` | Admin | Update any field of an existing entry |
| `POST` | `/admin/edc/:id/aliases` | Admin | Add an alias to an entry |
| `DELETE` | `/admin/edc/:id/aliases/:aliasId` | Admin | Remove an alias by row id |

#### POST /scan/barcode

Request:
```json
{ "barcode": "5000112637922" }
```

Response (`200`):
```json
{
  "data": {
    "barcode": "5000112637922",
    "name": "Product Name",
    "brand": "Brand",
    "image_url": "https://...",
    "ingredients_text": "water, salt, ...",
    "packaging_materials": ["plastic"],
    "source_url": "https://world.openfoodfacts.org/..."
  },
  "disclaimer": "...",
  "error": null
}
```

Error codes: `not_found` (404), `network_error` (502), `invalid_barcode` (400).

#### POST /scan/photo

Accepts `multipart/form-data` with a field named `image`.

Response (`200`):
```json
{
  "data": {
    "request_id": "1717235200123456",
    "raw_text": "Water, Sodium Lauryl Sulfate, Parabens, Fragrance",
    "analysis": {
      "cleaned_text": "Water, Sodium Lauryl Sulfate, Parabens, Fragrance",
      "worst_severity": "Low-Moderate",
      "matches": [
        {
          "id": "methylparaben",
          "name": "Methylparaben",
          "severity": "Low-Moderate",
          "evidence_tier": "Limited",
          "draft_app_output_message": "Weak estrogenic activity detected"
        }
      ]
    }
  },
  "disclaimer": "...",
  "error": null
}
```

Rate limited: 10 requests per user per minute.
Error codes: `ocr_failed` (502), `ocr_no_text` (422), `rate_limited` (429), `missing_image` (400).

#### Admin routes

All admin routes require `X-User-Id` to be in `ADMIN_ALLOWLIST`.

`PUT /admin/edc/:id` — partial update, only fields present in the body are written:
```json
{ "last_reviewed_date": "2024-06-01", "reviewed_by": "shivansh" }
```

`POST /admin/edc/:id/aliases`:
```json
{ "alias": "new-alias-string" }
```

After every write the in-memory `EdcCache` is refreshed so `/scan/photo` immediately sees the updated data.

---

## Authentication

The gateway verifies a `Bearer` JWT in the `Authorization` header on every request. The `sub` (or `userId`/`id`) claim is extracted and forwarded to the Dart backend as `X-User-Id`.

The Dart backend trusts `X-User-Id` as-is — it does not verify JWTs itself. Never expose the Dart backend port directly to clients.

Admin routes return `403 forbidden` if `X-User-Id` is absent or not in `ADMIN_ALLOWLIST`.

---

## Structured Logging

Every `/scan/photo` request emits a JSON log line to stdout:

```json
{
  "timestamp": "2024-06-01T10:00:00.000Z",
  "event": "match_result",
  "request_id": "1717235200123456",
  "token_count": 12,
  "match_count": 2,
  "worst_severity": "High",
  "matched_ratio": "3.9",
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

`match_type` is `exactName` or `alias` — use this to monitor alias coverage over time.
A persistent `match_count: 0` on scans that visually contain known chemicals means aliases need expanding.

---

## Running Tests

```bash
cd edc_backend
dart test
```

---

## EDC Reference Data

The authoritative dataset is `edc_database.json` at the workspace root — 51
entries covering chemicals from BPA and phthalates to heavy metals and
microplastics. Each entry maps directly to the `EdcEntry` model in
`edc_matcher/lib/src/models.dart` and the `edc_entries` Postgres table.

Severity values are free-form text (`High`, `Moderate-High`, `Moderate`,
`Low-Moderate`, `Dose-dependent`, `Low`, `Emerging`, `Acute`, `Non-EDC`) —
not a database enum — because the categories are hedged and compound.

---

## Production Hardening Notes

- Rate limiter is in-process (per-isolate). Move to Redis ZSET for multi-instance correctness — see `lib/middleware/rate_limiter.dart` TODO.
- `CacheStore` interface has a `ttl` parameter ready for Redis. See migration sketch in `lib/product_resolution/cache_store.dart`.
- Vision API and OFF API calls have explicit timeouts (15s and 10s respectively).
- DB connection failures in admin routes return `503 db_unavailable` instead of crashing.
- Admin allowlist is a temporary measure — replace with JWT role claims before production (marked TODO in `lib/config.dart` and `routes/admin/middleware.dart`).
