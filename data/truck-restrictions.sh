docker run -v "$(pwd)":/data ghcr.io/onthegomap/planetiler:latest generate-custom --schema=/data/truck-restrictions.yaml --download --output=/data/truck-restrictions.mbtiles
