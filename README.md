# Dockerize Confluent Kafka Connect Worker

Build docker image for secured confluent kafka Connect worker in your local docker environment with Debzeium MySQL connector and JDBC source/sink connector. Subsequently deploy the kafka connect worker in kubernetes cluster in a distributed way. 

The image is available directly from [Docker Hub](https://hub.docker.com/r/wurstmeister/kafka/)
### Prerequisite
 - You have a local kafka cluster running in any of the PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL mode.
 -  You have a schema registry server running with/without SSL mode.
 -  You want to convert data for Kafka Connect to and from in Avro format.
 -  For testing query based CDC connector a MySQL DB server is configured and running.
 -  For rebuilding Docker image, install docker with buildx plugin as described [here](https://docs.docker.com/engine/install/ubuntu/).

### Usage
#### Use case - I
Run Kafka connect worker with Kafka broker listener configured in PLAINTEXT mode. The schema registry is running in either secured or non-secured mode.

    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest 

#### Use case - II
Run Kafka connect worker with Kafka broker listener configured in SSL mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest

#### Use case - III
Run Kafka connect worker with Kafka broker listener configured in SASL_SSL mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SASL_SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest

#### Use case - IV
Run Kafka connect worker with Kafka broker listener configured in SASL_PLAINTEXT mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SASL_PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest

### Using docker compose

### Docker environment variable
    Name: UID
    Default value: 1000
    Description: User ID used to build Dockerfile   

    Name: GID
    Default value: 1000
    Description: Group ID used to build Dockerfile

    Name: USERNAME 
    Default value: kafka
    Description: Kafka files/folder owner 
  
    Name: BOOTSTRAP_SERVERS
    Default value: test-kafka.default.svc.cluster.local:9092
    Description: A list of host/port pairs to use for establishing the initial connection to the Kafka cluster.
    
    Name: GROUP_ID
    Default value: connect-cluster
    Description: A unique string that identifies the Connect cluster group this Worker belongs to.
   
    Name: KEY_CONVERTER
    Default value: org.apache.kafka.connect.json.JsonConverter
    Description: Converter class for key Connect data.
    
    Name: VALUE_CONVERTER
    Default value: org.apache.kafka.connect.json.JsonConverter
    Description: Converter class for value Connect data.
    
    Name: KEY_CONVERTER_SCHEMAS_ENABLE
    Default value: false
    Description: Exclude/Include the verbose schema information(Key) from each record.
    
    Name: VALUE_CONVERTER_SCHEMAS_ENABLE
    Default value: false
    Description: Exclude/Include the verbose schema information(Value) from each record.
    
    Name: OFFSET_STORAGE_TOPIC
    Default value: connect-offsets
    Description: The name of the topic where connector and task configuration offsets are stored.
    
    Name: CONFIG_STORAGE_TOPIC
    Default value: connect-configs
    Description: The name of the topic where connector and task configuration data are stored.
    
    Name: STATUS_STORAGE_TOPIC
    Default value: connect-status
    Description: The name of the topic where connector and task configuration status updates are stored.
    
    Name: REST_HOST_NAME
    Default value: Hostname of the container
    Description: The host name for REST server.
    
    Name: LISTENER_PORT
    Default value: 8081
    Description: The worker listener and Rest server port number.
    ---
    Name: REST_ADVERTISED_HOST_NAME
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PLUGIN_PATH
    Default value: 8081
    Description: The worker listener and Rest server port number.

    Name: CONFIG_PROVIDERS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONFIG_PROVIDERS_FILE_CLASS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: SSL_ENDPOINT_IDENTIFICATION_ALGORITHM
    Default value: 8081
    Description: The worker listener and Rest server port number.
   
    Name: REQUEST_TIMEOUT_MS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: RETRY_BACKOFF_MS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: SECURITY.PROTOCOL
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: SSL_PROTOCOL
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: SSL_TRUSTSTORE_LOCATION
    Default value: 8081
    Description: The worker listener and Rest server port number.

    Name: SSL_TRUSTSTORE_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
     
    Name: SSL_KEYSTORE_LOCATION
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: SSL_KEYSTORE_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: SSL_KEY_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
 
    Name: CONSUMER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM
    Default value: 8081
    Description: The worker listener and Rest server port number.
     
    Name: CONSUMER_REQUEST_TIMEOUT_MS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONSUMER_RETRY_BACKOFF_MS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONSUMER_SECURITY_PROTOCOL
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONSUMER_SSL_PROTOCOL
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONSUMER_SSL_TRUSTSTORE_LOCATION
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONSUMER_SSL_TRUSTSTORE_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
   
    Name: CONSUMER_SSL_KEYSTORE_LOCATION
    Default value: 8081
    Description: The worker listener and Rest server port number. 
 
    Name: CONSUMER_SSL_KEYSTORE_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.

    Name: CONSUMER_SSL_KEY_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM
    Default value: 8081
    Description: The worker listener and Rest server port number.

    Name: PRODUCER_REQUEST_TIMEOUT_MS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_RETRY_BACKOFF_MS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SECURITY_PROTOCOL
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SSL_PROTOCOL
    Default value: 8081
    Description: The worker listener and Rest server port number.
       
    Name: PRODUCER_SSL_TRUSTSTORE_LOCATION
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SSL_TRUSTSTORE_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SSL_KEYSTORE_LOCATION
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SSL_KEYSTORE_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: PRODUCER_SSL_KEY_PASSWORD
    Default value: 8081
    Description: The worker listener and Rest server port number.
    

    SASL_JAAS_CONFIG \
    PRODUCER_SASL_JAAS_CONFIG \
    CONSUMER_SASL_JAAS_CONFIG \
    SASL_MECHANISM \
    PRODUCER_SASL_MECHANISM \
    CONSUMER_SASL_MECHANISM \
    SASL_USER \
    SASL_PASSWORD \
    KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION \
    KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION \
    KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD \
    KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD \
    KEY_CONVERTER_SCHEMA_REGISTRY_URL \
    KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE \
    KEY_CONVERTER_BASIC_AUTH_USER_INFO \
    KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE \
    VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION \
    VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION \
    VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD \
    VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD \
    VALUE_CONVERTER_SCHEMA_REGISTRY_URL \
    VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE \
    VALUE_CONVERTER_BASIC_AUTH_USER_INFO \
    VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE \
    SCHEMA_REGISTRY_URL \
    SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD \
    SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION \
    SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD \
    SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION \
    SCHEMA_REGISTRY_SSL_KEY_PASSWORD \
    SCHEMA_REGISTRY_BASIC_AUTH_CREDENTIALS_SOURCE \
    SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO \
    LISTENERS \
    REST_ADVERTISED_LISTENER \
    KAFKA_JMX_PORT \
    KAFKA_JMX_HOSTNAME \
    KAFKA_JMX_OPTS \
    BROKER_LISTENER_MODE \
    SCHEMA_REGISTRY_MODE \
    KEY_CONVERTER_SCHEMAS_ENABLE \
    VALUE_CONVERTER_SCHEMAS_ENABLE

https://github.com/1ambda/docker-kafka-connect
https://github.com/SAP/kafka-connect-sap
https://github.com/debezium/debezium
https://github.com/wurstmeister/kafka-docker
https://joelforjava.com/blog/2019/10/27/adding-ssl-encryption-to-kafka-connector.html 
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTEyODAzNDY0Nyw3NTgyMzMzNTEsLTEzNz
cxMDU2MTUsMjA0NTg2MzQyLDEwOTMzODg0MTQsMzM2NTAyNDYz
LDE4OTgzMTA1NDQsLTIxOTQ2MDY1NCwtMjAyMzc5MjUyMSwtMT
E5ODAzNTI5MCwtNTgxOTg5ODQ0LDExMzk2OTMwNjEsMjc4NTQz
ODE0LDkyOTA2MzYxOSw5OTExMTMxNjQsMjAxNDEyMzc2NSwtOD
c4NzcxMDE3LC00ODI0Mjk2NDcsNzE5MjA1MjYwXX0=
-->