#!/usr/bin/python

from ansible.module_utils.basic import *

import yaml

def create_yaml_file(path, vardict, child):
    if child is not None:
        vardict = vardict[child]

    with open(path, 'w') as yaml_file:
        yaml.dump(vardict, yaml_file, default_flow_style=False)

    return 'present'

def main():

    fields = {
        "path": {"required": True, "type": "str"},
        "vardict": {"required": True, "type": "dict"},
        "child": {"required": False, "default": None, "type": "str"},
        "state": {"required": True, "type": "str", "choices": ["present", "absent"]},
    }
    module = AnsibleModule(argument_spec=fields)

    path = module.params['path']
    vardict = module.params['vardict']
    child = module.params['child']
    state = module.params['state']

    result = create_yaml_file(path, vardict, child)

    if result == state:
        module.exit_json(changed=False, meta=module.params)
    else:
        msg = "Creating %s failed" % path
        module.fail_json(msg=msg, meta=module.params)

if __name__ == '__main__':
    main()
