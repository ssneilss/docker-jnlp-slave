FROM cloudbees/jnlp-slave-with-java-build-tools
MAINTAINER Neil Zheng <pppp29654213@gmail.com>

USER root

# Install node & npm & yarn
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential libssl-dev
RUN npm install yarn -g

# Set yarn cache dir
RUN yarn config set cache-folder /cache
VOLUME cache:/cache

# Configure ubuntu timezone
RUN apt-get install -y tzdata
RUN dpkg-reconfigure tzdata

# Install docker
RUN curl -sSL https://get.docker.com/ | sh
VOLUME sock:/var/run/docker.sock

# Install rvm
USER jenkins
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash

# Install ruby 2.3.3
USER root
RUN /home/jenkins/.rvm/bin/rvm install 2.3.3

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod o+x /usr/local/bin/jenkins-slave

WORKDIR /home/jenkins

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
