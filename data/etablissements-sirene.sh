#!/usr/bin/bash

set -e

# 45.20 - Entretien et réparation de véhicules automobiles
# 55.10 Hôtel
# 56.10 Restaurant
NAF_REGEX=",45\.20|,55\.10|,56\.10"

wget https://www.data.gouv.fr/fr/datasets/r/0651fb76-bcf3-4f6a-a38d-bc04fa708576 -O /tmp/StockEtablissement_utf8.zip
(
    zcat /tmp/StockEtablissement_utf8.zip | head -n 1;
    zcat /tmp/StockEtablissement_utf8.zip | grep -E "$NAF_REGEX"
) | npx csvtojson parse --ignoreEmpty=true | gzip > o.gz
rm /tmp/StockEtablissement_utf8.zip

DATE_FILTER=`date --iso-8601 --date='-2 year'`

for naf in "45.20" "55.10" 56.10; do
    echo "Processing NAF ${naf}"

    zcat o.gz | \
    tail -n+2 | head -n-2 | sed 's/,$//' | \
    jq -c " \
        select(.etatAdministratifEtablissement = \"O\") | \
        select(.caractereEmployeurEtablissement = \"O\") | \
        select(.codeCommuneEtablissement < \"97\") | \
        select(.activitePrincipaleEtablissement | match(\"^${naf}.*\")) | \
        select(.coordonneeLambertAbscisseEtablissement) | \
        select(.coordonneeLambertAbscisseEtablissement != \"[ND]\") | \
        select(.coordonneeLambertAbscisseEtablissement != \"[ND]\") | \
        select(.dateCreationEtablissement) | \
        select(.dateCreationEtablissement < \"${DATE_FILTER}\") | \
        { \
            type: \"Feature\", \
            properties:{siret: .siret, name: .denominationUsuelleEtablissement, employees: .trancheEffectifsEtablissement, naf: .activitePrincipaleEtablissement} | with_entries(select(.value != null)), \
            geometry: {type: \"Point\", coordinates: [(.coordonneeLambertAbscisseEtablissement|tonumber),(.coordonneeLambertOrdonneeEtablissement|tonumber)]} \
        }
    " | \
    jq -c -s "{type: \"FeatureCollection\", features: . }" \
    > etablissements-${naf}-2154.geojson

    ogr2ogr -t_srs EPSG:4326 -s_srs EPSG:2154 etablissements-${naf}.geojson etablissements-${naf}-2154.geojson
    rm -f etablissements-${naf}-2154.geojson

    tippecanoe \
        etablissements-${naf}.geojson \
        --feature-filter '{ "*": [ "any", [ ">=", "$zoom", 14 ], [">=", "employees", "02"] ] }' \
        -rg \
        --force -o etablissements-${naf}.mbtiles
    rm -f etablissements-${naf}.geojson
done
