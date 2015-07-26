/*
 * Create initial portroach SQL tables
 *
 * Copyright (C) 2006-2011, Shaun Amott <shaun@inerd.com>
 * All rights reserved.
 *
 */

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
	checked timestamp,
	updated timestamp DEFAULT CURRENT_TIMESTAMP,
	fullpkgpath text,
	basepkgpath text,
	discovered timestamp,
	maintainer text,
	status text,
	method integer,
	newurl text,
	ignore boolean DEFAULT FALSE,
	limitver text,
	skipbeta boolean DEFAULT TRUE,
	limiteven boolean,
	limitwhich smallint,
	pcfg_comment text,
	homepage text,
	indexsite text,
	skipversions text,
	pcfg_static boolean DEFAULT FALSE,
	mailed text DEFAULT '',
	systemid integer
);

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
	ignore boolean DEFAULT FALSE
);

CREATE TABLE maildata (
	id serial UNIQUE,
	address text
);

CREATE TABLE systemdata (
	id serial UNIQUE,
	host text
);

CREATE TABLE portroach (
	dbver integer
);

CREATE TABLE stats (
	key text,
	val text DEFAULT ''
);

INSERT
  INTO portroach (dbver)
VALUES (2015072601);

INSERT
  INTO stats (key)
VALUES ('buildtime');

CREATE
 INDEX portdata_index_name
    ON portdata (name);

CREATE
 INDEX portdata_index_maintainer
    ON portdata (maintainer);

CREATE
 INDEX portdata_index_lower_maintainer
    ON portdata (lower(maintainer));

CREATE
 INDEX portdata_index_discovered
    ON portdata (discovered);

CREATE
 INDEX sitedata_index_host
    ON sitedata (host);
