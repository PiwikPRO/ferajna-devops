import unittest
from mock import patch

from .containers import check_if_all_instances_are_stopped


def generate_instance(state='started'):
    return {
        'meta': {
            'instances': [
                {
                    'name': 'foo',
                    'state': state
                }
            ]
        }
    }


class CheckAllInstancesStopped(unittest.TestCase):

    def test_stopped(self):        
        assert check_if_all_instances_are_stopped(
            generate_instance('stopped'),
            '.*'
        )

    def test_not_stopped(self):        
        assert not check_if_all_instances_are_stopped(
            generate_instance('started'),
            '.*'
        )

