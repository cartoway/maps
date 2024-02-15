#!/usr/bin/bash

set -e

curl "https://overpass.kumi.systems/api/interpreter?data=%5Bout%3Axml%5D%5Btimeout%3A360%5D%3B%0Arelation%5B%22boundary%22%3D%22low_emission_zone%22%5D%2834.016241889667036%2C-10.014225844127038%2C59.84481485969108%2C14.902766343372946%29%3B%0Aout%20geom%3B" > low_emission_zone.osm.xml
npm install -g osmtogeojson
npx osmtogeojson low_emission_zone.osm.xml > low_emission_zone_raw.geojson
cat low_emission_zone_raw.geojson | jq -c '.features[] | select(.properties."access:note" != null) | . + {properties: (.properties + {low_emission_zone: "true"})}' > low_emission_zone.geojson
# ogr2ogr low_emission_zone-f.geojson -where "start_date IS NULL OR start_date < '`date --iso`'" low_emission_zone.geojson
tippecanoe low_emission_zone.geojson --force -o low_emission_zone.mbtiles
rm low_emission_zone.osm.xml low_emission_zone_raw.geojson low_emission_zone.geojson
