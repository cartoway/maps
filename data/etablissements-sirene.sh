#!/usr/bin/bash

set -e

# 45.20 - Entretien et réparation de véhicules automobiles
# 55.10 Hôtel
# 56.10 Restaurant
NAF="45.20 55.10 56.10"
NAF_REGEX="45\.20|55\.10|56\.10"

DATE_FILTER=`date --iso-8601 --date='-2 year'`

wget https://www.data.gouv.fr/fr/datasets/r/825f4199-cadd-486c-ac46-a65a8ea1a047 -O /tmp/StockUniteLegale.zip
zcat /tmp/StockUniteLegale.zip | csvgrep -c activitePrincipaleUniteLegale -r "$NAF_REGEX" | csvgrep -c etatAdministratifUniteLegale -m A | csvcut -c siren,activitePrincipaleUniteLegale,dateCreationUniteLegale,prenom1UniteLegale,prenomUsuelUniteLegale,nomUniteLegale,denominationUniteLegale | gzip > /tmp/StockUniteLegale.csv.gz
rm /tmp/StockUniteLegale.zip

wget https://www.data.gouv.fr/fr/datasets/r/0651fb76-bcf3-4f6a-a38d-bc04fa708576 -O /tmp/StockEtablissement_utf8.zip
zcat /tmp/StockEtablissement_utf8.zip | csvgrep -c activitePrincipaleEtablissement -r "$NAF_REGEX" | csvgrep -c etatAdministratifEtablissement -m A | csvgrep -c caractereEmployeurEtablissement -m O | csvcut -c siren,siret,codeCommuneEtablissement,denominationUsuelleEtablissement,dateCreationEtablissement,trancheEffectifsEtablissement,activitePrincipaleEtablissement,coordonneeLambertAbscisseEtablissement,coordonneeLambertOrdonneeEtablissement | gzip > /tmp/StockEtablissement_utf8.csv.gz
rm /tmp/StockEtablissement_utf8.zip

csvjoin -c siren /tmp/StockUniteLegale.csv.gz /tmp/StockEtablissement_utf8.csv.gz | gzip > etablissement.csv.gz
rm /tmp/StockUniteLegale.csv.gz
rm /tmp/StockEtablissement_utf8.csv.gz

for naf in $NAF; do
    echo "Processing NAF ${naf}"
    zcat etablissement.csv.gz | csvjson --stream | \
    jq -c " \
        select(.dateCreationUniteLegale) | \
        select(.dateCreationUniteLegale < \"${DATE_FILTER}\") | \
        select(.codeCommuneEtablissement < \"97\") | \
        select(.activitePrincipaleEtablissement | match(\"^${naf}.*\")) | \
        select(.coordonneeLambertAbscisseEtablissement) | \
        select(.coordonneeLambertAbscisseEtablissement != \"[ND]\") | \
        select(.coordonneeLambertAbscisseEtablissement != \"[ND]\") | \
        select(.dateCreationEtablissement) | \
        select(.dateCreationEtablissement < \"${DATE_FILTER}\") | \
        { \
            type: \"Feature\", \
            properties: { \
                siret: .siret, \
                name: (.denominationUsuelleEtablissement // .denominationUniteLegale // ([.prenom1UniteLegale, .nomUniteLegale] | join(\" \"))), \
                employees: .trancheEffectifsEtablissement \
            } | with_entries(select(.value != null and .value !=\"[ND]\")), \
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
