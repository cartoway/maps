FROM debian:12.4

RUN apt update -y && \
    apt install -y \
        curl \
        build-essential \
        jq \
        gdal-bin \
        npm \
        locales \
        ruby

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt install -y libsqlite3-dev zlib1g-dev

RUN git clone https://github.com/felt/tippecanoe.git && \
    cd tippecanoe && \
    make install

RUN apt install -y osmium-tool wget

WORKDIR /data/data
