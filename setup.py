"""Packaging settings."""

from codecs import open
from os.path import abspath, dirname, join
from subprocess import call

from setuptools import Command, find_packages, setup

from portroacher import __version__


this_dir = abspath(dirname(__file__))
with open(join(this_dir, 'README.md')) as file:
    long_description = file.read()


class RunTests(Command):
    """Run all tests."""
    description = 'run tests'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        """Run all tests!"""
        errno = call(['py.test', '--cov=portroacher', '--cov-report=term-missing'])
        raise SystemExit(errno)


setup(
    name = 'portroacher',
    version = __version__,
    description = 'Portroach, but betterer.',
    long_description = long_description,
    url = 'https://github.com/jasperla/portroacher',
    author = 'Jasper Lievisse Adriaanse',
    author_email = 'j@jasper.la',
    license = 'ISC',
    classifiers = [
        'Intended Audience :: Developers',
        'Topic :: Utilities',
        'License :: Public Domain',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
    ],
    keywords = 'cli',
    packages = find_packages(exclude=['docs', 'tests*']),
    install_requires = ['docopt'],
    extras_require = {
        'test': ['coverage', 'pytest', 'pytest-cov'],
    },
    entry_points = {
        'console_scripts': [
            'portroacher=portroacher.cli:main',
        ],
    },
    cmdclass = {'test': RunTests},
)
