FROM mhart/alpine-node:8
MAINTAINER Neil Zheng <pppp29654213@gmail.com>

USER root

ARG JENKINS_REMOTING_VERSION=3.12

COPY jenkins-slave /usr/local/bin/jenkins-slave

RUN apk --update add --no-cache \
  python make g++ \
  py-pip \
  openjdk8-jre-base \
  wget curl git jq bash zip \
  docker \
# workaround "You are using pip version 8.1.1, however version 9.0.1 is available."
&& pip install --upgrade pip setuptools awscli \
# Add normal user with passwordless sudo
&& adduser -S jenkins -s /bin/bash \
  && adduser jenkins root \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:secret' | chpasswd \
# Set yarn cache dir
&& yarn config set cache-folder /cache \
# Jenkins slave
&& curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar \
&& chmod a+rwx /home/jenkins \
&& chmod o+x /usr/local/bin/jenkins-slave

VOLUME cache:/cache
VOLUME sock:/var/run/docker.sock

WORKDIR /home/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
