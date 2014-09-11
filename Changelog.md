v1.1.2 (not yet released)
======

- Various improvements to HTML pages
- Add summary of total ports (found and outdated)
- Unbreak sending notification emails to maintainers
- Unbreak restricted ports' JSON output
- Drop pkg_version handling and unfinished "quick make" mode

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
