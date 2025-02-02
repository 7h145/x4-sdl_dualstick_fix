# syntax=docker/dockerfile:1
# copyright 2025, thias <github.attic@typedef.net>, CC BY 4.0

FROM debian:bookworm

COPY skel/debian-bookworm-src.list /etc/apt/sources.list.d

RUN true \
  && echo 'debconf debconf/frontend select Noninteractive' |debconf-set-selections \
  && dpkg-reconfigure --frontend noninteractive debconf \
  && apt-get update && apt-get -y upgrade && apt-get -y install \
    build-essential \
    cmake \
    git \
  && apt-get -y build-dep libsdl2 \
  && apt-get -y remove --purge --auto-remove && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/*

RUN true \
  && mkdir -vp /stage \
  && mkdir -vp /stage/build

COPY skel/x4_duplicate_joystick_hack.patch /stage

ARG LIBSDL_TAG="release-2.30.11"
ENV LIBSDL_TAG=$LIBSDL_TAG

RUN true \
  && cd /stage \
  && git clone --branch "${LIBSDL_TAG}" \
    --single-branch --depth 1 https://github.com/libsdl-org/SDL \
  && patch -p0 <x4_duplicate_joystick_hack.patch \
  && cd /stage/build \
  && cmake -S ../SDL \
  && make -j8 \
  && cp -v $(find -type f -name 'libSDL2*.so*') /stage

VOLUME /stage

