#!/bin/sh

#
# Tool for waiting until specific log entry will appear in given container.
#
# Usage:
# waitForContainerLogEntry container log_entry timeout
#
# container - name of container
# log_entry - string that will determine that container is ready
# timeout - [optional] timeout in seconds how long script should wait for log entry - default is 60
#
# If timeout reaches limit or container will have `Exit` status
# script will stop and show logs from given container
#
#

waitForContainerLogEntry(){
    local timeoutCounter=0
    local sleep=1

    local containerName=$1
    local grepText="$2"
    local timeoutInSeconds=${3:-60} #default is 60 seconds

    while :
    do
        IS_READY=$(docker-compose ${DC_ARGS} logs ${containerName} | grep -sc "$grepText")
        if [ ${IS_READY} -gt 0 ]; then
            echo "\nBreaking..."
            break
        fi

        IT_NOT_CRASHED=$(docker-compose ${DC_ARGS} ps ${containerName} | grep -sc "Exit")
        if [ ${IT_NOT_CRASHED} -gt 0 ]; then
            echo "\n[Error] Container $containerName exited - check logs for details"
            docker-compose ${DC_ARGS} logs ${containerName}
            exit
        fi

        local timeoutCounter=$((timeoutCounter+sleep))
        printf "Waiting for $containerName... $timeoutCounter\\r"

        if [ ${timeoutCounter} -gt ${timeoutInSeconds} ]; then
            echo "\n[Error] Running $containerName takes too much time - check logs for details"
            docker-compose ${DC_ARGS} logs ${containerName}
            exit
        fi

        sleep ${sleep}
    done
}
