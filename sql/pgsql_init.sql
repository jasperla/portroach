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
	masterport text,
	masterport_id integer DEFAULT 0,
	enslaved boolean DEFAULT FALSE,
	skipbeta boolean DEFAULT TRUE,
	limiteven boolean,
	limitwhich smallint,
	indexsite text,
	skipversions text,
	pcfg_static boolean DEFAULT FALSE,
	mailed text DEFAULT '',
	systemid integer,
	gh_account text,
	gh_project text
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

CREATE TABLE allocators (
	id serial UNIQUE,
	seq integer NOT NULL,
	systemid integer REFERENCES systemdata (id),
	allocator text
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
VALUES (2015040602);

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
 INDEX portdata_index_masterport_id
    ON portdata (masterport_id);

CREATE
 INDEX portdata_index_discovered
    ON portdata (discovered);

CREATE
 INDEX sitedata_index_host
    ON sitedata (host);
