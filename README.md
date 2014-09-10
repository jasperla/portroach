Portroach
===

Portroach is the OpenBSD ports tree version scanner. It scans the
upstream master sites for ports looking for new releases.

Installation
---

Portroach is available as an OpenBSD package built from `misc/portroach`:

    pkg_add portroach

Alternatively you can `git clone` this repository and run
`portroach.pl` inplace.

Usage
---

Please see 'perldoc portroach' for usage instructions, or refer to
[docs/portroach-portconfig.txt](docs/portroach-portconfig.txt) for
details on the `PORTROACH` variable.

Results
---

The results are available over at
[ftp.fr.openbsd.org/portroach/](http://ftp.fr.openbsd.org/portroach/), kindly
hosted by ajacoutot@.

ToDo
---

Here's a shortlist of outstanding tasks or ideas:

- add Makefile.PL
- recurse into remaining subdirectories (graphics/gimp, etc)
- improve DISTFILES handling and "lack" of versions
- add MySQL installation instructions
- ports removed from the tree aren't purged from the database
- for the dynamic pages:
  - use a single `maintainer.html`
  - add page loading notification

Copyright
---

- 2005-2011 Shaun Amott <shaun@inerd.com>
- 2014 Jasper Lievisse Adriaanse <jasper@humppa.nl>

Contributing
---

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
