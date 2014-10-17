#!/bin/sh
JAVA_OPTS="$JAVA_OPTS -server"
JAVA_OPTS="$JAVA_OPTS -Xms128m -Xmx2048m"
JAVA_OPTS="$JAVA_OPTS -XX:PermSize=64m -XX:MaxPermSize=128m -XX:+UseG1GC"
JAVA_OPTS="$JAVA_OPTS -Duser.timezone=UTC -Dfile.encoding=UTF8"
SOLR_OPTS="$SOLR_OPTS -Dsolr.solr.home=/usr/lib/solr-home -Dport=8983 -DhostContext=solr -DzkClientTimeout=20000 -Dlog4j.configuration=file:/solr-dist/example/resources/log4j.properties -Dlog4j.debug=true"
JAVA_OPTS="$JAVA_OPTS $SOLR_OPTS"