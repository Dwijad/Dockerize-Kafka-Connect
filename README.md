# Dockerize Confluent Kafka Connect

Build and run docker image for secured Confluent kafka Connect worker with Debzeium `MySQL` connector and `JDBC` source/sink connector. Run the docker image using docker CLI or use a kubernetes manifest to create kafka connect cluster in a distributed way.  Further, Kafka connect will be configured for converting data to and from in `AVRO` format.

The image is available in the [Docker Hub](https://hub.docker.com/r/dwijad/kafka-connect)

### Prerequisite
#### To build the docker image 

 - Install docker with buildx plugin as described [here](https://docs.docker.com/engine/install/ubuntu/)
 
 #### To run the docker image
 - A kafka cluster configured in any of the `PLAINTEXT`, `SSL`, `SASL_PLAINTEXT`, `SASL_SSL` mode.
 -  A schema registry server running with/without `SSL` mode
 -  For testing query/log based CDC connector a `MySQL` DB server is already configured .

### About AVRO converter

Converters change the format of data from one format to another. The default converter format for kafka connect is `JSON` converter. `AVRO` format is considered to be the stable and the recommended format for data conversion. In case of source connector, `AVRO` converter takes input from `JDBC` driver and convert it to `AVRO` format before sending it to kafka topic.

![kc](https://github.com/Dwijad/Dockerize-Kafka-Connect-Worker/assets/12824049/cab48827-6174-4e14-b27f-ca5023d41985)

### Build

To build from scratch, clone the repo and copy kafka keystore/truststore certificates and public certificate authority (CA) file of kafka broker to `script/ca` folder.

    $ git clone https://github.com/Dwijad/Dockerize-Kafka-Connect.git
    $ copy {ca-cert, kafka.truststore.jks, kafka.keystore.jks} to ~/Dockerize-Kafka-Connect/script/ca 
    $ DOCKER_BUILDKIT=1 docker buildx build -t dwijad/kafka-connect:latest --no-cache --progress=plain .

Or rebuild the existing image using a `Dockerfile` like:
    
    FROM dwijad/kafka-connect:latest
    RUN echo "===> Updating  keystore and truststore files===" \ 
    &&  ADD  --chown=kafka:kafka  --chmod=755  your-local-folder/kafka-broker-0.keystore.jks $KAFKA_HOME/script/ca \
    &&  ADD  --chown=kafka:kafka  --chmod=755  your-local-folder/kafka.truststore.jks $KAFKA_HOME/script/ca \
    &&  ADD  --chown=kafka:kafka  --chmod=755  your-local-folder/ca-cert $KAFKA_HOME/script/ca
 
 Rebuild
 

    $ DOCKER_BUILDKIT=1 docker buildx build -t dwijad/kafka-connect:latest --no-cache --progress=plain .
     
### Run

Create container from docker image if the kafka broker's listener mode is configured on `PLAINTEXT` or `SASL_PLAINTEXT`  as described below (Use case - I and Use case - IV)

If the kafka broker is running on `SASL_SSL` or `SSL` mode then rebuild the docker image as described above by incorporating the truststore/keystore file and public CA cert of  kafka broker. (Use case II and  Use case III)

#### Use case - I

Run the Kafka connect docker image when Kafka broker listener is configured in `PLAINTEXT` mode. The schema registry is configued with `https` or `http`.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="PLAINTEXT" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="PLAINTEXT" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="PLAINTEXT" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="PLAINTEXT" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.plaintext.with.sr.http](https://gist.github.com/Dwijad/4731a41a694eeb23fc3d9d5a389c6120) and [connect-distributed.properties.plaintext.with.sr.https](https://gist.github.com/Dwijad/e02e4d92e159fa83b77f7acf746a11b2)

#### Use case - II
Run Kafka connect worker with Kafka broker listener configured in `SSL` mode. The schema registry is configued with `https` or `http`.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SSL" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SSL" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest         

    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SSL" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SSL" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.ssl.with.sr.http](https://gist.github.com/Dwijad/770863589f3f8aa6b4c8516c85ce3ce6) and [connect-distributed.properties.ssl.with.sr.https](https://gist.github.com/Dwijad/56b23e078bb7ac374ebe5ce45f2b8ff9)

#### Use case - III
Run Kafka connect worker with Kafka broker listener configured in `SASL_SSL` mode. The schema registry is configued with `https` or `http`.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_SSL" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SASL_SSL" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_SSL" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_SSL" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.sasl_ssl.with.sr.http](https://gist.github.com/Dwijad/af69aefba552fdbbb73f30d4640b3601) and [connect-distributed.properties.sasl_ssl.with.sr.https](https://gist.github.com/Dwijad/79992c6bf65399fe84254abe9564b0e4)

#### Use case - IV
Run Kafka connect worker with Kafka broker listener configured in `SASL_PLAINTEXT` mode. The schema registry is configued with `https` or `http`.

    Schema registry is running in http
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e LISTENER_PORT="8081" -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTP" -e BROKER_LISTENER_MODE="SASL_PLAINTEXT" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://sr-service-http.default.svc:8081" dwijad/kafka-connect:latest 
    
    Schema registry is running in https
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e LISTENER_PORT="8081"  -e REST_ADVERTISED_LISTENER="http" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_PLAINTEXT" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest

Generated connect distributed properties files are [connect-distributed.properties.sasl_plaintext.with.sr.http](https://gist.github.com/Dwijad/647aa86f9313bfbac922e9f5bc5254ec)  and [connect-distributed.properties.sasl_plaintext.with.sr.https](https://gist.github.com/Dwijad/931b351accadb66b8ff12ad89cab043f)

### JMX
To enable JMX, use the environmental variable `KAFKA_JMX_PORT` and `KAFKA_JMX_OPTS` The value for the environmental variable `KAFKA_JMX_HOSTNAME` will be picked up from container.

    $ docker run -d --name=connect-worker-1 -e KAFKA_JMX_PORT="8080" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=$(KAFKA_JMX_HOSTNAME) -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml"

Location for prometheus java agent: `/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar`

Location for JMX configuration for Kafka connect metrics: `/u01/cnfkfk/etc/kafka/kafka-connect.yml`


### Docker environment variable

Environmental variables used in the Dockerfile are listed below.

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
    
    Name: LISTENER_PORT
    Default value: 8081
    Description: The port number used by the worker listener and Rest server.
        
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
    
    Name: SECURITY_PROTOCOL
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
    
    Name: KAFKA_OPTS
    Default value: -Dlogging.level=TRACE
    Description: Environment variable to set kafka connect server settings  
    
    Name: KAFKA_HEAP_OPTS
    Default value: -Xmx512M -Xms512M
    Description: Set the JVM heap size on the host
    

### Configure MySQL for log based change data capture(CDC)

Configure MySQL server for log based CDC. Edit MySQL server configuration file to include the following stanzas.

    [mysql]
    server-id=184054  
    binlog_format=ROW  
    binlog_row_image=FULL  
    log_bin=mysql-bin      
    expire_logs_days=15  
    gtid_mode=ON  
    enforce_gtid_consistency=ON  
    interactive_timeout=500  
    wait_timeout=500  
    binlog_rows_query_log_events=ON

Create a new user with the name "cdcuser" and a choosen password "PasswOrd@123".  Grant  necessary privileges.

    CREATE USER 'cdcuser'@'%' IDENTIFIED BY 'PasswOrd@123';  
    GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'cdcuser'@'%';  
    ALTER USER 'cdcuser'@'%' IDENTIFIED WITH mysql_native_password BY 'PasswOrd@123';  
    FLUSH PRIVILEGES;

Set the GTID Mode/GTID Consistency     
     
    SET @@GLOBAL.ENFORCE_GTID_CONSISTENCY = ON;     
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

Restart MySQL server.

    sudo systemctl restart mysqld

#### Create MySQL database/table

Create a databse/table and push some records

    -- Create a test database  
    CREATE DATABASE saleDB; 
    USE saleDB;  
    
    -- Create table and push some records  
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
#### Kafka env variable in container

Exec into the container to list the environment variable.

    kafka@connect-worker-1:~$ env | grep KAFKA
    KAFKA_JMX_PORT=8080
    KAFKA_JMX_OPTS=-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml
    KAFKA_OPTS=-Dlogging.level=INFO
    KAFKA_HOME=/u01/cnfkfk
    KAFKA_HEAP_OPTS=-Xmx512M -Xms512M
    KAFKA_VERSION=3.5.0
    KAFKA_JMX_HOSTNAME=connect-worker-1


#### Verify Kafka Connect and JMX Port

    $ netstat -pltn
    Active Internet connections (only servers)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
    tcp        0      0 10.244.5.31:8081        0.0.0.0:*               LISTEN      237/java            
    tcp        0      0 0.0.0.0:38421           0.0.0.0:*               LISTEN      237/java            
    tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      237/java

#### Check kafka connect logs

    $ tail -f logs/connect-worker-trace.log 
    [2024-02-06 15:41:23,868] TRACE [Consumer clientId=connect-cluster--configs, groupId=connect-cluster] Polling for fetches with timeout 2147475609 (org.apache.kafka.clients.consumer.KafkaConsumer)
    [2024-02-06 15:41:23,868] DEBUG [Consumer clientId=connect-cluster--offsets, groupId=connect-cluster] Sending READ_UNCOMMITTED IncrementalFetchRequest(toSend=(), toForget=(), toReplace=(), implied=(connect-offsets-0), canUseTopicIds=True) to broker test-kafka-broker-1.test-kafka-broker-headless.default.svc.cluster.local:9092 (id: 101 rack: null) (org.apache.kafka.clients.consumer.internals.AbstractFetch)
    [2024-02-06 15:41:23,868] DEBUG [Consumer clientId=connect-cluster--offsets, groupId=connect-cluster] Adding pending request for node test-kafka-broker-1.test-kafka-broker-headless.default.svc.cluster.local:9092 (id: 101 rack: null) (org.apache.kafka.clients.consumer.internals.AbstractFetch)
    [2024-02-06 15:41:23,868] TRACE [Consumer clientId=connect-cluster--offsets, groupId=connect-cluster] Polling for fetches with timeout 2147476777 (org.apache.kafka.clients.consumer.KafkaConsumer)

`TRACE` debug log  consumes considerable amount of space. So for sufficiently moderate number of connectors, create a cron job to remove the old zipped log files.

#### View loaded connectors plugins in the connect cluster

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
Run kafka avro console consumer

    $ kafka-avro-console-consumer --bootstrap-server test-kafka.default.svc.cluster.local:9092 --topic schema-changes.sales --property schema.registry.url="https://sr-service-https.default.svc:8082"  --consumer.config /u01/cnfkfk/etc/ssl/client.properties --from-beginning
    {"id":1,"product_name":"Product_1","product_code":101,"sale_time":{"long":1707146905000}}
    {"id":2,"product_name":"Product_2","product_code":102,"sale_time":{"long":1707146905000}}
    {"id":3,"product_name":"Product_3","product_code":103,"sale_time":{"long":1707146906000}}
    ...
    ...

#### Submit a log based CDC source connector

The Debezium MySQL connector reads the binlog, produces change events for row-level `INSERT`, `UPDATE`, and `DELETE` operations, and emits the change events to a Kafka topics. Client applications read those Kafka topics.

The following connector will make use of Debezium source connector which records all changes made to the database and push these changes to the configured kafka topic when some insert/update/delete event  occur in the database.  More on Debezium MySQL connector can be found [here](https://debezium.io/documentation/reference/stable/connectors/mysql.html).

    curl -k -X POST -H "Content-Type: application/json" --data '{
        "name": "sales_source",
        "config": {
                   "connector.class": "io.debezium.connector.mysql.MySqlConnector",
                   "database.hostname": "ec2-54-151-173-22.ap-southeast-1.compute.amazonaws.com",
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
    }' https://connect-worker-1:8082/connectors/ | jq .

While the connector is loading, update a record in the `MySQL` database and simultaneously  run `kafka-avro-console-consumer` to view the change events.

    mysql> update sale set product_code=106 where product_name='Product_3';
    Query OK, 1 row affected (0.01 sec)
    Rows matched: 1  Changed: 1  Warnings: 0

In case, broker is configured with `SASL_SSL`, `SSL` or `SASL_PLAINTEXT`, a kafka client properties files needs to be configured to run kafka avro console consumer or producer.

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

Run kafka avro console consumer to view the change events.

    $ export SCHEMA_REGISTRY_OPTS="-Djavax.net.ssl.keyStore=/u01/cnfkfk/etc/ssl/kafka-broker-0.keystore.jks -Djavax.net.ssl.trustStore=/u01/cnfkfk/etc/ssl/kafka.truststore.jks -Djavax.net.ssl.keyStorePassword=password -Djavax.net.ssl.trustStorePassword=password"
    $ kafka-avro-console-consumer --bootstrap-server test-kafka.default.svc.cluster.local:9092 --topic sales_service.saleDB.sale --property schema.registry.url="https://sr-service-https.default.svc:8082"  --consumer.config /u01/cnfkfk/etc/ssl/client.properties --from-beginning
    {"before":{"sales_service.saleDB.sale.Value":{"id":3,"product_name":"Product_3","product_code":109,"sale_time":{"string":"2024-02-07T09:18:23Z"}}},"after":{"sales_service.saleDB.sale.Value":{"id":3,"product_name":"Product_3","product_code":106,"sale_time":{"string":"2024-02-07T09:18:23Z"}}},"source":{"version":"2.4.2.Final","connector":"mysql","name":"sales_service","ts_ms":1707311828000,"snapshot":{"string":"false"},"db":"saleDB","sequence":null,"table":{"string":"sale"},"server_id":184054,"gtid":{"string":"937de382-c598-11ee-8fc9-060947aa73f3:16"},"file":"mysql-bin.000005","pos":3092,"row":0,"thread":{"long":58},"query":null},"op":"u","ts_ms":{"long":1707311828997},"transaction":null}
    ...
    ...

### References:
 - https://docs.confluent.io/platform/current/connect/index.html
 - https://debezium.io/documentation/reference/stable/connectors/mysql.html


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTI4Mjc2NDk1MCwxOTIyNzUzNDY3LC0xMT
AyODU2MjA1LC0zNzAxNTk5MjAsLTExMDExMzg3MjEsLTk3MDk0
OTIzMiwtODYxMTY3MDg0LDU0Mjk0NjgzMCwtMjYyMzUyMTM4LD
EzNTg0MzQ3NjgsMTgyMzcxODEwNywxNzU3ODU5NTQzLDExMDU4
NDk4MjcsLTcxMzU4OTE3NywtMjAxMDU0MTk3NiwxMzQyMjUxMj
c4LC0zNjU3NzE5MDEsODA5NzAwNDg3LC05NjUzNDg3ODAsLTEw
ODIyNDUzMzhdfQ==
-->