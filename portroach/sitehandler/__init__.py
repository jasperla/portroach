# Import the individual handlers
from .cpan import Cpan
from .pypi import Pypi

from .handler import MetaHandler, Handler, find_handler

# Initialize a first set of classes to populate the registry
# and thus record the list of handlers.Cpan()
Cpan()
Pypi()
