-- Deploy community-schema:more_nomad_details to pg
-- requires: initial

BEGIN;

create domain uri as text
  check(
    VALUE ~* '^https?://[^\s/$.?#].[^\s]*$'
  );

alter table v1.nomads
  add column job_title text,
  add column profile_img_url uri,
  add column profile_background_img_url uri;

COMMIT;
