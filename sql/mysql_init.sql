/*
 * Create initial portscout SQL tables
 *
 * Copyright (C) 2006-2011, Shaun Amott <shaun@inerd.com>
 * Copyright (C) 2011, Martin Matuska <mm@FreeBSD.org>
 * All rights reserved.
 *
 * $Id$
 */

DROP TABLE IF EXISTS portdata;
CREATE TABLE portdata (
	id serial UNIQUE,
	name text,
	distname text,
	ver text,
	newver text,
	comment text,
	cat text,
	distfiles text,
	sufx text,
	mastersites text,
	updated timestamp DEFAULT CURRENT_TIMESTAMP,
	checked timestamp,
	discovered timestamp,
	maintainer text,
	status text,
	method integer,
	newurl text,
	`ignore` boolean DEFAULT 0,
	limitver text,
	masterport text,
	masterport_id integer DEFAULT 0,
	enslaved boolean DEFAULT 0,
	skipbeta boolean DEFAULT 0,
	limiteven boolean,
	limitwhich smallint,
	moved boolean DEFAULT 0,
	indexsite text,
	skipversions text,
	pcfg_static boolean DEFAULT 0,
	mailed text DEFAULT '',
	systemid integer
);

DROP TABLE IF EXISTS sitedata;
CREATE TABLE sitedata (
	id serial UNIQUE,
	failures integer DEFAULT 0,
	successes integer DEFAULT 0,
	liecount integer DEFAULT 0,
	robots integer DEFAULT 1,
	robots_paths text DEFAULT '',
	robots_nextcheck timestamp,
	type text,
	host text,
	`ignore` boolean DEFAULT 0
);

DROP TABLE IF EXISTS moveddata;
CREATE TABLE moveddata (
	id serial UNIQUE,
	fromport text,
	toport text,
	date text,
	reason text
);

DROP TABLE IF EXISTS maildata;
CREATE TABLE maildata (
	id serial UNIQUE,
	address text
);

DROP TABLE IF EXISTS systemdata;
CREATE TABLE systemdata (
	id serial UNIQUE,
	host text
);

DROP TABLE IF EXISTS allocators;
CREATE TABLE allocators (
	id serial UNIQUE,
	seq integer NOT NULL,
	systemid integer REFERENCES systemdata (id),
	allocator text
);

DROP TABLE IF EXISTS portscout;
CREATE TABLE portscout (
	dbver integer
);

DROP TABLE IF EXISTS stats;
CREATE TABLE stats (
	`key` text,
	val text DEFAULT ''
);

DROP TABLE IF EXISTS results;
CREATE TABLE results (
	maintainer text,
	total integer,
	withnewdistfile integer,
	percentage float
);

INSERT
  INTO portscout (dbver)
VALUES (2011040901);

INSERT
  INTO stats (`key`)
VALUES ('buildtime');

CREATE
 INDEX portdata_index_name
    ON portdata (name(255));

CREATE
 INDEX portdata_index_maintainer
    ON portdata (maintainer(255));

CREATE
 INDEX portdata_index_masterport_id
    ON portdata (masterport_id);

CREATE
 INDEX portdata_index_discovered
    ON portdata (discovered);

CREATE
 INDEX sitedata_index_host
    ON sitedata (host(255));

CREATE
 INDEX moveddata_index_fromport
    ON moveddata (fromport(255));
