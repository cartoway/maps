docker run \
    -v "$(pwd)":/data \
    ghcr.io/onthegomap/planetiler:latest \
    generate-custom \
        --tile_weights=none \
        --schema=/data/truck-restrictions.yaml \
        --output=/data/truck-restrictions.mbtiles
