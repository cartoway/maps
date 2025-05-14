# Maps layers

## Build data

```
docker compose --profile=* build
```

```
docker compose --profile=* run --rm tools ./low_emission_zone.sh
docker compose --profile=* run --rm tools ./charching_station.sh
docker compose --profile=* run --rm tools ./limited_traffic_zone.sh
docker compose --profile=* run --rm tools ./etablissements-sirene.sh
```

truck-restrictions
```
docker compose --profile=* run --rm tools ./truck-restrictions-download.sh
./truck-restrictions-tiles.sh
```
