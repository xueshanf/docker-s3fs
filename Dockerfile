FROM ubuntu:16.04
MAINTAINER Xueshan Feng <xueshan.feng@gmail.com>

ENV VERSION 1.91

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
 automake \
 curl \
 build-essential \
 libcurl4-openssl-dev \
 libssl-dev \
 libfuse-dev \
 libtool \
 libxml2-dev mime-support \
 tar \
 pkg-config \
 && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v${VERSION}.tar.gz | tar zxv -C /usr/src
RUN cd /usr/src/s3fs-fuse-${VERSION} && ./autogen.sh && ./configure --prefix=/usr && make && make install

CMD ["/bin/bash"]
