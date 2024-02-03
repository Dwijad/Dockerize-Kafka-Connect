# Dockerize Kafka Connect Worker

Build docker image for secured kafka Connect worker in your local docker environment with Debzeium MySQL connector and JDBC source/sink connector. Subsequently deploy the kafka connect worker in kubernetes cluster in a distributed way. 

### This kafka connect worker setup is for you if -
 -  You want to leverage your local kafka cluster running in SSL_SASL mode.
 -  You have a schema registry server running in SSL mode.
 -  You want to convert data for Kafka Connect to and from in Avro format.
 - No other listener mode like PLAINTEXT, SSL, SSL_PLAINTEXT configured in kafka broker will not work.
 -  However, a modification in the start script 

https://github.com/1ambda/docker-kafka-connect
https://github.com/SAP/kafka-connect-sap
https://github.com/debezium/debezium
https://github.com/wurstmeister/kafka-docker
https://joelforjava.com/blog/2019/10/27/adding-ssl-encryption-to-kafka-connector.html
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTk3MTUwOTUzMywtNDgyNDI5NjQ3LDcxOT
IwNTI2MF19
-->