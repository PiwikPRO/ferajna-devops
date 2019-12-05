import unittest
from .containers import check_if_all_instances_are_stopped


def generate_single_instance(state):
    return {
        "meta": {
            "instances": [
                {
                    "name": "piwik-data-processing-organization0",
                    "state": state
                }
            ]
        }
    }



class TestSmth(unittest.TestCase):

    def test_stopped(self):
        assert check_if_all_instances_are_stopped(generate_single_instance("stopped"), ".*")

    def test_not_stopped(self):
        assert not check_if_all_instances_are_stopped(generate_single_instance("started"), ".*")
