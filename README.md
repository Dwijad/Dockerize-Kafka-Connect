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
    $ docker run -d --name=connect-worker-1 -e BOOTSTRAP_SERVERS="kafka:9092" -e SECURITY_PROTOCOL="SASL_PLAINTEXT" -e REST_HOST_NAME="connect-worker-1"  -e LISTENER_PORT="8081" -e REST_ADVERTISED_HOST_NAME="connect-worker-1"  -e REST_ADVERTISED_LISTENER="https" -e SCHEMA_REGISTRY_MODE="HTTPS" -e BROKER_LISTENER_MODE="SASL_SSL"  -e KAFKA_JMX_HOSTNAME="connect-worker-1" -e KAFKA_JMX_PORT="8080" -e SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.rmi.port=8080 -Djava.rmi.server.hostname=connect-worker-1 -javaagent:/u01/cnfkfk/etc/kafka/jmx_prometheus_javaagent-0.20.0.jar=8080:/u01/cnfkfk/etc/kafka/kafka-connect.yml" -e SASL_USER=user1 -e SASL_PASSWORD=password -e KEY_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" -e VALUE_CONVERTER_SCHEMA_REGISTRY_URL="https://sr-service-https.default.svc:8082" dwijad/kafka-connect:latest
        
https://github.com/1ambda/docker-kafka-connect
https://github.com/SAP/kafka-connect-sap
https://github.com/debezium/debezium
https://github.com/wurstmeister/kafka-docker
https://joelforjava.com/blog/2019/10/27/adding-ssl-encryption-to-kafka-connector.html 
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEzNTY1NTEyMzcsLTExOTgwMzUyOTAsLT
U4MTk4OTg0NCwxMTM5NjkzMDYxLDI3ODU0MzgxNCw5MjkwNjM2
MTksOTkxMTEzMTY0LDIwMTQxMjM3NjUsLTg3ODc3MTAxNywtND
gyNDI5NjQ3LDcxOTIwNTI2MF19
-->