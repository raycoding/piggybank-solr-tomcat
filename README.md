# Solr Cloud Docker Image

Automated SolrCloud Bootstrap with Solr 4.8.1 running on Apache Tomcat 7.0.32 or Jetty(shipped with Solr 4.8.1) and cluster managed with ZooKeeper 3.4.6.

### Steps to run Solr Cloud

  1. The Docker Image depends on raycoding/piggybank-zookeeper Docker Image as we will be using **Zookeeper** for managing our cluster. To run Zookeeper
      - `docker pull raycoding/piggybank-zookeeper`
      - `docker run --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 raycoding/piggybank-zookeeper`
      - The above command will start Zookeeper in foreground. Note even though we have exposed 3 ports, the Zookeeper setup in this docker image is in stand-alone mode, therefore only 2181 should suffice.
      - The **--name** parameter is important as we would need to reference in our other containers.
      

  
  2. If you want to use **Jetty** as Application Server then follow only Step 2, else Step 3 for Apache Tomcat v7
      - Pull this docker image `docker pull raycoding/piggybank-solr-tomcat`
      - `sudo docker run --link zookeeper:ZK --name=solr -i -p 8983:8983 -t raycoding/piggybank-solr-tomcat /bin/bash -c 'cd /solr-dist/example && java -Dbootstrap_confdir=./solr/collection1/conf -Dcollection.configName=myconf -DzkHost=$ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT -DnumShards=3 -jar start.jar'`
      - In the above step we reference zookeeper container as created in step 1 as ZK in our new container for running tomcat and solr node. ZK_* environment variables in the container are used to locate the ZooKeeper container with zkHost params.
      - We only need to upload solr configuration once to ZooKeeper.
      - As we mentioned numShards3, lets open up two more containers for running tomcat and solr nodes.
      - Second Node - `sudo docker run --link zookeeper:ZK -i -p 8984:8983 -t raycoding/piggybank-solr-tomcat /bin/bash -c 'cd /solr-dist/example && java -DzkHost=$ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT -DnumShards=3 -jar start.jar'`
      - Similarly, Third Node - `sudo docker run --link zookeeper:ZK -i -p 8985:8983 -t raycoding/piggybank-solr-tomcat /bin/bash -c 'cd /solr-dist/example && java -DzkHost=$ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT -DnumShards=3 -jar start.jar'`
      - Voila you have Solr Cloud setup! `http://localhost:8983/solr, http://localhost://8984/solr, http://localhost://8985/solr`
      - Read Step 3 only if you want to use Apache Tomcat v7 instead of Jetty.
  
  
  3. If you want to use **Apache Tomat v7** as Application Server then follow only Step 3, else Step 2 for Jetty
      - Pull this docker image `docker pull raycoding/piggybank-solr-tomcat`
      - For the first Nodes, we will simultaneously also upload the solr configuration into ZooKeeper using Zookeeper Command Line Interface tools shipped by Solr 4.8.1 which is available in this docker image at /solr-zk-cli
      - `sudo docker run --link zookeeper:ZK --name=nodeA -i -t -p 8983:8983 -e 'SOLR_OPTS="-DzkHost=$ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT"' raycoding/piggybank-solr-tomcat /bin/bash -c 'java -classpath .:/solr-zk-cli/* org.apache.solr.cloud.ZkCLI -cmd upconfig -zkhost $ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT -confdir /solr-dist/example/solr/collection1/conf -confname example ; /usr/lib/apache-tomcat-7.0.32/bin/catalina.sh run'`
      - In the above step we reference zookeeper container as created in step 1 as ZK in our new container for running tomcat and solr node. **ZK_* environment** variables in the container are used to locate the ZooKeeper container with zkHost params.
      - We only need to upload solr configuration once to ZooKeeper.
      - Second Node, `sudo docker run --link zookeeper:ZK --name=nodeB -i -t -p 8984:8983 -e 'SOLR_OPTS="-DzkHost=$ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT"' raycoding/piggybank-solr-tomcat /bin/bash -c '/usr/lib/apache-tomcat-7.0.32/bin/catalina.sh run'`
      - Third Node, `sudo docker run --link zookeeper:ZK --name=nodeC -i -t -p 8985:8983 -e 'SOLR_OPTS="-DzkHost=$ZK_PORT_2181_TCP_ADDR:$ZK_PORT_2181_TCP_PORT"' raycoding/piggybank-solr-tomcat /bin/bash -c '/usr/lib/apache-tomcat-7.0.32/bin/catalina.sh run'`
      - Now that we have uploaded our solr configurations and three nodes are ready to serve, we can create a new collection in Solr Cloud
      - From you local host machine run `curl "http://localhost:8983/solr/admin/collections?action=CREATE&name=bazinga&numShards=3&replicationFactor=2&maxShardsPerNode=2"` or paste the same in browser.
      - Voila you have Solr Cloud setup! `http://localhost:8983/solr, http://localhost://8984/solr, http://localhost://8985/solr`


Note : For example purpose, I have bootstraped with the example solr configurations from the one shipped with Solr 4.8.1, if you need to modify the schema.xml or the whole configurations directory you can easily use that by attaching a Data Volume from your Host Machine and replace referece to '/solr-dist/example/solr/collection1/conf' to the data volume path!
