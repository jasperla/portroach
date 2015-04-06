-- Migration for 2.0.3
ALTER TABLE portdata DROP COLUMN enslaved;

UPDATE portroach SET dbver = '2015040602';
