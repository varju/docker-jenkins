FROM java:7

RUN groupadd -g 999 docker \
  && apt-get update \
  && apt-get install -y wget git curl zip docker.io \
  && rm -rf /var/lib/apt/lists/*

ENV JENKINS_VERSION 1.591

COPY init.groovy /tmp/WEB-INF/init.groovy.d/tcp-slave-angent-port.groovy
RUN mkdir /usr/share/jenkins/ \
  && curl -L http://updates.jenkins-ci.org/download/war/$JENKINS_VERSION/jenkins.war -o /usr/share/jenkins/jenkins.war \
  && cd /tmp \
  && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy.d/tcp-slave-angent-port.groovy \
  && rm -rf /tmp/WEB-INF

ENV JENKINS_HOME /var/jenkins_home
RUN useradd -d "$JENKINS_HOME" -m -s /bin/bash -G docker jenkins \
  && chown -R jenkins "$JENKINS_HOME"

VOLUME /var/jenkins_home

RUN cd /tmp \
  && curl -L -O https://dl.bintray.com/sbt/debian/sbt-0.13.7.deb \
  && dpkg -i sbt-0.13.7.deb \
  && rm sbt-0.13.7.deb

RUN curl -L https://github.com/docker/fig/releases/download/1.0.1/fig-`uname -s`-`uname -m` > /usr/local/bin/fig; chmod +x /usr/local/bin/fig

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

USER jenkins

COPY jenkins.sh /usr/local/bin/jenkins.sh
ENTRYPOINT ["/usr/local/bin/jenkins.sh"]
