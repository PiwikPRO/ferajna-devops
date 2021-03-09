#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "Before running this script forward port 9000 to ClickHouse with: ${bold}kubectl --namespace=default port-forward chi-ferajna-cluster-0-0-0 9000${normal}"
read -p "Press enter to continue"

echo "Running queries to make some noise"
while true;
do
    clickhouse-client --query "SELECT count() FROM recipes;" > /dev/null
    clickhouse-client --query "SELECT
        arrayJoin(NER) AS k,
        count() AS c
    FROM recipes
    GROUP BY k
    ORDER BY c DESC
    LIMIT 50" > /dev/null
    clickhouse-client --query "SELECT
        title,
        length(NER),
        length(directions)
    FROM recipes
    WHERE has(NER, 'strawberry')
    ORDER BY length(directions) DESC
    LIMIT 10" > /dev/null
    clickhouse-client --query "SELECT arrayJoin(directions)
    FROM recipes
    WHERE title = 'Chocolate-Strawberry-Orange Wedding Cake'" > /dev/null
done
