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
│   │   ├── edc_repository/
│   │   │   └── edc_repository.dart            # findAll() / findById() over Postgres
│   │   └── product_resolution/
│   │       ├── product_resolution.dart        # ProductResolution model
│   │       ├── product_resolution_service.dart# resolveBarcode() — waterfall over 3 OFF APIs
│   │       └── cache_store.dart               # CacheStore interface + InMemoryCacheStore
│   ├── routes/
│   │   ├── middleware.dart                    # Global: requestLogger + AppConfig + userId
│   │   ├── index.dart                         # GET / — health check
│   │   └── scan/
│   │       ├── middleware.dart                # Provides ProductResolutionService
│   │       └── barcode.dart                   # POST /scan/barcode
│   ├── db/
│   │   ├── migrations/
│   │   │   ├── 0001_create_edc_tables.sql     # Placeholder (superseded)
│   │   │   └── 0002_recreate_edc_tables.sql   # Current schema
│   │   └── seeds/
│   │       ├── edc_database.json              # 51 real EDC entries
│   │       └── seed_edc.dart                  # One-time idempotent seed script
│   └── test/
│       └── product_resolution_service_test.dart
│
└── edc_database.json          # Authoritative EDC reference data (source of truth)
```

---

## Prerequisites

- [Dart SDK](https://dart.dev/get-dart) >= 3.0.0
- [Dart Frog CLI](https://dartfrog.vgv.dev) — `dart pub global activate dart_frog_cli`
- PostgreSQL >= 14
- `psql` CLI available in PATH

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
OCR_API_KEY=your_ocr_api_key
OCR_API_URL=https://api.ocr-provider.example.com/v1
PORT=8080
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

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/` | Health check |
| `POST` | `/scan/barcode` | Resolve a product barcode |

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
  "disclaimer": "This is not medical advice...",
  "error": null
}
```

Error codes: `not_found` (404), `network_error` (502), `invalid_barcode` (400).

---

## Authentication

Routes that require a user read the `X-User-Id` header, which is expected to
be injected by an upstream auth gateway. Routes that don't need a user ignore
the header — there is no global rejection.

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
