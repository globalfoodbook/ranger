# FROM mysql:5.7
# FROM debian:jessie
FROM ubuntu:trusty

MAINTAINER Ikenna N. Okpala <me@ikennaokpala.com>

ARG BUILD_DATE
ARG VCS_REF
# i.e
# BUILD_DATE `date -u +"%Y-%m-%dT%H:%M:%SZ"`
# VCS_REF `git rev-parse --short HEAD`
LABEL org.label-schema.build-date=$BUILD_DATE \
       org.label-schema.docker.dockerfile="/Dockerfile" \
       org.label-schema.license="GNU GENERAL PUBLIC LICENSE" \
       org.label-schema.name="Ranger docker container (gfb)" \
       org.label-schema.url="http://globalfoodbook.com/" \
       org.label-schema.vcs-ref=$VCS_REF \
       org.label-schema.vcs-type="Git" \
       org.label-schema.vcs-url="https://github.com/globalfoodbook/ranger.git"

RUN locale-gen

ENV DEBIAN_FRONTEND noninteractive

ENV S3_BUCKET gfb-assets
ENV GCS_BUCKET assets.globalfoodbook.net
ENV GCS_AUTH_FILE /etc/gcs-auth.txt
ENV MOUNT /mnt/cloud-storage-bucket
ENV BACKUP /dumps

# Add all base dependencies
RUN apt-get update -y

RUN apt-get install -y build-essential checkinstall
RUN apt-get install -y vim curl wget unzip
RUN apt-get install -y libfuse-dev libcurl4-openssl-dev mime-support automake libtool python-docutils libreadline-dev
RUN apt-get install -y pkg-config libssl-dev
RUN apt-get install -y git-core
RUN apt-get install -y man
RUN apt-get install -y libgmp-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libxslt-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libpcre3 libpcre3-dev
RUN apt-get install -y freetds-dev
RUN apt-get install -y software-properties-common
RUN apt-get -y install postfix
RUN apt-get -y install rsyslog
RUN apt-get -y install mysql-client
# RUN apt-get -y install ruby ruby-dev
# RUN gem install fpm
# RUN apt-get install -y python-setuptools python-dev
# RUN easy_install pip
# RUN /usr/bin/yes | pip install --upgrade virtualenv
# RUN /usr/bin/yes | pip install awscli --ignore-installed six

RUN mkdir -p $MOUNT

WORKDIR /root

RUN /bin/bash -l -c "wget https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip"
RUN unzip master.zip

RUN cd /root/s3fs-fuse-master/ && ./autogen.sh && ./configure --prefix=/usr/ --with-openssl && make && make install

RUN rm -rf master.zip s3fs-fuse-master/

ADD templates/schema.sql /root/schema.sql
ADD templates/backup-db.sh /root/backup-db.sh
ADD templates/entrypoint.sh /usr/bin/entrypoint.sh
ADD templates/fxn.sh /usr/bin/fxn.sh

RUN chmod +x /root/backup-db.sh
RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/fxn.sh

RUN echo "$(cat /root/.bashrc)\nsource /usr/bin/fxn.sh\nalias mcs=mount_cloud_storage\n" > /root/.bashrc;

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/usr/bin/entrypoint.sh"]
