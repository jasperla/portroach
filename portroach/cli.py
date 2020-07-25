#!/usr/bin/env python3
#
# Portroach, the OpenBSD distfile scanner

import argparse
import configparser

from pprint import pprint as pp

import metadata
import sitehandler


def main():
    m = metadata.Metadata()

    parser = argparse.ArgumentParser(f'{m.metadata["name"]} {m.metadata["version"]}')
    parser.add_argument('--check', action='store_true',
            help='Perform a the actual check')
    parser.add_argument('--build', action='store_true',
            help='Build the database')
    parser.add_argument('--config', default='portroach.cfg',
            help='Path to configuration file. Defaults to "portroach.cfg".')
    parser.add_argument('--noop', action='store_true',
            help='Do not modify the database and do not mail maintainers.')
    #parser.add_argument('--limit-ports', help='Only check this list of ports')
    #parser.add_argument('--limit-maintainer', help='Only check ports belonging to a specific maintainer')
    args = parser.parse_args()

    cfg = configparser.ConfigParser()
    cfg.read_file(open(args.config))

    # Merge commandline options with configuration file settings
    if args.noop:
        cfg.readonly = True

    #portroach = Portroach(args, config)
    #portroach.run()

    # XXX: mocked port
    port = {
        'distname': 'salt-3001',
        'master_sites': 'https://pypi.io/packages/source/s/salt/',
    }

    h = sitehandler.find_handler(port['master_sites'])
    h.get(port)


if __name__ == '__main__':
    main()
