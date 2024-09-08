#!/usr/bin/bash

set -e

mkdir -p truck-restrictions-pbf &&
cd truck-restrictions-pbf &&
wget -O \
    http://download.geofabrik.de/europe/france-latest.osm.pbf \
    http://download.geofabrik.de/europe/spain-latest.osm.pbf \
    http://download.geofabrik.de/europe/portugal-latest.osm.pbf \
    http://download.geofabrik.de/europe/belgium-latest.osm.pbf \
    http://download.geofabrik.de/europe/luxembourg-latest.osm.pbf \
    http://download.geofabrik.de/europe/germany-latest.osm.pbf \
    http://download.geofabrik.de/africa/canary-islands-latest.osm.pbf \
    http://download.geofabrik.de/africa/morocco-latest.osm.pbf \
&&
cd - &&
osmium merge truck-restrictions-pbf/*.pbf -o truck-restrictions-pbf/merge.osm.pbf
