-- Migration for 2.0.6
ALTER TABLE portdata ADD COLUMN homepage text;

UPDATE portroach SET dbver = '2015072601';
