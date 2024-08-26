# Maps layers

## Build data

```
docker compose --profile=* build
```

```
docker compose --profile=* run --rm tools ./low_emission_zone.sh
docker compose --profile=* run --rm tools ./charching_station.sh
docker compose --profile=* run --rm tools ./limited_traffic_zone.sh
```
