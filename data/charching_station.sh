#!/usr/bin/bash

set -e

cat Stations\ de\ recharge\ pour\ véhicules\ électriques-Analyser_Merge_Charging_station_FR.byOSM.csv | \
    ruby -e "require 'csv'; require 'json'; CSV.parse(STDIN, headers: true).each{ |r| puts r.to_h.compact.to_json }" | \
    jq -c '
        . |
        select(.motorcar != "no") |
        {type: "Feature", geometry: {type: "Point", coordinates: [(.lon | tonumber), .lat | tonumber]}, properties: {
            ref: ."ref:EU:EVSE",
            operator: .operator,
            network: .network,
            fee: (if .fee == "yes" then true else if .fee == "no" then false else null end end),
            type: [
                if ."socket:type2" then "2" else null end,
                if ."socket:type3" then "3" else null end,
                if ."socket:type3c" then "3c" else null end,
                if ."socket:typee" then "e" else null end,
                if ."socket:chademo" then "CHA." else null end
            ] | del(..|nulls) | join(",")
        }}
    ' \
    > charching_station.json
rm -f charching_station.mbtiles
tippecanoe -r1 --cluster-distance=10 --cluster-densest-as-needed charching_station.json -o charching_station.mbtiles
