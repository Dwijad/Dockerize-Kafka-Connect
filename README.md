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
You can run the docker image if the kafka broker you want to make use of is running on PLAINTEXT or SASL_PLAINTEXT mode as described below(Use case - I and Use case - IV)

If your kafka broker is running on SASL_SSL or SSL mode then you have to rebuild the docker image incorporating the truststore and keystore file of your    kafka broker.

FROM dwijad/kafka-connect:latest
 RUN echo "===> Installing MySQL connector" \ && curl https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar --output /usr/share/java/kafka-connect-jdbc/mysql-connector-java-8.0.19.jar

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
    Description: The port number used by the worker listener and Rest server.
   
    Name: REST_ADVERTISED_HOST_NAME
    Default value: connect-worker-1
    Description: The host name advertised by the REST server. 
    
    Name: PLUGIN_PATH
    Default value: file
    Description: The locations for connectors and their specific dependent JARs

    Name: CONFIG_PROVIDERS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: CONFIG_PROVIDERS_FILE_CLASS
    Default value: org.apache.kafka.common.config.provider.FileConfigProvider
    Description: Allows variable references to be replaced with values from local files on each worker.
    
    Name: SSL_ENDPOINT_IDENTIFICATION_ALGORITHM
    Default value: Empty String
    Description: Algorithm used by kafka connect to validate Kafka server host name.
   
    Name: REQUEST_TIMEOUT_MS
    Default value: 20000
    Description: This configuration controls the maximum amount of time kafka connect will wait for the response of a request.
    
    Name: RETRY_BACKOFF_MS
    Default value: 500
    Description: The amount of time to wait by kafka connect before attempting to retry a failed fetch request to a given topic partition.
    
    Name: SECURITY.PROTOCOL
    Default value: SASL_SSL
    Description: The security protocol used by kafka connect while connecting to kafka broker.
    
    Name: SSL_PROTOCOL
    Default value: TLS
    Description: The SSL protocol used by kafka connect.
    
    Name: SSL_TRUSTSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka.truststore.jks
    Description: The SSL truststore location.

    Name: SSL_TRUSTSTORE_PASSWORD
    Default value: password
    Description: The SSL truststore password.
     
    Name: SSL_KEYSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    Description: The SSL keystore location.
    
    Name: SSL_KEYSTORE_PASSWORD
    Default value: password
    Description: The SSL keystore password.
    
    Name: SSL_KEY_PASSWORD
    Default value: password
    Description: The SSL key password.
 
    Name: CONSUMER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM
    Default value: Empty String
    Description: Algorithm used by consumer to validate Kafka server host name.
     
    Name: CONSUMER_REQUEST_TIMEOUT_MS
    Default value: 20000
    Description: The configuration controls the maximum amount of time the consumer will wait for the response of a request.
    
    Name: CONSUMER_RETRY_BACKOFF_MS
    Default value: 500
    Description: The amount of time to wait by the consumer before attempting to retry a failed fetch request to a given topic partition.
    
    Name: CONSUMER_SECURITY_PROTOCOL
    Default value: SASL_SSL
    Description: The security protocol used by consumer while connecting to kafka broker.
    
    Name: CONSUMER_SSL_PROTOCOL
    Default value: TLS
    Description: The SSL protocol used by consumer.
    
    Name: CONSUMER_SSL_TRUSTSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka.truststore.jks
    Description: The SSL truststore location for consumer. 
    
    Name: CONSUMER_SSL_TRUSTSTORE_PASSWORD
    Default value: password
    Description: The SSL truststore password for consumer.
   
    Name: CONSUMER_SSL_KEYSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    Description: The SSL keystore location for consumer. 
 
    Name: CONSUMER_SSL_KEYSTORE_PASSWORD
    Default value: password
    Description: The SSL keystore password for consumer.

    Name: CONSUMER_SSL_KEY_PASSWORD
    Default value: password
    Description: The SSL key password for consumer.
    
    Name: PRODUCER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM
    Default value: Empty String
    Description: Algorithm used by producer to validate Kafka server host name.

    Name: PRODUCER_REQUEST_TIMEOUT_MS
    Default value: 20000
    Description: The configuration controls the maximum amount of time the producer will wait for the response of a request.
    
    Name: PRODUCER_RETRY_BACKOFF_MS
    Default value: 500
    Description: The amount of time to wait by the producer before attempting to retry a failed fetch request to a given topic partition.
    
    Name: PRODUCER_SECURITY_PROTOCOL
    Default value: SASL_SSL
    Description: The security protocol used by producer while connecting to kafka broker.
    
    Name: PRODUCER_SSL_PROTOCOL
    Default value: TLS
    Description: The SSL protocol used by producer.
       
    Name: PRODUCER_SSL_TRUSTSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka.truststore.jks
    Description: The SSL truststore location for producer.
    
    Name: PRODUCER_SSL_TRUSTSTORE_PASSWORD
    Default value: password
    Description: The SSL truststore password for producer.
    
    Name: PRODUCER_SSL_KEYSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    Description: The SSL keystore location for producer.
    
    Name: PRODUCER_SSL_KEYSTORE_PASSWORD
    Default value: password
    Description: The SSL keystore password for producer.
    
    Name: PRODUCER_SSL_KEY_PASSWORD
    Default value: password
    Description: The SSL key password for producer.
    
    Name: SASL_JAAS_CONFIG
    Default value: org.apache.kafka.common.security.plain.PlainLoginModule
    Description: Specify the JAAS configuration kafka client uses to connect kafka broker.
    
    Name: PRODUCER_SASL_JAAS_CONFIG 
    Default value: org.apache.kafka.common.security.plain.PlainLoginModule
    Description: Specify the producer JAAS configuration.
    
    Name: CONSUMER_SASL_JAAS_CONFIG 
    Default value: org.apache.kafka.common.security.plain.PlainLoginModule
    Description: Specify the consumer JAAS configuration.
    
    Name: SASL_MECHANISM
    Default value: PLAIN
    Description: The sasl mechanism kafka client uses to connect Kafka broker.
    
    Name: PRODUCER_SASL_MECHANISM
    Default value: PLAIN
    Description: The SASL mechanism producer uses to connect Kafka broker.
    
    Name: CONSUMER_SASL_MECHANISM
    Default value: PLAIN
    Description: The SASL mechanism consumer uses to connect Kafka broker.
    
    Name: SASL_USER
    Default value: user1
    Description: Basic username.
    
    Name: SASL_PASSWORD
    Default value: password
    Description: Password for SASL_USER.
    
    Name: KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka.truststore.jks
    Description: SSL truststore location for key converter schema registry URL.
    
    Name: KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION 
    Default value:  /u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    Description: SSL keystore location for key converter schema registry URL.
    
    Name: KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD 
    Default value: password
    Description: The SSL keystore password for schema registry key  converter.
    
    Name: KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD 
    Default value: password
    Description: The SSL key password for schema registry key  converter.
    
    Name: KEY_CONVERTER_SCHEMA_REGISTRY_URL 
    Default value: https://127.0.0.1:8082    
    Description: Schema registry URL for key converter.

    Name: KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE
    Default value: USER_INFO    
    Description: Specifies the configuration property(ies) that provide the basic authentication credentials for key converter.
  
    Name: KEY_CONVERTER_BASIC_AUTH_USER_INFO
    Default value: user1:password    
    Description: User name and password for schema registry key converter basic authentication.
      
    Name: KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE
    Default value: PEM
    Description: The truststore type for schema registry value converter.

    Name: VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka.truststore.jks
    Description: SSL truststore location for value converter schema registry URL.
    
    Name: VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    Description: SSL keystore location for value converter schema registry URL.
    
    Name: VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD
    Default value: password
    Description: The SSL keystore password for schema registry value converter.
    
    Name: VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD
    Default value: password
    Description: The SSL key password for schema registry value converter.
     
    Name: VALUE_CONVERTER_SCHEMA_REGISTRY_URL
    Default value: https://127.0.0.1:8082
    Description: Schema registry URL for value converter.
    
    Name: VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE
    Default value: USER_INFO
    Description: Specifies the configuration property(ies) that provide the basic authentication credentials for value converter.
    
    Name: VALUE_CONVERTER_BASIC_AUTH_USER_INFO
    Default value: user1:password
    Description: User name and password for schema registry basic authentication.
    
    Name: VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE
    Default value: PEM
    Description: The truststore type for schema registry value converter.
    
    Name: SCHEMA_REGISTRY_URL
    Default value: https://127.0.0.1:8082
    Description: Schema registry URL.
    
    Name: SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD
    Default value: password
    Description: SSL truststore password while connecting to secured schema registry server.
    
    Name: SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka.truststore.jks
    Description: SSL truststore location while connecting to secured schema registry server.
    
    Name: SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD
    Default value: password
    Description: SSL keystore password while connecting to secured schema registry server.
    
    Name: SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION
    Default value: /u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    Description: SSL keystore location while connecting to secured schema registry server.
    
    Name: SCHEMA_REGISTRY_SSL_KEY_PASSWORD
    Default value: password
    Description: SSL key password while connecting to secured schema registry server.
    
    Name: SCHEMA_REGISTRY_BASIC_AUTH_CREDENTIALS_SOURCE
    Default value: USER_INFO
    Description: Specifies the configuration property(ies) that provide the basic authentication credentials.
    
    Name: SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO
    Default value: user1:password
    Description: User name and password for schema registry basic authentication.
    
    Name: LISTENERS
    Default value: 8081
    Description: The worker listener and Rest server port number.
    
    Name: REST_ADVERTISED_LISTENER
    Default value: 8081
    Description: Configures the listener used for communication between Workers.
    
    Name: KAFKA_JMX_PORT
    Default value: 8080
    Description: The JMX Port.
    
    Name: KAFKA_JMX_HOSTNAME
    Default value: connect-worker-1
    Description: The hostname associated with locally created remote objects.
    
    Name: KAFKA_JMX_OPTS
    Default value: "-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml"
    Description: The JMX options.

    Name: BROKER_LISTENER_MODE
    Default value: SASL_SSL
    Description: Kafka Broker listener mode.
    
    Name: SCHEMA_REGISTRY_MODE
    Default value: NULL
    Description: Kafka connect connection protocol to schema registry server. Values can be either HTTP or HTTPS


https://github.com/1ambda/docker-kafka-connect
https://github.com/SAP/kafka-connect-sap
https://github.com/debezium/debezium
https://github.com/wurstmeister/kafka-docker
https://joelforjava.com/blog/2019/10/27/adding-ssl-encryption-to-kafka-connector.html 
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5ODA0OTQzNDIsLTEyOTkzMTI2MzIsMT
U3OTU1ODc1OCw4MTIwNDA4MzMsMTM0MjExNzk5MiwtMTE2NzU3
MDEwOSwyMzE4NDU2MTAsLTE4Mzg2Mzk4NTAsLTg0MTk3MDQ4OC
w3MDQxMzE0MTcsLTExMDU2NDI2MzYsNzAxMDMyNjk1LC0xNTgy
MDA4MzAsNzU4MjMzMzUxLC0xMzc3MTA1NjE1LDIwNDU4NjM0Mi
wxMDkzMzg4NDE0LDMzNjUwMjQ2MywxODk4MzEwNTQ0LC0yMTk0
NjA2NTRdfQ==
-->