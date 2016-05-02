-- Verify community-schema:more_nomad_details on pg

BEGIN;

select job_title, profile_img_url, profile_background_img_url
  from v1.nomads
 where false;

ROLLBACK;
