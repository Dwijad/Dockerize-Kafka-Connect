# Dockerize Kafka Connect Worker

Build docker image for secured kafka Connect worker in your local docker environment with Debzeium MySQL connector and JDBC source/sink connector. Subsequently deploy the kafka connect worker in kubernetes cluster in a distributed way. 

### Prerequisi
 -  You want to leverage your local kafka cluster running in PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL mode.
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
eyJoaXN0b3J5IjpbNjA5NDc2MzgxLC04Nzg3NzEwMTcsLTQ4Mj
QyOTY0Nyw3MTkyMDUyNjBdfQ==
-->