#!/usr/bin/bash

set -e

cat Stations\ de\ recharge\ pour\ véhicules\ électriques-Analyser_Merge_Charging_station_FR.byOSM.csv | ruby -e "require 'csv'; require 'json'; CSV.parse(STDIN, headers: true).each{ |r| puts r.to_h.compact.to_json }" | jq -c '. | select(.motorcar == "yes") | {type: "Feature", geometry: {type: "Point", coordinates: [(.lon | tonumber), .lat | tonumber]}, properties: {ref: ."ref:EU:EVSE", operator: .operator, network: .network }}' > charching_station.json
rm -f charching_station.mbtiles
tippecanoe -r1 --cluster-distance=10 --cluster-densest-as-needed charching_station.json -o charching_station.mbtiles
