FROM cloudbees/jnlp-slave-with-java-build-tools
MAINTAINER Neil Zheng <pppp29654213@gmail.com>

USER root

# Install node & npm & yarn
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential libssl-dev
RUN npm install yarn -g

# Install docker
RUN curl -sSL https://get.docker.com/ | sh
VOLUME sock:/var/run/docker.sock

# Set yarn cache dir
RUN yarn config set cache-folder /cache
VOLUME cache:/cache

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod o+x /usr/local/bin/jenkins-slave

WORKDIR /home/jenkins

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
