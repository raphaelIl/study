#!/usr/bin/python
from ansible.module_utils.basic import *
import yaml

def migrate_yaml(migrate_rules, yaml_path):
    rules = migrate_rules
    doc = yaml.load(open(yaml_path))
    # check old key and new key in config.yaml
    for rule in rules:
        check_key(rule['oldkey'], doc, 'old')
        check_key(rule['newkey'], doc, 'new')
    # migrate old key to new key and generate a new config.yaml
    for rule in rules:
        newkey, oldkey = format_key(rule)
        # run python code "doc['new']['subnew'] = doc['old']" with exec
        # replace old key with new
        exec('doc' + newkey + ' = doc' + oldkey)
        # delete old key-vlaue
        exec('del doc' + oldkey)
        with open(yaml_path, 'w') as new_yaml:
            yaml.dump(doc, new_yaml, default_flow_style=False)
    return 'present'

def check_key(keys, doc, key_type='new'):
    tmp_dict = doc
    for key in keys.split('.'):
        # create key if not exist for new key
        if key not in tmp_dict:
            if key_type == 'new':
                tmp_dict[key.encode('utf-8')] = {}
            else:
                raise KeyError('{} key is not exist, make sure this key exist in config.yaml.'.format(key))
        tmp_dict = tmp_dict[key]

def format_key(key):
    oldkey = key['oldkey']
    newkey = key['newkey']
    return "['" + "']['".join(newkey.split('.')) + "']", "['" +  "']['".join(oldkey.split('.')) + "']"

def main():

    fields = {
        "migrate_rules": {"required": True, "type": "list"},
        "yaml_path": {"required": True, "type": "str"},
        "state": {"required": True, "type": "str", "choices": ["present", "absent"]},
    }
    module = AnsibleModule(argument_spec=fields)

    migrate_rules = module.params['migrate_rules']
    yaml_path = module.params['yaml_path']
    state = module.params['state']

    result = migrate_yaml(migrate_rules, yaml_path)

    if result == state:
        module.exit_json(changed=False, meta=module.params)
    else:
        msg = "Migrate yaml failed"
        module.fail_json(msg=msg, meta=module.params)

if __name__ == '__main__':
    main()
