import re

# Reference of the handler classes; these need to be
# instantiated before using. For example through find_handler().
registry = {}


# Meta class for all handlers to ensure they're properly
# registered.
class MetaHandler(type):
    def __new__(meta, name, bases, class_dict):
        cls = type.__new__(meta, name, bases, class_dict)
        registry[cls.__name__] = cls
        return cls


class Handler(object):
    def __init__(self):
        pass

    # Indicates whether or not this handler works for the given
    # master_site.
    def handles(self, site) -> bool:
        if re.match(self.handles_re, site):
            return True
        else:
            return False

    # For the given port, retrieve the latest distfiles.
    def get(self, port) -> list:
        pass


def find_handler(site) -> Handler:
    for h in registry:
        handler = registry[h]()
        if handler.handles(site):
            return handler

    return None
