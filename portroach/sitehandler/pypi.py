from .handler import Handler, MetaHandler


class Pypi(Handler, metaclass=MetaHandler):
    def __init__(self):
        super().__init__()
        self.name = 'pypi'
        self.handles_re = r'https:\/\/pypi\.io\/'

    def get(self, port):
        print(f'getting {port["distname"]} via {self.name}')
