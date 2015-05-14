-- Migration for 2.0.4
ALTER TABLE portdata ADD COLUMN pcfg_comment text;

UPDATE portroach SET dbver = '2015051401';
