#!/usr/bin/env python3
#
# Portroach, the OpenBSD distfile scanner

import argparse
import configparser

from pprint import pprint as pp

import portroach

def main():
    parser = argparse.ArgumentParser(f'portroach {portroach.__version__}')
    parser.add_argument('--check', action='store_true',
            help='Sync and crawl')
    parser.add_argument('--crawl', action='store_true',
            help='Only crawl master sites (skip database sync)')
    parser.add_argument('--sync', action='store_true',
            help='Sync the database with sqlports')
    parser.add_argument('--initdb', action='store_true',
            help='Initialize the database')
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

    roach = portroach.Portroach(args, cfg)

    # Initialize the database, after making sure it's not already setup.
    if args.initdb:
        if args.noop:
            print('Nope, nope, nope')
            return
        else:
            roach.initdb()
            return

    # Sync the database with sqlports
    if args.sync:
        if args.noop:
            print('Nope, nope, nope')
            return
        else:
            roach.sync()
            return

    if args.crawl or args.check:
        # XXX: mocked port
        port = {
                'distname': 'salt-3001',
                'master_sites': 'https://pypi.io/packages/source/s/salt/',
                }

        h = sitehandler.find_handler(port['master_sites'])
        h.get(port)


if __name__ == '__main__':
    main()
