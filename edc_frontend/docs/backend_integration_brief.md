# Safe_basket ⇄ EDC client — backend integration brief

**To:** Safe_basket backend team · **From:** EDC Flutter client team
**Status:** the Flutter client is contract-ready and already calls every endpoint below. It
binds real Dio repos by default (fake fallback via `--dart-define=USE_FAKES=true`). This brief
is everything the backend needs to deliver/confirm so the two halves connect end-to-end.

---

## 0. Conventions the client already assumes (please build to match)

1. **Response envelope** — every response is `{ "data": <payload>, "disclaimer": <string|null>,
   "error": <null | {"code","message"}> }`. You already do this (`response_envelope.dart`) — keep it.
2. **JSON is snake_case** — `scan_id`, `overall_risk`, `received_at`, etc.
3. **Normalized risk is server-side.** Every scan payload must include a `risk` /
   `overall_risk` field using the client's 4-value enum wire values: **`low` · `moderate` ·
   `high` · `very_high`**. Do **not** send the raw `severity` string as the risk field — map
   it. Use the shared package (below); keep the raw `severity` + `evidence_tier` as extra
   fields for display.
4. **Auth** — identify the caller by the existing **`X-User-Id`** header. The client sends a
   stable per-install device id today; it becomes the signed-in account id when Google
   Sign-In lands (JWT can be added then).

## 1. Use the shared contract package

We added a pure-Dart package **`edc_contracts`** at `Safe_basket/edc_contracts` (path-depended
by `edc_backend` already). It holds the exact wire DTOs (`ScanResult`, `DetectedChemical`,
`ChemicalDetail`, `Alternative`, `AppNotification`, `ScanJobStatus`) and the **single
normalization function** `normalizeSeverity(severity) -> RiskLevel`. **Serialize responses via
these `toJson()` methods** so both sides never drift. Mapper helpers from `EdcEntry` →
contracts already exist in `edc_backend/lib/contracts_mapper.dart`.

Severity → risk mapping (already implemented in `edc_contracts`; listed so you can sanity-check
/ tune): `Non-EDC, Emerging, Low → low` · `Low-Moderate, Dose-dependent, Moderate → moderate`
· `Moderate-High, High → high` · `Acute → very_high` · unknown/null → `moderate`.

## 2. Endpoints the client calls

Payloads shown are the **`data`** field (inside the envelope). ✅ = done, 🔨 = please build.

### ✅ Already aligned — please confirm shapes
- **`POST /scan/barcode`** — body `{ "barcode": "..." }` → `data: ScanResult`. (Now resolves
  the product **and** runs the matcher over its ingredients; returns risk, not just product
  info.)
- **`POST /scan/manual`** — body `{ "query": "..." }` → `data: ScanResult`.

### 🔨 To build
- **`POST /scan/image`** (async wrapper over your synchronous `/scan/photo`) —
  `multipart/form-data` field **`image`** → `data: { "job_id": "..." }`. Enqueue a job, run
  OCR+match in the background, persist the result.
- **`GET /scan/image/{jobId}`** → `data: { "status": "pending" | "done" | "failed",
  "result": ScanResult (when done), "error": string (when failed) }`.
- **`GET /scan/{scanId}`** → `data: ScanResult` (fetch a stored scan).
- **`GET /history`** (`X-User-Id`) → `data: [ ScanResult ]` (this user's scans, newest first).
- **`POST /scan/water`** — body `{ "source_type": "...", "location": "..." }` →
  `data: ScanResult` (environmental; derive from `EdcEntry` water fields —
  `reference_range`/`guideline_value`/`guideline_authority`).
- **`GET /chemicals/{id}`** → `data: ChemicalDetail` (public read of an `EdcEntry`).
- **`GET /chemicals/{id}/alternatives`** → `data: [ Alternative ]`.
- **`GET /notifications`** (`X-User-Id`) → `data: [ AppNotification ]`.

### DTO shapes (snake_case JSON)
```jsonc
// ScanResult
{ "scan_id","product_name","scanned_at" (ISO-8601 UTC),
  "overall_risk": "low|moderate|high|very_high",
  "product_meta": string|null,
  "detected_chemicals": [ DetectedChemical ], "disclaimer": string|null }
// DetectedChemical
{ "id","name","risk","severity"?,"evidence_tier"?,"message"? }   // message = draft_app_output_message
// ChemicalDetail
{ "id","name","risk","chemical_class","regulatory_status",
  "health_effects": [string], "exposure_routes": ["dermal"|"ingestion"|"inhalation"] }
// Alternative
{ "id","name","risk","note"? }
// AppNotification
{ "id","title","body","received_at","risk": <risk>|null, "read": bool }
```

## 3. Suggested build order (cheapest wins first)
1. Confirm/adjust the two done routes (barcode-risk, `/scan/manual`).
2. Async job wrapper + persistence: `scan_jobs` + `scans` tables → unlocks `/scan/image`,
   the poll route, `/scan/{id}`, and `/history` together.
3. `/chemicals/{id}` (map `EdcEntry` → `ChemicalDetail`).
4. `/scan/water` (reuse existing `EdcEntry` water data).
5. `/chemicals/{id}/alternatives` and `/notifications` (need data — see §5).

## 4. Blockers to clear first
- `dart analyze` currently reports **pre-existing errors** (package-version drift, not from
  our changes): `routes/scan/photo.dart:53` (`Stream<List<int>>` vs `List<int>`) and
  `routes/admin/middleware.dart:23` (`Undefined class 'Connection'`). These block
  `dart_frog dev`. Please fix (pin/upgrade `postgres`/`dart_frog`, adjust the multipart read).
- `edc_backend/pubspec.yaml` needs `publish_to: none` (it has path deps) to silence the
  analysis warnings.

## 5. Data / modelling gaps (need product input, not just code)
- **Alternatives** — `EdcEntry` has no "safer alternative" data. Either add a curated field to
  the dataset or derive (e.g. lower-severity entries sharing `common_sources`). Confirm the
  approach.
- **Notifications** — no table/data yet. Needs a `notifications` table + how alerts are
  generated (high-risk scan? recalls?).
- **Chemical detail `exposure_routes`** — `EdcEntry` doesn't model dermal/ingestion/inhalation.
  Send `[]` for now, or add the field. Confirm.

## 6. Please confirm back
- OCR job polling params (expected duration, TTL / max attempts), and whether you'd prefer a
  webhook/push later instead of polling.
- Water-check semantics (what `source_type`/`location` should key off in the dataset).
- Whether normalization should stay client-4-level or you want to expose the full 9-value
  severity to the UI as well (we already pass `severity` through for display).
- Auth timeline: when to move from `X-User-Id` (device id) to real JWT/Google identity.
