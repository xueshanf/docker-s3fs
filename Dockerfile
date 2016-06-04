FROM ubuntu:14.04
MAINTAINER Xueshan Feng <xueshan.feng@gmail.com>

RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool curl tar

RUN curl -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.80.tar.gz | tar zxv -C /usr/src
RUN cd /usr/src/s3fs-fuse-1.79 && ./autogen.sh && ./configure --prefix=/usr && make && make install

CMD ["/bin/bash"]
