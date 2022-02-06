FROM ubuntu:20.04

LABEL maintainer="Yves Vindevogel (vindevoy) - yves.vindevogel@asynchrone.com"

ENV DEBIAN_FRONTEND noninteractive

ARG TZ_REGION=Europe
ARG TZ_CITY=Brussels

RUN set -x && \ 
    apt-get update -y && \ 
    apt-get dist-upgrade -y && \ 
    apt-get install apt-utils --no-install-recommends -y && \ 
    apt-get install tzdata --no-install-recommends -y && \ 
    apt-get autoremove && \ 
    apt-get clean all && \ 
    rm -f /etc/localtime && \ 
    ln -s /usr/share/zoneinfo/$TZ_REGION/$TZ_CITY /etc/localtime

CMD ["/bin/sh"]
