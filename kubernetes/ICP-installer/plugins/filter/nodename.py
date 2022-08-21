def node_name(nodename_option, ip_tmpl, hostname_tmpl):
    if nodename_option == 'ip':
        return ip_tmpl
    return hostname_tmpl.lower()

class FilterModule(object):

    def filters(self):
        return {'node_name': node_name}
