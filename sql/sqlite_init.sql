/*
 * Create initial portroach SQL tables
 *
 * Copyright (C) 2006-2011, Shaun Amott <shaun@inerd.com>
 * All rights reserved.
 *
 */

CREATE TABLE portdata (
	`id` integer PRIMARY KEY,
	`name` text,
	`distname` text,
	`ver` text,
	`newver` text,
	`comment` text,
	`cat` text,
	`distfiles` text,
	`sufx` text,
	`mastersites` text,
	`updated` timestamp DEFAULT CURRENT_TIMESTAMP,
	`fullpkgpath` text,
	`basepkgpath` text,
	`discovered` timestamp,
	`checked` timestamp,
	`maintainer` text COLLATE NOCASE,
	`status` text,
	`method` integer,
	`newurl` text,
	`ignore` smallint DEFAULT 0,
	`limitver` text,
	`masterport` text,
	`masterport_id` integer DEFAULT 0,
	`enslaved` integer DEFAULT 0,
	`skipbeta` smallint DEFAULT 1,
	`limiteven` smallint,
	`limitwhich` smallint,
	`indexsite` text,
	`skipversions` text,
	`pcfg_static` smallint DEFAULT 0,
	`mailed` text DEFAULT '',
	`systemid` integer,
	`gh_account` text,
	`gh_project` text
);

CREATE TABLE sitedata (
	`id` integer PRIMARY KEY,
	`failures` integer DEFAULT 0,
	`successes` integer DEFAULT 0,
	`liecount` integer DEFAULT 0,
	`robots` integer DEFAULT 1,
	`robots_paths` text DEFAULT '',
	`robots_nextcheck` timestamp,
	`type` text,
	`host` text,
	`ignore` smallint DEFAULT 0
);

CREATE TABLE maildata (
	`id` integer PRIMARY KEY,
	`address` text COLLATE NOCASE
);

CREATE TABLE systemdata (
	`id` integer PRIMARY KEY,
	`host` text
);

CREATE TABLE allocators (
	`id` integer PRIMARY KEY,
	`seq` integer NOT NULL,
	`systemid` integer REFERENCES systemdata (id),
	`allocator` text
);

CREATE TABLE portroach (
	`dbver` integer
);

CREATE TABLE stats (
	`key` text,
	`val` text
);

CREATE TABLE results (
	`maintainer` text,
	`total` integer,
	`withnewdistfile` integer,
	`percentage` float
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

/*
CREATE
 INDEX portdata_index_maintainer
    ON portdata (maintainer);
*/

CREATE
 INDEX portdata_index_lower_maintainer
    ON portdata (maintainer COLLATE NOCASE);

CREATE
 INDEX portdata_index_masterport_id
    ON portdata (masterport_id);

CREATE
 INDEX portdata_index_discovered
    ON portdata (discovered);

CREATE
 INDEX sitedata_index_host
    ON sitedata (host);

CREATE
 INDEX results_index_maintainer
    ON results (maintainer);
