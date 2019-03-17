# Docker-in-Docker Jenkins Slave
#
# See: https://github.com/tehranian/dind-jenkins-slave
# See: https://dantehranian.wordpress.com/2014/10/25/building-docker-images-within-docker-containers-via-jenkins/
#
# Following the best practices outlined in:
#   http://jonathan.bergknoff.com/journal/building-good-docker-images

FROM jenkinsci/ssh-slave

ENV DEBIAN_FRONTEND noninteractive

# Adapted from: https://registry.hub.docker.com/u/jpetazzo/dind/dockerfile/
# Let's start with some basic stuff.
RUN apt-get update && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    php-cli \
    php-curl
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get install -y docker-ce && \
    rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/docker

# Make sure that the "jenkins" user from evarga's image is part of the "docker"
# group. Needed to access the docker daemon's unix socket.
RUN usermod -a -G docker jenkins

# Phabricator API
RUN cd /opt; \
    git clone https://github.com/phacility/arcanist.git; \
    git clone https://github.com/phacility/libphutil.git; \
    ln -s /opt/arcanist/bin/arc /usr/local/bin/arc; \
    arc set-config default https://phabricator.gavinmogan.com

COPY wrapdocker wrapdocker-setup-sshd /usr/local/bin/
RUN chmod +x /usr/local/bin/wrapdocker /usr/local/bin/wrapdocker-setup-sshd
RUN cat /usr/local/bin/wrapdocker /usr/local/bin/wrapdocker-setup-sshd
ENTRYPOINT ["/usr/local/bin/wrapdocker-setup-sshd"]

