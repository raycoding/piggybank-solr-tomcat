FROM raycoding/piggybank-zookeeper
MAINTAINER Shuddhashil Ray rayshuddhashil@gmail.com

# Environment Variables
ENV SOLR_VERSION 4.8.1
ENV TOMCAT_VERSION 7.0.32
ENV SOLR solr-$SOLR_VERSION
ENV TOMCAT apache-tomcat-$TOMCAT_VERSION
ENV SOLR_HOME /usr/lib/solr-home
ENV TOMCAT_HOME /usr/lib/$TOMCAT

# Fetch Apache Tomcat 7.0.32
RUN (cd /usr/lib/ && wget -q -nc http://archive.apache.org/dist/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/$TOMCAT.zip)
RUN unzip -q /usr/lib/$TOMCAT.zip -d /usr/lib

# Fetch Solr 4.8.1
RUN (cd /usr/lib && wget -q -nc http://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/$SOLR.zip)
RUN unzip -q /usr/lib/$SOLR.zip -d /usr/lib

RUN cp /usr/lib/$SOLR/dist/$SOLR.war /usr/lib/$TOMCAT/webapps/solr.war
RUN cp -r /usr/lib/$SOLR/example/lib/ext/* /usr/lib/$TOMCAT/lib/
RUN ln -s $SOLR_HOME /solr-home

RUN mkdir -p $SOLR_HOME
RUN touch /usr/lib/$TOMCAT/bin/setenv.sh && echo '
	#!/bin/sh
	JAVA_OPTS="$JAVA_OPTS -server"
	JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx2048m"
	JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=128m -XX:+UseG1GC"
	JAVA_OPTS="$JAVA_OPTS -Duser.timezone=UTC -Dfile.encoding=UTF8"
	SOLR_OPTS="-Dsolr.solr.home=$SOLR_HOME -Dport=8080 -DhostContext=solr"
	JAVA_OPTS="$JAVA_OPTS $SOLR_OPTS"
' > /usr/lib/$TOMCAT/bin/setenv.sh

RUN touch $SOLR_HOME/solr.xml && echo '
	<?xml version="1.0" encoding="UTF-8" ?>
	<solr>
	  <solrcloud>
	    <str name="host">${host:}</str>
	    <int name="hostPort">${port:}</int>
	    <str name="hostContext">${hostContext:}</str>
	    <int name="zkClientTimeout">${zkClientTimeout:}</int>
	    <bool name="genericCoreNodeNames">${genericCoreNodeNames:true}</bool>
	  </solrcloud>
	  <shardHandlerFactory name="shardHandlerFactory"
	    class="HttpShardHandlerFactory">
	    <int name="socketTimeout">${socketTimeout:0}</int>
	    <int name="connTimeout">${connTimeout:0}</int>
	  </shardHandlerFactory>
	</solr>
' > $SOLR_HOME/solr.xml

RUN chmod +x /usr/lib/$TOMCAT/bin/*.sh
RUN rm -f /usr/lib/$TOMCAT.zip
RUN rm -f /usr/lib/$SOLR.zip
EXPOSE 8080