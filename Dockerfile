FROM tomcat:7
MAINTAINER piesecurity <admin@pie-secure.org>
RUN set -ex && rm -rf /usr/local/tomcat/webapps/*
RUN set -ex && /bin/bash -c "chmod 755 /usr/local/tomcat/bin/*.sh"
COPY struts2-showcase-2.3.12.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
