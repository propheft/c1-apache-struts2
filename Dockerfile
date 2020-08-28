FROM tomcat:7
MAINTAINER piesecurity <admin@pie-secure.org>
RUN set -ex && rm -rf /usr/local/tomcat/webapps/*
RUN set -ex && chmod 755 /usr/local/tomcat/bin/*.sh
ADD https://files.trendmicro.com/products/CloudOne/ApplicationSecurity/1.0.2/agent-java/trend_app_protect-4.2.0.jar /usr/local/tomcat/trend_app_protect-4.2.0.jar
ENV CATALINA_OPTS="\${CATALINA_OPTS} -javaagent:/usr/local/tomcat/trend_app_protect-4.2.0.jar"
COPY struts2-showcase-2.3.12.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
