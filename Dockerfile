FROM jenkins/inbound-agent:4.7-1-jdk11

ENV DEBIAN_FRONTEND noninteractive

USER root

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
