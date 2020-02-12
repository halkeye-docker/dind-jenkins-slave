# Docker-in-Docker Jenkins Slave
#
# See: https://github.com/tehranian/dind-jenkins-slave
# See: https://dantehranian.wordpress.com/2014/10/25/building-docker-images-within-docker-containers-via-jenkins/
#
# Following the best practices outlined in:
#   http://jonathan.bergknoff.com/journal/building-good-docker-images

FROM jenkins/jnlp-slave:3.40-1

ENV DEBIAN_FRONTEND noninteractive

USER root

ENV GOSU_VERSION 1.11
RUN set -x \
  && curl -sSLo /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && curl -sSLo /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

RUN apt-get update && \
    apt-get remove docker docker-engine docker.io; \
    apt-get install -qqy apt-transport-https ca-certificates curl software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -qqy docker-ce docker-ce-cli containerd.io && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/docker

# Make sure that the "jenkins" user from base's image is part of the "docker"
# group. Needed to access the docker daemon's unix socket.
RUN usermod -a -G docker jenkins


COPY wrapdocker /usr/local/bin/
RUN chmod +x /usr/local/bin/wrapdocker
ENTRYPOINT ["/usr/local/bin/wrapdocker"]
CMD ["bash"]

