#!/usr/bin/bash

set -e

tippecanoe-decode -Z14 -z14 jo-2024-grab.mbtiles > jo-2024.geojson
cat jo-2024.geojson | jq -c '{type: "FeatureCollection", features:[ .features[].features[].features[] | .properties.id = .id | .properties.DATE_DEBUT = (.properties.DATE_DEBUT[0:16]) | .properties.DATE_FIN = (.properties.DATE_FIN[0:16]) ]}' > jo-2024-grab.geojson
rm -f jo-2024.geojson
ogr2ogr jo-2024.geojson -dialect SQLite -sql 'SELECT id, DATE_DEBUT, DATE_FIN, TYPE_PERI, ST_Union(geometry) AS geometry FROM "jo-2024-grab" GROUP BY id, DATE_DEBUT, DATE_FIN, TYPE_PERI' jo-2024-grab.geojson
rm -f jo-2024.mbtiles
tippecanoe jo-2024.geojson -o jo-2024.mbtiles
