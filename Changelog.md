v2.0.5
======

- Do not list ignored ports in the "Only show outdated" maintainer view
- Add sitehandler for Bitbucket; the upstream API doesn't allow to
  query for files or releases, only tags. So the sitehandler can only
  report updates for projects that use tags.

v2.0.4
======

- Support new variable: PORTROACH_COMMENT to expand on the PORTROACH value.
  When updating run: `psql -U portroach portroach < sql/migrations/pgsql_2.0.4.sql`

v2.0.3
======

- Remove unused and unneeded flags/configuration options and database columns.
  When updating run: `psql -U portroach portroach < sql/migrations/pgsql_2.0.3.sql`
- Various display tweaks on generated HTML layout/reminder email.
- Remove static HTML output. If you want to generate static HTML, there's the
  'json' output type which can be used as a basis.
- Use basepkgpath in reminder email.
- Unbreak with DBD::SQLite > 1.38.

v2.0.2
======

- Keep track of BASE_PKGPATH to identify ports.
- Fix some nits in the HTML output.
- Sync the RubyGems sitehandler with the new master site protocol.
- Rewrite GitHub sitehandler to use the JSON api.
- Adjust maintainer pages to be more clear and fix cvsweb links.

v2.0.1
======

- Make the inserter and several other SQL interfaces FULLPKGPATH aware.
  Fixes issues where the PORTROACH annotation would not be recorded.

v2.0.0
======

- Switch to using sqlports as the primary datasource. This greatly
  improves performance as we don't have to walk the entire ports tree
  ourselves anymore, executing make(1) 10000s of times.
  It also greatly improves the accuracy and prevents any stale data
  (such as bogus maintainers) from entering the database.
- Add a 'prune' subcommand which will remove any records from the
  database for ports that have been removed from the ports tree.
- Use a simpler layout for generated pages removing some unneeded text.
- Support for MySQL has been removed.
- Add sitehandler for PyPI.
- 'rebuild' is now an alias for 'build' and 'prune'.

v1.2.2
======

- Add sitehandlers for PEAR (pear.php.net) and PECL (pecl.php.net)

v1.2.1
======

- Started to improve version comparision for non-standard versioning schemes

v1.2.0
======

- Various improvements to HTML pages
- Add summary of total ports (found and outdated)
- Unbreak sending notification emails to maintainers
- Unbreak restricted ports' JSON output
- Drop pkg_version handling and unfinished "quick make" mode
- Rework how port directories are scanned

v1.1.1
======

- Various sorting adjustments to the dynamic pages
- Force floats in the JSON output for percentages
- Make failure to write a maintainer page non-fatal again
- Differentiate between having found a file by directory listing and having used
  a dedicated site handler.

v1.1.0
======

- Overhaul templates and default to dynamic pages utilizing AngularJS for
  better filtering and sorting options. Defaults to `output type = dynamic`,
  use `output type = static` for the static HTML-only pages.
- Add site handler for npmjs.org
- Configuration option `output json = true` was removed.
  Instead use `output type = json`

v1.0.0
======

Initial release of Portroach, summary of changes since Portscout 0.8.1:

- Support for OpenBSD ports
- Drop support for FreeBSD and XML data source
- Unbreak site handler for SourceForge
- New dedicated site handlers for:
  - CPAN
  - GitHub
  - Hackage
  - RubyGems
- Allow ignoring certain master sites (i.e. backup sites with no new versions)
- Support generating results in JSON format
