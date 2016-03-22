# An Ranger running inside docker.

A Docker container for setting up Ranger. This is used as a utility container for connecting to AWS, cron and backup purposes. This container best suites development purposes.

This is a sample Ranger docker container used to test Wordpress installation on [http://www.globalfoodbook.com](http://www.globalfoodbook.com)


To build this ranger server run the following command:

```bash
$ docker pull globalfoodbook/ranger
```

This will doesn't expose any port.

To run the server on the host machine, run the following command:

```bash
$ docker run --name=ranger --link=mysql:mysql --env AWS_S3=${AWS_S3} --detach --volume=/home/core/gfb/conductor/vagrant/scripts/dumps/:/dumps/ --cap-add mknod --cap-add sys_admin --device=/dev/fuse --privileged ranger
```

# NB:

## Before pushing to docker hub

## Login

```bash
$ docker login
```

## Build

```bash
$ cd /to/docker/directory/path/
$ docker build -t <username>/<repo>:latest .
```

## Push to docker hub

```bash
$ docker push <username>/<repo>:latest
```


IP=`docker inspect ranger | grep -w "IPAddress" | awk '{ print $2 }' | head -n 1 | cut -d "," -f1 | sed "s/\"//g"`
HOST_IP=`/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

DOCKER_HOST_IP=`awk 'NR==1 {print $1}' /etc/hosts` # from inside a docker container
