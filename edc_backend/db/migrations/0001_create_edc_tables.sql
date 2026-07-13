-- Migration: 0001_create_edc_tables.sql
-- Run once: psql $DB_CONNECTION_STRING -f db/migrations/0001_create_edc_tables.sql

BEGIN;

CREATE TYPE risk_level AS ENUM ('low', 'moderate', 'high', 'unknown');

CREATE TABLE edc_entries (
    id                 TEXT        PRIMARY KEY,          -- matches EdcEntry.id
    name               TEXT        NOT NULL,             -- matches EdcEntry.name
    cas_number         TEXT        NOT NULL DEFAULT '',  -- matches EdcEntry.casNumber
    risk_level         risk_level  NOT NULL DEFAULT 'unknown',
    last_reviewed_date DATE,                             -- nullable, data-staleness tracking
    reviewed_by        TEXT                              -- nullable, who last reviewed
);

CREATE TABLE edc_aliases (
    id            BIGSERIAL   PRIMARY KEY,
    edc_entry_id  TEXT        NOT NULL REFERENCES edc_entries(id) ON DELETE CASCADE,
    alias         TEXT        NOT NULL,
    UNIQUE (edc_entry_id, alias)                         -- prevent duplicate aliases per entry
);

CREATE INDEX idx_edc_aliases_entry ON edc_aliases(edc_entry_id);
-- Case-insensitive alias lookup used by EdcMatcher
CREATE INDEX idx_edc_aliases_lower ON edc_aliases(lower(alias));

COMMIT;
