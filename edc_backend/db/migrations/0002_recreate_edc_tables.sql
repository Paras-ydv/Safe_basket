psql postgres://postgres:postgres123@localhost:5432/edc_db -f db/migrations/0002_recreate_edc_tables.sql
-- Migration: 0002_recreate_edc_tables.sql
-- Drops the placeholder schema from 0001 and creates the correct schema
-- derived from the real edc_database.json and EdcEntry model.
--
-- Run: psql $DB_CONNECTION_STRING -f db/migrations/0002_recreate_edc_tables.sql

BEGIN;

-- Drop old objects from placeholder migration
DROP TABLE IF EXISTS edc_aliases CASCADE;
DROP TABLE IF EXISTS edc_entries CASCADE;
DROP TYPE  IF EXISTS risk_level CASCADE;

-- ── edc_entries ──────────────────────────────────────────────────────────────
-- severity: TEXT, not ENUM. Real values: High, Moderate-High, Moderate,
--   Low-Moderate, Dose-dependent, Low, Emerging, Acute, Non-EDC.
--   Deliberately free-form — categories are hedged/compound.
-- evidence_tier: TEXT. Values: Strong, Moderate, Limited, or NULL.
-- common_sources: TEXT[] — small, not independently edited, no join needed.
-- All other nullable fields map directly from EdcEntry's nullable Dart fields.

CREATE TABLE edc_entries (
    id                       TEXT    PRIMARY KEY,
    name                     TEXT    NOT NULL,
    abbreviation             TEXT,
    common_sources           TEXT[]  NOT NULL DEFAULT '{}',
    scan_method              TEXT,
    app_detection_method     TEXT,
    lab_confirmation_method  TEXT,
    severity                 TEXT    NOT NULL,
    evidence_tier            TEXT,
    mechanism                TEXT,
    pediatric_harms          TEXT,
    adult_harms              TEXT,
    guideline_value          TEXT,
    guideline_authority      TEXT,
    reference_range          TEXT,
    reference_source_url     TEXT,
    draft_app_output_message TEXT,
    notes                    TEXT,
    last_reviewed_date       DATE,
    reviewed_by              TEXT
);

-- ── edc_aliases ───────────────────────────────────────────────────────────────
-- One row per alias string. Separate table because aliases are edited
-- independently and queried case-insensitively by EdcMatcher.

CREATE TABLE edc_aliases (
    id            BIGSERIAL  PRIMARY KEY,
    edc_entry_id  TEXT       NOT NULL REFERENCES edc_entries(id) ON DELETE CASCADE,
    alias         TEXT       NOT NULL,
    UNIQUE (edc_entry_id, alias)
);

CREATE INDEX idx_edc_aliases_entry ON edc_aliases(edc_entry_id);
CREATE INDEX idx_edc_aliases_lower ON edc_aliases(lower(alias));

COMMIT;
