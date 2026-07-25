# EDC Scanning App — Flutter Client Architecture & Boundaries

> **Scope of this document:** the **Flutter mobile app only**. It defines what *our* team
> builds, the strict line where our responsibility ends and another team's begins, the
> contract across that line, the internal architecture of the app, and detailed specs for
> the required screens.
>
> Source: `context/EDC_App_Original.md` (transcribed from `EDC App.docx`) and the two
> embedded architecture diagrams.

---

## 1. The core principle: the app is a thin client

The original system diagram describes **5–7 layers** (Input → Processing → Knowledge Base →
Risk Engine → Output → Lab Validation → Feedback Loop). **Almost none of that is Flutter
work.** OCR, NLP chemical extraction, the EDC knowledge base, the risk-scoring engine, the
lab workflow, and the ML feedback loop are server / data-science / laboratory concerns.

**Our rule of thumb — a task is OURS only if it is _just_ Flutter:**

> If it needs a model to be trained, a database to be queried, a chemistry rule to be
> evaluated, or a lab to be involved — it is **not ours**. We capture the input, hand it to
> the backend, and render whatever the backend returns.

The app **never** classifies a chemical, computes a risk score, or decides severity. It
**displays** decisions the backend already made. This keeps medical/scientific logic out of
the client (also required by CLAUDE.md: *"No business logic in widgets"* — here extended to
*"no scientific logic in the client at all"*).

---

## 2. Strict ownership boundary

### 2.1 OURS (Flutter team)

| Area | What we own |
|---|---|
| **Capture** | Camera/barcode UI, image capture of labels, manual entry forms, water-source/location input |
| **On-device pre-checks** | Barcode symbology decode (via plugin), image cropping/compression, basic input validation — *format only, never meaning* |
| **API integration** | Calling backend endpoints, auth token handling, ret/timeout/error mapping (Dio interceptors) |
| **Presentation** | All screens, navigation, risk color-coding, charts/trends, empty/loading/error states |
| **Local persistence** | Scan history cache, offline queue of pending scans, user profile/preferences on device |
| **Client UX** | Alerts/notifications display, share/export of a report the backend produced (PDF/CSV) |
| **Accessibility & i18n** | Localization, font scaling, contrast, screen-reader labels |

### 2.2 NOT OURS (other teams — we only consume their output)

| Layer (from source diagrams) | Owning team |
|---|---|
| OCR & text extraction (Tesseract / Google Vision) | Backend / ML |
| NLP chemical-name recognition & standardization (CAS/INCI/EC) | ML |
| EDC knowledge base (WHO, ECHA, ATSDR, IARC), regulatory limits | Data / Backend |
| External data sources (Open Food Facts, CosIng, ECHA, env & gov APIs) | Backend |
| Risk assessment engine (matching, exposure, scoring, health-impact mapping) | Backend / Data-science |
| Lab validation workflow (sample collection → GC-MS/LC-MS/ICP-MS → confirmation) | Laboratory |
| Feedback / learning loop (model retraining, knowledge-base updates) | ML / Data |

### 2.3 The dividing line

```
        ┌────────────────────── OURS (Flutter app) ──────────────────────┐
 user → │ capture → validate format → package request → HTTP → render     │
        └───────────────┬───────────────────────────────▲────────────────┘
                        │ request (barcode / image / manual / location)   │ response (JSON)
        ┌───────────────▼───────────────────────────────┴────────────────┐
        │  BACKEND (not ours): OCR, NLP, knowledge base, risk engine,     │
        │  external APIs, lab validation, ML feedback loop                │
        └─────────────────────────────────────────────────────────────────┘
```

Everything above the line is this repo. Everything below is a **contract** we depend on.

---

## 3. The contract (what we need from the other team)

> **Integration status (reconciled with the real backend).** The backend is the sibling
> repo **`Safe_basket`** (Dart Frog + Postgres + the pure-Dart `edc_matcher` lib + a curated
> EDC dataset). The wire contract below is now aligned with it via a shared pure-Dart
> package **`edc_contracts`** (`Safe_basket/edc_contracts`, path-depended by both sides), and:
> - **All responses use the envelope** `{ data, disclaimer, error }`; the client unwraps
>   `data` in a Dio `EnvelopeInterceptor` (`lib/core/network/envelope_interceptor.dart`).
> - **JSON is snake_case** (`scan_id`, `overall_risk`, …); client models use
>   `field_rename: snake` (`build.yaml`).
> - **Risk is normalized server-side.** The backend `severity` is free-form text (9 hedged
>   values); it is mapped to the client's 4-level `RiskLevel` enum in `edc_contracts`
>   (`normalizeSeverity`) and sent as a `risk` field, so the client stays a thin renderer.
> - **Auth** currently uses an `X-User-Id` header (a per-install device id from
>   `shared_preferences`); it becomes the account id when Google Sign-In lands.
> - Client repos bind the real Dio implementations by default; `--dart-define=USE_FAKES=true`
>   falls back to the in-memory fakes for offline dev.

We build against these endpoints. Exact schemas live in `edc_contracts`. This is the *only*
coupling point.

| Purpose | Endpoint (proposed) | We send | We receive |
|---|---|---|---|
| Barcode lookup | `POST /scan/barcode` | `{ barcode }` | `ScanResult` (backend resolves the product, then runs the matcher over its ingredients) |
| Label/ingredient OCR scan (submit) | `POST /scan/image` | multipart `image` | `{ jobId }` |
| OCR scan status (poll) | `GET /scan/image/{jobId}` | — | `{ status: pending\|done\|failed }` + `ScanResult` when done |
| Manual chemical/product entry | `POST /scan/manual` | free text / selected chemical | `ScanResult` |
| Water source check | `POST /scan/water` | location / source type | `ScanResult` (environmental) |
| Chemical detail | `GET /chemicals/{id}` | — | `ChemicalDetail` |
| Safer alternatives | `GET /chemicals/{id}/alternatives` | — | list of alternatives |
| History sync | `GET /history` | auth token (Google-signed-in user) | list of `ScanResult` |
| Report export | — (client-rendered) | — | — |

**OCR is async — via a backend job wrapper over a synchronous scan.** Safe_basket's
underlying `POST /scan/photo` is synchronous (OCR + match in one call). To keep the client's
patient "processing" UX and avoid long-held requests, the backend wraps it: `POST /scan/image`
enqueues a job and returns a `jobId`; the app polls `GET /scan/image/{jobId}` (short interval,
capped attempts) until `status` is `done` (with the `ScanResult`) or `failed`.
Barcode/manual/water stay synchronous (one request → one `ScanResult`).

**Auth: `X-User-Id` today, Google Sign-In later.** The backend identifies callers by an
`X-User-Id` header (injected by an upstream gateway). Until Google Sign-In lands the client
sends a stable per-install device id (persisted in `shared_preferences`); this becomes the
signed-in account id afterwards. History/profile are tied to this id.

**Report export is client-rendered.** The backend does not produce a PDF/CSV file; the app
renders the report from the `ScanResult` / `ChemicalDetail` data it already has on-device
(e.g. via a PDF-generation package — needs sign-off per CLAUDE.md's "no new packages without
asking" rule before implementation).

**Canonical `ScanResult` (backend-owned, client renders as-is):**
- `scanId`, `scannedAt`, `productName`, `productMeta` (batch/size)
- `overallRisk`: enum `low | moderate | high | veryHigh` — **backend decides, we only color it**
- `detectedChemicals[]`: `{ id, name, risk, ... }`
- `disclaimer` text (lab-confirmation caveat) — displayed verbatim

**Risk-level enum is the single shared vocabulary.** The legend from the source diagram maps
directly to our theme:

| Enum | Label | Color token |
|---|---|---|
| `low` | Low – minimal concern | green |
| `moderate` | Moderate – some concern | amber |
| `high` | High – significant concern | orange |
| `veryHigh` | Very High – severe concern | red |

If the backend isn't ready, we develop against a **fake repository** returning canned
`ScanResult`s so screen work is never blocked.

---

## 4. Internal architecture (inside the app)

Follows the conventions in `CLAUDE.md`: feature-first, Riverpod `@riverpod` AsyncNotifier,
Dio repositories, GoRouter, Freezed + JsonSerializable models.

### 4.1 Layer boundaries (never crossed)

```
Widget (UI only)
   │  reads state / calls notifier methods — no logic, no Dio, no I/O
   ▼
Notifier (AsyncNotifier)   ← orchestration & UI state only
   │  calls repository — never touches Dio or JSON directly
   ▼
Repository                 ← the ONLY place that talks to the network
   │  Dio + interceptors, maps JSON ⇄ Freezed models
   ▼
Backend API (not ours)
```

Rules (enforced in review):
- Widgets contain no business logic and never call a repository directly.
- Notifiers never construct HTTP calls — always go through a repository (CLAUDE.md).
- Repositories are the only network boundary; they return domain models, never raw JSON/`Response`.
- No screen computes risk, severity, or health impact — those fields arrive from the backend.

### 4.2 Folder structure

```
lib/
├── core/
│   ├── network/            # Dio client, interceptors (auth, retry, error mapping)
│   ├── router/             # GoRouter named routes
│   └── theme/              # risk color tokens, typography
├── features/
│   ├── scan/               # capture: barcode, image, manual, water source
│   │   ├── data/           # scan_repository.dart (+ fake for dev)
│   │   ├── application/    # scan_notifier.dart
│   │   ├── domain/         # scan_result.dart, detected_chemical.dart (Freezed)
│   │   ├── presentation/   # scan_options, scanning, result screens + widgets
│   │   └── scan.dart       # barrel export
│   ├── chemical/           # chemical detail + alternatives
│   ├── history/            # history + trends
│   ├── home/               # home dashboard
│   └── profile/            # profile, water test entry point, learn
└── main.dart
```

Each feature owns `data / application / domain / presentation` and exports a barrel
`feature.dart`. Cross-feature access goes through barrels only.

---

## 5. Required screens

Derived from the 6 mockups in the source diagram (`image1.png`). Each screen lists its
route, the feature that owns it, what it renders, and — critically — **what it must NOT do**
(the boundary reminder).

### 5.1 Home — `/` (feature: `home`)
- **Renders:** hero banner ("Scan. Know. Protect."), primary CTA `Start Scanning`, bottom nav
  (History · Water Test · Learn · Profile), notification bell.
- **State:** minimal; may show a recent-scan teaser pulled from local history cache.
- **Must NOT:** perform any scan logic; it only navigates.

### 5.2 Scan Options — `/scan` (feature: `scan`)
- **Renders:** four capture entry tiles — **Barcode Scan**, **Scan Label / Ingredients**,
  **Water Source Check**, **Manual Entry** — plus a "Recent Scans" list.
- **Boundary:** picks an *input modality*. Each routes to a capture flow.
- **Must NOT:** decide anything about chemicals.

### 5.3 Scanning — `/scan/barcode` · `/scan/label` (feature: `scan`)
- **Renders:** live camera preview with framing overlay, torch toggle, gallery pick,
  scanning tips.
- **On-device (ours):** barcode symbology decode, image crop/compress.
- **On capture (barcode):** send to `/scan/barcode`; synchronous — show loading, then
  navigate to Result.
- **On capture (label/OCR):** submit to `/scan/image`, receive a `jobId`, then poll
  `/scan/image/{jobId}` and show a "processing" state (this is a longer wait than barcode —
  design for it explicitly, e.g. progress messaging, cancel option) until `done`/`failed`,
  then navigate to Result or an error state.
- Map network/timeout/permission errors to friendly states.
- **Must NOT:** run OCR or chemical recognition locally — that is the backend's job.

### 5.4 Result — `/scan/result/:scanId` (feature: `scan`)
- **Renders:** product header (name, batch/size, scan date), **overall risk banner**
  (color from `overallRisk`), list of **detected chemicals** each with a risk chip,
  actions `View Details` and `Safer Alternatives`, and the lab-confirmation disclaimer.
- **Must NOT:** compute or override risk — every risk value and label is backend-provided.

### 5.5 Chemical Details — `/chemical/:id` (feature: `chemical`)
- **Renders:** chemical name + risk badge, chemical class, health effects, exposure routes
  (dermal / ingestion / inhalation icons), regulatory status.
- **Data:** `GET /chemicals/{id}`.
- **Must NOT:** author clinical content — it renders backend/knowledge-base text verbatim.

### 5.6 History & Trends — `/history` (feature: `history`)
- **Renders:** tabbed **History** (list of past scans with risk chips) and **Trends**
  (exposure over time charts).
- **Data:** local cache first, synced against `GET /history` for the signed-in Google
  account.
- **Must NOT:** recompute trends' risk categories — it aggregates stored backend results.

### Supporting (from bottom nav, lightweight)
- **Water Test** entry (part of `scan` water flow), **Learn** (static educational content),
  **Profile** (preferences, notification settings). Notifications/alerts are displayed by us
  but triggered by backend risk findings.

---

## 6. What this boundary buys us

- **No medical liability in the client** — the app never makes a health judgment.
- **Parallel work** — screens build against a fake repository while the backend/ML/lab teams
  build their layers; integration is just swapping the repository implementation.
- **One coupling point** — the API contract in §3. If the backend changes internals (new OCR
  engine, retrained model, new database), the app is unaffected as long as `ScanResult`
  holds.

---

## 7. Open questions for the other team

**Resolved:**
1. ~~Sync vs async OCR?~~ → **Async via a backend job wrapper** over Safe_basket's
   synchronous `/scan/photo`: `POST /scan/image` → `jobId`, poll `GET /scan/image/{jobId}`.
   See §3, §5.3.
2. ~~Auth model?~~ → **`X-User-Id`** (per-install device id) now, becoming the **Google
   Sign-In** account id later. See §3.
3. ~~Server- vs client-rendered report export?~~ → **Client-rendered** (`pdf`/`printing`);
   no export endpoint. See §3.
4. ~~Final field list & enum values?~~ → Defined in the shared **`edc_contracts`** package;
   severity→`RiskLevel` normalization lives there too.

**Still open (tracked against Safe_basket):**
5. Offline expectations — must any lookup work without connectivity?
6. OCR polling parameters — interval, timeout/max attempts, webhook/push alternative.
7. **Backend gaps to build** (client screens exist, routes don't yet): async job wrapper +
   `scans`/`scan_jobs` tables, `GET /history`, `GET /scan/{id}`, `GET /chemicals/{id}` (public),
   `/chemicals/{id}/alternatives` (+ dataset), `POST /scan/water`, `GET /notifications`
   (+ table). Barcode-risk and `POST /scan/manual` are done.
8. **Backend build blockers** — Safe_basket currently has pre-existing analysis errors
   (`routes/scan/photo.dart`, `routes/admin/middleware.dart`) from package-version drift;
   the backend team owns these.
