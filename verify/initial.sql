-- Verify community-schema:initial on pg

BEGIN;

SELECT pg_catalog.has_schema_privilege('internal', 'usage');
SELECT pg_catalog.has_schema_privilege('v1', 'usage');

ROLLBACK;
