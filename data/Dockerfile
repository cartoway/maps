FROM debian:12.4

RUN apt update -y && \
    apt install -y \
        curl \
        build-essential \
        npm

RUN apt install -y libsqlite3-dev zlib1g-dev

RUN git clone https://github.com/felt/tippecanoe.git && \
    cd tippecanoe && \
    make install

WORKDIR /data/data
