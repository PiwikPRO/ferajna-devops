#!/bin/bash
bold=$(tput bold)
normal=$(tput sgr0)

echo "Please download example dataset from ${bold}https://clickhouse.tech/docs/en/getting-started/example-datasets/recipes/${normal} and extract it to ${bold}full_dataset.csv${normal} file"
read -p "Press enter to continue"

echo "Before running this script forward port 9000 to ClickHouse with: ${bold}kubectl --namespace=default port-forward chi-ferajna-cluster-0-0-0 9000${normal}"
read -p "Press enter to continue"

echo "Adding tables"
clickhouse-client --query "CREATE TABLE IF NOT EXISTS recipes (title String, ingredients Array(String), directions Array(String), link String, source LowCardinality(String), NER Array(String)) ENGINE = MergeTree ORDER BY title;"

echo "Adding data - there might be an error during this step, but do not worry about it"
clickhouse-client --query "
    INSERT INTO recipes
    SELECT
        title,
        JSONExtract(ingredients, 'Array(String)'),
        JSONExtract(directions, 'Array(String)'),
        link,
        source,
        JSONExtract(NER, 'Array(String)')
    FROM input('num UInt32, title String, ingredients String, directions String, link String, source LowCardinality(String), NER String')
    FORMAT CSVWithNames
" --input_format_with_names_use_header 0 --format_csv_allow_single_quote 0 --input_format_allow_errors_num 10 < full_dataset.csv
