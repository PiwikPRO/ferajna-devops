#!/usr/bin/python

import requests as lib_requests

from ansible.module_utils.basic import *


def get_foo_and_set_baz(host, port, requests=lib_requests):
    resp1 = requests.get(
        "http://{host}:{port}/foo".format(host=host, port=port)
    )
    assert resp1.status_code == 200

    token = resp1.json()['token']
    resp2 = requests.get(
        "http://{host}:{port}/bar?baz={token}".format(host=host, port=port, token=token)
    )
    assert resp2.status_code == 200


def main():
    module = AnsibleModule(argument_spec={
        "host": {"type": "str"},
        "port": {"type": "int"}
    })
    try:
        get_foo_and_set_baz(
            module.params['host'], module.params['port']
        )
        module.exit_json(
            changed=True,
            rc=0
        )
    except AssertionError:
        module.exit_json(
            changed=True,
            rc=1
        )


if __name__ == '__main__':
    main()