--oops i used the wrong schema last time

--DROP THE BRS.metro_area_postal_code TABLE...BUT RENAMING IT FOR NOW IN CASE I NEED IT AGAIN
ALTER TABLE IF EXISTS brs.metro_area_postal_code
  RENAME TO deprecated_metro_area_postal_code;
