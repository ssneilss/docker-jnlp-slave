FROM ubuntu:16.04
MAINTAINER Neil Zheng <pppp29654213@gmail.com>

USER root

# Customize sources for apt-get
RUN DISTRIB_CODENAME=$(cat /etc/*release* | grep DISTRIB_CODENAME | cut -f2 -d'=') \
    && echo "deb http://archive.ubuntu.com/ubuntu ${DISTRIB_CODENAME} main universe\n" > /etc/apt/sources.list \
    && echo "deb http://archive.ubuntu.com/ubuntu ${DISTRIB_CODENAME}-updates main universe\n" >> /etc/apt/sources.list \
    && echo "deb http://security.ubuntu.com/ubuntu ${DISTRIB_CODENAME}-security main universe\n" >> /etc/apt/sources.list

#========================
# Miscellaneous packages
#========================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install software-properties-common \
  && add-apt-repository -y ppa:git-core/ppa \
  && apt-get -qqy --no-install-recommends install \
    openssh-client ssh-askpass\
    ca-certificates \
    openjdk-8-jdk \
    tar zip unzip \
    wget curl \
    git \
    build-essential \
    jq \
    python python-pip \
    libssl-dev \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' ./usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

# workaround https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=775775
RUN [ -f "/etc/ssl/certs/java/cacerts" ] || /var/lib/dpkg/info/ca-certificates-java.postinst configure

# workaround "You are using pip version 8.1.1, however version 9.0.1 is available."
RUN pip install --upgrade pip setuptools

# Configure ubuntu timezone
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install -y tzdata
RUN dpkg-reconfigure tzdata

# Add normal user with passwordless sudo
RUN useradd jenkins --shell /bin/bash --create-home \
  && usermod -a -G sudo jenkins \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'jenkins:secret' | chpasswd

#==========
# Maven
#==========
ENV MAVEN_VERSION 3.5.0

RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

#====================================
# AWS CLI
#====================================
RUN pip install awscli

#====================================
# MYSQL CLIENT
#====================================
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install -y mysql-client \
  && rm -rf /var/lib/apt/lists/*

#==================
# NodeJS and Yarn
#==================
RUN apt-get update -qqy \
  && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get -qqy --no-install-recommends install -y nodejs
RUN npm install yarn -g

# Set yarn cache dir
RUN yarn config set cache-folder /cache
VOLUME cache:/cache

#==========
# Docker
#==========
RUN curl -sSL https://get.docker.com/ | sh
VOLUME sock:/var/run/docker.sock

#==========
# RVM
#==========
USER jenkins
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash

#==========
# Ruby
#==========
USER root
RUN /home/jenkins/.rvm/bin/rvm install 2.3.3

#==================
# Jenkins slave
#==================
ARG JENKINS_REMOTING_VERSION=3.12

# See https://github.com/jenkinsci/docker-slave/blob/2.62/Dockerfile#L32
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/$JENKINS_REMOTING_VERSION/remoting-$JENKINS_REMOTING_VERSION.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

RUN chmod a+rwx /home/jenkins
COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod o+x /usr/local/bin/jenkins-slave

WORKDIR /home/jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
