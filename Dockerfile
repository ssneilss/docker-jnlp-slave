FROM cloudbees/jnlp-slave-with-java-build-tools
MAINTAINER Neil Zheng <pppp29654213@gmail.com>

USER root

# Install node & npm & yarn
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y build-essential libssl-dev
RUN npm install yarn -g

WORKDIR /home/jenkins
USER jenkins

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
