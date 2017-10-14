FROM cloudbees/jnlp-slave-with-java-build-tools
MAINTAINER Neil Zheng <pppp29654213@gmail.com>

USER root

# Install docker
RUN curl -fsSL get.docker.com -o get-docker.sh
RUN sh get-docker.sh
RUN usermod -aG docker jenkins

WORKDIR /home/jenkins
USER jenkins

ENTRYPOINT ["/opt/bin/entry_point.sh", "/usr/local/bin/jenkins-slave"]
