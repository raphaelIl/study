#!/usr/bin/python

from ansible.module_utils.basic import *

import socket

def port_status(hosts, port):
    status = 'closed'
    for host in hosts:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        if sock.connect_ex((host, port)) == 0:
            return 'opened'
    return status

def main():

    fields = {
        "hosts": {"required": True, "type": "list"},
        "port": {"required": True, "type": "int"},
        "state": {"required": True, "type": "str", "choices": ["opened", "closed"]},
    }
    module = AnsibleModule(argument_spec=fields)

    hosts = module.params['hosts']
    port = module.params['port']
    state = module.params['state']

    hosts.append('127.0.0.1')

    result = port_status(hosts, port)

    if result == state:
        module.exit_json(changed=False, meta=module.params)
    else:
        msg = "Port %s should be %s" % (port, state)
        module.fail_json(msg=msg, meta=module.params)

if __name__ == '__main__':
    main()
