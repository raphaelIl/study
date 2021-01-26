def node_arch(ansible_architecture):
    if ansible_architecture == 'x86_64':
        return 'amd64'
    return ansible_architecture

class FilterModule(object):

    def filters(self):
        return {'node_arch': node_arch}
