-- Migration for 2.0.3
ALTER TABLE portdata DROP COLUMN enslaved;
ALTER TABLE portdata DROP COLUMN masterport;
ALTER TABLE portdata DROP COLUMN masterport_id;

UPDATE portroach SET dbver = '2015040602';
