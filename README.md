# Dockerize Kafka Connect Worker

Build docker image for secured kafka Connect worker in your local docker environment with Debzeium MySQL connector and JDBC source/sink connector. Subsequently deploy the kafka connect worker in kubernetes cluster in a distributed way. 

### This kafka connect worker setup is for you if -
 -  You want to leverage your local kafka cluster running in SSL_SASL mode.
 -  You have a schema registry server running in SSL mode.
 -  You want to convert data for Kafka Connect to and from in Avro format.
 - No other listener mode like PLAINTEXT, SSL, SSL_PLAINTEXT configured in kafka broker will not work.
 -  

<!--stackedit_data:
eyJoaXN0b3J5IjpbNzIyODMwNDI4XX0=
-->