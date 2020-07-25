from .handler import Handler, MetaHandler


class Cpan(Handler, metaclass=MetaHandler):
    def __init__(self):
        super().__init__()
        self.name = 'cpan'
        self.handles_re = r'(https|http|ftp):\/\/(.*?)\/CPAN\/modules\/'

    def get(self, port):
        print(f'getting {port["distname"]} via {self.name}')
