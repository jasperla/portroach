-- Migration for 2.0.3
ALTER TABLE portdata DROP COLUMN enslaved;
ALTER TABLE portdata DROP COLUMN masterport;
ALTER TABLE portdata DROP COLUMN masterport_id;

DROP TABLE allocators;

UPDATE portroach SET dbver = '2015040602';
