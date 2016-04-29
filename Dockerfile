# FROM mysql:5.7
# FROM debian:jessie
FROM ubuntu:trusty

MAINTAINER Ikenna N. Okpala <me@ikennaokpala.com>

RUN locale-gen

ENV DEBIAN_FRONTEND noninteractive

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.en
ENV LC_ALL en_US.UTF-8
ENV PS_NGX_EXTRA_FLAGS --with-cc=/usr/bin/gcc --with-ld-opt=-static-libstdc++

# Add all base dependencies
RUN apt-get update -y

RUN apt-get install -y build-essential checkinstall
RUN apt-get install -y vim curl wget unzip
RUN apt-get install -y libfuse-dev libcurl4-openssl-dev mime-support automake libtool python-docutils libreadline-dev
RUN apt-get install -y pkg-config libssl-dev
RUN apt-get install -y git-core
RUN apt-get install -y man cron
RUN apt-get install -y libgmp-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libxslt-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libpcre3 libpcre3-dev
RUN apt-get install -y freetds-dev
# RUN apt-get install -y openjdk-7-jdk
RUN apt-get install -y software-properties-common
RUN apt-get -y install postfix
RUN apt-get -y install rsyslog
RUN apt-get -y install anacron
RUN apt-get -y install mysql-client

RUN mkdir -p /mnt/s3b

WORKDIR ~/

RUN /bin/bash -l -c "wget https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip"
RUN unzip master.zip

RUN cd s3fs-fuse-master/ && ./autogen.sh && ./configure --prefix=/usr --with-openssl && make && make install

ADD templates/schema.sql /root/schema.sql
ADD templates/backup-db.sh /root/backup-db.sh
# ADD templates/crontab /etc/crontab
ADD templates/anacrontab /etc/anacrontab
ADD templates/entrypoint.sh /usr/bin/entrypoint.sh
ADD templates/entrypoint.sh /root/entrypoint.sh

# RUN touch /var/log/cron.log

RUN chmod +x /root/backup-db.sh
RUN chmod +x /usr/bin/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
# ADD templates/backup-cron /etc/cron.d/backup-cron
# RUN chmod 0644 /etc/cron.d/backup-cron
# RUN cron

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/usr/bin/entrypoint.sh"]
