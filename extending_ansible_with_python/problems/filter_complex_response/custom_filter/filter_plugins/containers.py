import re


def check_if_all_instances_are_stopped(rancher_response, pattern='piwik-data-processing-organization\\d'):
    compiled_pattern = re.compile(pattern)
    return all(
        [
            r['state'] == "stopped" for r in rancher_response['meta']['instances']
            if compiled_pattern.match(r['name'])
        ]
    )


class FilterModule(object):

    def filters(self):
        return {
            'all_data_processing_containers_are_stopped': check_if_all_instances_are_stopped
        }