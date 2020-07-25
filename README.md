Portroach
===

Portroach is the OpenBSD ports tree version scanner. It scans the
upstream master sites for ports looking for new releases.

Installation
---

Portroach is available as an OpenBSD package built from `misc/portroach`:

    pkg_add portroach

Alternatively you can `git clone` this repository and run
`portroach.py` inplace.

Usage
---

Please see 'perldoc portroach' for usage instructions, or refer to
[docs/portroach-portconfig.txt](docs/portroach-portconfig.txt) for
details on the `PORTROACH` variable.

Results
---

The results are available at
[portroach.openbsd.org](http://portroach.openbsd.org), kindly
hosted by ajacoutot@.

Copyright
---

- 2020 Jasper Lievisse Adriaanse <j@jasper.la>

Contributing
---

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
