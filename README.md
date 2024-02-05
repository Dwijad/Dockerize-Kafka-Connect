# Dockerize Confluent Kafka Connect Worker

Build docker image for secured confluent kafka Connect worker in your local docker environment with Debzeium MySQL connector and JDBC source/sink connector. Subsequently deploy the kafka connect worker in kubernetes cluster in a distributed way. 

The image is available in the [Docker Hub](https://hub.docker.com/r/wurstmeister/kafka/)
### Prerequisite
 - You have a local kafka cluster running in any of the PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL mode.
 -  You have a schema registry server running with/without SSL mode.
 -  You want to convert data for Kafka Connect to and from in Avro format.
 -  For testing query based CDC connector a MySQL DB server is configured and running.
 -  For rebuilding Docker image, install docker with buildx plugin as described [here](https://docs.docker.com/engine/install/ubuntu/).

### Usage
You can run the docker image if the kafka broker you want to make use of is running on PLAINTEXT or SASL_PLAINTEXT mode as described below(Use case - I and Use case - IV)

If your kafka broker is running on SASL_SSL or SSL mode then you have to rebuild the docker image by incorporating the truststore/keystore file and public CA cert of your  kafka broker.

    FROM dwijad/kafka-connect:latest
    RUN echo "===> Updating  keystore and truststore files===" \ 
    &&  ADD  --chown=kafka:kafka  --chmod=755  your-local-folder/kafka-broker-0.keystore.jks $KAFKA_HOME/script/ca \
    &&  ADD  --chown=kafka:kafka  --chmod=755  your-local-folder/kafka.truststore.jks $KAFKA_HOME/script/ca \
    &&  ADD  --chown=kafka:kafka  --chmod=755  your-local-folder/ca-cert $KAFKA_HOME/script/ca

Build the image

    $ DOCKER_BUILDKIT=1 docker buildx build -t dwijad/kafka-connect:latest --no-cache --progress=plain .

Now you can run the kafka connect docker image when the broker is using either of the SASL_SSL or SSL mode by using use case - II or use case IV.

#### Use case - I
Run Kafka connect worker with Kafka broker listener configured in PLAINTEXT mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.plaintext.with.sr.http](https://gist.github.com/Dwijad/4731a41a694eeb23fc3d9d5a389c6120) and [connect-distributed.properties.plaintext.with.sr.https](https://gist.github.com/Dwijad/e02e4d92e159fa83b77f7acf746a11b2)

#### Use case - II
Run Kafka connect worker with Kafka broker listener configured in SSL mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest         

    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.ssl.with.sr.http](https://gist.github.com/Dwijad/770863589f3f8aa6b4c8516c85ce3ce6) and [connect-distributed.properties.ssl.with.sr.https](https://gist.github.com/Dwijad/56b23e078bb7ac374ebe5ce45f2b8ff9)

#### Use case - III
Run Kafka connect worker with Kafka broker listener configured in SASL_SSL mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SASL_SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_SSL" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.sasl_ssl.with.sr.http](https://gist.github.com/Dwijad/af69aefba552fdbbb73f30d4640b3601) and [connect-distributed.properties.sasl_ssl.with.sr.https](https://gist.github.com/Dwijad/79992c6bf65399fe84254abe9564b0e4)

#### Use case - IV
Run Kafka connect worker with Kafka broker listener configured in SASL_PLAINTEXT mode. The schema registry is running in either secured or non-secured mode.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SASL_PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_PLAINTEXT"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.sasl_plaintext.with.sr.http](https://gist.github.com/Dwijad/647aa86f9313bfbac922e9f5bc5254ec)  and [connect-distributed.properties.sasl_plaintext.with.sr.https](https://gist.github.com/Dwijad/931b351accadb66b8ff12ad89cab043f)

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

### Configure MySQL for log based change data capture(CDC)

Configure MySQL server for log based CDC. Edit MySQL server configuration file to include the following stanzas.

    [mysql]  
    binlog_format=ROW  
    binlog_row_image=FULL  
    log_bin=mysql-bin      
    expire_logs_days=15  
    gtid_mode=ON  
    enforce_gtid_consistency=ON  
    interactive_timeout=500  
    wait_timeout=500  
    binlog_rows_query_log_events=ON

Create a new user with the name "cdcuser" and password "PasswOrd@123", and grant  necessary privileges.

    CREATE USER 'cdcuser'@'%' IDENTIFIED BY 'PasswOrd@123';  
    GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'cdcuser'@'%';  
    ALTER USER 'cdcuser'@'%' IDENTIFIED WITH mysql_native_password BY 'PasswOrd@123';  
    FLUSH PRIVILEGES;

Set the GTID Mode/GTID Consistency 

    SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = OFF;  
    SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = ON;  
    SET @@GLOBAL.GTID_MODE = OFF;  
    SET @@GLOBAL.GTID_MODE = OFF_PERMISSIVE;  
    SET @@GLOBAL.GTID_MODE = ON_PERMISSIVE;

Check if the following table shows a value of '0'

    mysql> SHOW STATUS LIKE 'ONGOING_ANONYMOUS_TRANSACTION_COUNT';
    +-------------------------------------+-------+
    | Variable_name                       | Value |
    +-------------------------------------+-------+
    | Ongoing_anonymous_transaction_count | 0     |
    +-------------------------------------+-------+
    1 row in set (0.01 sec)


Again change the GTID Mode to “ON” and then exit the MySQL shell.

    SET @@GLOBAL.GTID_MODE = ON;
    exit

Restart the MySQL server.

    sudo systemctl restart mysqld

#### Create MySQL database table

Create a table and push some records

    -- Create a test database  
    CREATE DATABASE saleDB; 
    USE saleDB;  
    
    -- Create and push some records  
    CREATE TABLE sale (  
    id INTEGER ZEROFILL NOT NULL AUTO_INCREMENT,  
    product_name VARCHAR(255) NOT NULL,  
    product_code INTEGER NOT NULL,
    sale_time TIMESTAMP,  
    PRIMARY KEY(id)  
    );  
    
    -- Insert test values  
    INSERT INTO sale(product_name, product_code, sale_time)  
    VALUES ('Product_1', 101, CURRENT_TIMESTAMP);  
    INSERT INTO sale(product_name, product_code, sale_time)  
    VALUES ('Product_2', 102, CURRENT_TIMESTAMP);  
    INSERT INTO sale(product_name, product_code, sale_time)  
    VALUES ('Product_3', 103, CURRENT_TIMESTAMP);  

### Test

#### Check loaded connectors plugins in the connect cluster
Post a curl request through workers REST interface to view the loaded plugins:

    $ curl -k --location --request GET 'https://connect-worker-1:8081/connector-plugins' | jq 
    [
      {
        "class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "type": "sink",
        "version": "10.7.4"
      },
      {
        "class": "io.confluent.connect.jdbc.JdbcSourceConnector",
        "type": "source",
        "version": "10.7.4"
      },
      {
        "class": "io.debezium.connector.mysql.MySqlConnector",
        "type": "source",
        "version": "2.4.2.Final"
      },
      ...
      ...

  
#### Submit a query based CDC source connector
This connector will make use of JDBC source connector to fetch all the records from the database(bulk mode) to a kafka topic.

    $ curl -k -X POST -H "Content-Type: application/json" --data '{          
       "name": "sale_saleDB",
       "config": {
                    "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
                    "tasks.max": "1",
                    "connection.user": "cdcuser",
                    "connection.password": "PasswOrd@123",
                    "connection.url": "jdbc:mysql://ec2-13-214-23-223.ap-southeast-1.compute.amazonaws.com:3306/saleDB",
                    "query": "select * from sale",
                    "key.converter": "io.confluent.connect.avro.AvroConverter",
                    "key.converter.schema.registry.url": "https://sr-service-https.default.svc:8082",
                    "value.converter": "io.confluent.connect.avro.AvroConverter",
                    "value.converter.schema.registry.url": "https://sr-service-https.default.svc:8082",
                    "mode": "bulk",
                    "topic.prefix": "sale"
       }
    }' https://connect-worker-1:8081/connectors/ | jq .

#### Check connector status

    $ curl -k -s https://connect-worker-1:8081/connectors/sale_saleDB/status | jq
    {
      "name": "sale_saleDB",
      "connector": {
        "state": "RUNNING",
        "worker_id": "connect-worker-1:8081"
      },
      "tasks": [
        {
          "id": 0,
          "state": "RUNNING",
          "worker_id": "connect-worker-1:8081"
        }
      ],
      "type": "source"
    }

#### Submit a log based CDC source connector

The Debezium MySQL connector reads the binlog, produces change events for row-level `INSERT`, `UPDATE`, and `DELETE` operations, and emits the change events to a Kafka topics. Client applications read those Kafka topics.

The following connector will make use of Debezium source connector which records all changes made to the database when some insert/update/delete event  occur in the database.

    curl -k -X POST -H "Content-Type: application/json" --data '{
        "name": "sales-connector",
        "config": {
                   "connector.class": "io.debezium.connector.mysql.MySqlConnector",
                   "database.hostname": "host.minikube.internal",
                   "database.port": "3306",
                   "database.user": "cdcuser",
                   "database.password": "PasswOrd@123",
                   "database.server.id": "184054",
                   "topic.prefix": "sales_service",
                   "database.include.list": "saleDB",
                   "schema.history.internal.kafka.bootstrap.servers": "test-kafka.default.svc.cluster.local:9092",
                   "schema.history.internal.kafka.topic": "schema-changes.sales",
                   "key.converter": "io.confluent.connect.avro.AvroConverter",
                   "value.converter": "io.confluent.connect.avro.AvroConverter",
                   "key.converter.schema.registry.url": "https://sr-service-https.default.svc:8082",
                   "value.converter.schema.registry.url": "https://sr-service-https.default.svc:8082"
        }
    }' https://connect-worker-1:8081/connectors/ | jq .

While the connector is loading, Run `kafka-avro-console-consumer` to view the change events.

Firstly create `client.properties` file.

    cat << EOF > /u01/cnfkfk/etc/ssl/client.properties
    security.protocol=SASL_SSL
    sasl.mechanism=SCRAM-SHA-256
    sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
        username="user1" \
        password="password";
    ssl.truststore.type=JKS
    ssl.truststore.location=/u01/cnfkfk/etc/ssl/kafka.truststore.jks
    ssl.truststore.password=password
    ssl.keystore.type=JKS
    ssl.keystore.location=/u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks
    ssl.keystore.password=password
    ssl.endpoint.identification.algorithm=
    EOF

Now run kafka avro console consumer.

    $ export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.keyStore=/u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks -Djavax.net.ssl.trustStore=/u01/cnfkfk/etc/ssl/kafka.truststore.jks -Djavax.net.ssl.keyStorePassword=password -Djavax.net.ssl.trustStorePassword=password"
    $ kafka-avro-console-consumer --bootstrap-server test-kafka.default.svc.cluster.local:9092 --topic test --property schema.registry.url="https://sr-service-https.default.svc:8082"  --consumer.config /u01/cnfkfk/etc/ssl/client.properties --from-beginning


https://github.com/1ambda/docker-kafka-connect
https://github.com/SAP/kafka-connect-sap
https://github.com/debezium/debezium
https://github.com/wurstmeister/kafka-docker
https://joelforjava.com/blog/2019/10/27/adding-ssl-encryption-to-kafka-connector.html 
https://stackoverflow.com/questions/40889743/string-operation-on-env-variables-on-kubernetes

https://materialize.com/guides/mysql-cdc/ 
https://debezium.io/documentation/reference/stable/connectors/mysql.html 
<!--stackedit_data:
eyJoaXN0b3J5IjpbMjY3MTIyMjU1LDE0MDg3MjE5ODIsLTEwMT
E3NjkyNjQsMjM1MDk1OTQ4LDIwMDUxMjE3NjIsLTE2NDQ4OTI5
NiwxMTg2NzA1MTEsLTE4MTI1NTk0MTAsNDgxOTY5NzgyLC00Mz
U5NDc3OTgsLTExMzYyNjYyNzksMTI4NDQxMDgwMCwxMjI0NTcw
OTgxLC0zMTU5Mjk5NzMsLTEwNTEzNDAzNzMsMTIzMDkxMDUwNi
w0ODEwMzMzNzksLTE1MTY2OTc2NzUsODkzMjY2NDA1LDE5OTM5
Nzk5OF19
-->