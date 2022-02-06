###
#
#   Version 20.04 (corresponds to latest, which is LTS according to Ubuntu)
#   https://hub.docker.com/_/ubuntu
#
#	Yves Vindevogel (vindevoy)
#	2022-02-04
#
###
 
FROM ubuntu:20.04

LABEL maintainer="Yves Vindevogel (vindevoy) - yves.vindevogel@asynchrone.com"

ENV DEBIAN_FRONTEND noninteractive

ARG TZ_REGION=Europe
ARG TZ_CITY=Brussels

RUN apt-get update -y
RUN apt-get dist-upgrade -y

RUN apt-get install apt-utils --no-install-recommends -y
RUN apt-get install tzdata --no-install-recommends -y

RUN apt-get autoremove
RUN apt-get clean all

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/$TZ_REGION/$TZ_CITY /etc/localtime

CMD ["/bin/sh"]
