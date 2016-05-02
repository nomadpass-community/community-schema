-- Revert community-schema:more_nomad_details from pg

BEGIN;

alter table v1.nomads
  drop column job_title,
  drop column profile_img_url,
  drop column profile_background_img_url;
drop domain uri;

COMMIT;
