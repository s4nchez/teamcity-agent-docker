FROM ubuntu:trusty

# basic
RUN apt-get update \
  && apt-get install -yqq git curl zip


# java
RUN (curl -L -k -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.tar.gz | gunzip -c | tar x) \
 && mv /jdk1.8.0_60 /jdk

ENV JAVA_HOME /jdk
ENV JRE_HOME  $JAVA_HOME/jre
ENV PATH $PATH:$JAVA_HOME/bin

# maven
ENV MAVEN_VERSION 3.3.3

RUN (curl -L http://www.us.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | gunzip -c | tar x) \
 && mv apache-maven-$MAVEN_VERSION apache-maven

# agent

ENV TEAMCITY_VERSION 9.1.1
ENV TEAMCITY_GIT_PATH /usr/bin/git

RUN curl -LO http://download.jetbrains.com/teamcity/TeamCity-$TEAMCITY_VERSION.war \
 && unzip -qq TeamCity-$TEAMCITY_VERSION.war -d /tmp/teamcity \
 && unzip -qq /tmp/teamcity/update/buildAgent.zip -d /teamcity-agent \


 && chmod +x /teamcity-agent/bin/*.sh \
 && mv /teamcity-agent/conf/buildAgent.dist.properties /teamcity-agent/conf/buildAgent.properties \

 && rm -f TeamCity-$TEAMCITY_VERSION.war \
 && rm -fR /tmp/*

RUN sed -i 's/serverUrl=http:\/\/localhost:8111\//serverUrl=http:\/\/teamcity:8080\/teamcity\//' /teamcity-agent/conf/buildAgent.properties \
 && sed -i 's/workDir=..\/work/workDir=\/home\/teamcity\/work/'                                  /teamcity-agent/conf/buildAgent.properties

RUN useradd -m teamcity \
 && chown -R teamcity:teamcity /teamcity-agent

USER teamcity

ENV M2_HOME /apache-maven
ENV MAVEN_OPTS -Xmx512m -Xss256k -XX:+UseCompressedOops

EXPOSE 9090
CMD ["/teamcity-agent/bin/agent.sh", "run"]

