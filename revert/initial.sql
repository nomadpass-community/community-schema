-- Revert community-schema:initial from pg

BEGIN;

DROP SCHEMA v1 CASCADE;
DROP SCHEMA internal CASCADE;

COMMIT;
