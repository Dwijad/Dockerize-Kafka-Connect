#!/bin/bash -x

HOSTNAME=$(hostname -f)
echo export KAFKA_JMX_HOSTNAME=$HOSTNAME >> .bashrc
. .bashrc
KAFKA_HOME=/u01/cnfkfk

cat << EOF > $KAFKA_HOME/etc/kafka/connect-distributed.properties
bootstrap.servers=${BOOTSTRAP_SERVERS:-test-kafka.default.svc.cluster.local:9092}
listeners=${LISTENERS:-"${REST_ADVERTISED_LISTENER}"://"${HOSTNAME}":"${LISTENER_PORT}"}
rest.advertised.listener=${REST_ADVERTISED_LISTENER:-http}
group.id=${GROUP_ID:-connect-cluster}
key.converter=${KEY_CONVERTER:-org.apache.kafka.connect.json.JsonConverter}
value.converter=${VALUE_CONVERTER:-org.apache.kafka.connect.json.JsonConverter}
key.converter.schemas.enable=${KEY_CONVERTER_SCHEMAS_ENABLE:-false}
value.converter.schemas.enable=${VALUE_CONVERTER_SCHEMAS_ENABLE:-false}
offset.storage.topic=${OFFSET_STORAGE_TOPIC:-connect-offsets}
config.storage.topic=${CONFIG_STORAGE_TOPIC:-connect-configs}
status.storage.topic=${STATUS_STORAGE_TOPIC:-connect-status}
rest.host.name="${HOSTNAME}"
rest.port=${LISTENER_PORT:-8083}
rest.advertised.host.name="${HOSTNAME}"
rest.advertised.port=${LISTENER_PORT:-8083}
plugin.path=${PLUGIN_PATH:-$KAFKA_HOME/share/java/kafka,$KAFKA_HOME/share/java/kafka-connect-jdbc}
config.providers=${CONFIG_PROVIDERS:-file}
config.providers.file.class=${CONFIG_PROVIDERS_FILE_CLASS:-org.apache.kafka.common.config.provider.FileConfigProvider}
request.timeout.ms=${REQUEST_TIMEOUT_MS:-20000}
retry.backoff.ms=${RETRY_BACKOFF_MS:-500}
EOF

# listeners=PLAINTEXT,SSL,SASL_SSL,SASL_PLAINTEXT and security.protocol
# Broker listener configured in SASL_SSL

if [[ "$BROKER_LISTENER_MODE" == "SASL_SSL" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
security.protocol=${SECURITY_PROTOCOL:-SASL_SSL}
ssl.protocol=${SSL_PROTOCOL:-TLS}
ssl.truststore.location=${SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
ssl.truststore.password=${SSL_TRUSTSTORE_PASSWORD:-password}
ssl.keystore.location=${SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
ssl.keystore.password=${SSL_KEYSTORE_PASSWORD:-password}
ssl.key.password=${SSL_KEY_PASSWORD:-password}
ssl.endpoint.identification.algorithm=${SSL_ENDPOINT_IDENTIFICATION_ALGORITHM:-}
consumer.ssl.endpoint.identification.algorithm=${CONSUMER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM:-}
consumer.request.timeout.ms=${CONSUMER_REQUEST_TIMEOUT_MS:-20000}
consumer.retry.backoff.ms=${CONSUMER_RETRY_BACKOFF_MS:-500}
consumer.security.protocol=${CONSUMER_SECURITY_PROTOCOL:-SASL_SSL}
consumer.ssl.protocol=${CONSUMER_SSL_PROTOCOL:-TLS}
consumer.ssl.truststore.location=${CONSUMER_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
consumer.ssl.truststore.password=${CONSUMER_SSL_TRUSTSTORE_PASSWORD:-password}
consumer.ssl.keystore.location=${CONSUMER_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
consumer.ssl.keystore.password=${CONSUMER_SSL_KEYSTORE_PASSWORD:-password}
consumer.ssl.key.password=${CONSUMER_SSL_KEY_PASSWORD:-password}
producer.ssl.endpoint.identification.algorithm=${PRODUCER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM:-}
producer.request.timeout.ms=${PRODUCER_REQUEST_TIMEOUT_MS:-20000}
producer.retry.backoff.ms=${PRODUCER_RETRY_BACKOFF_MS:-500}
producer.security.protocol=${PRODUCER_SECURITY_PROTOCOL:-SASL_SSL}
producer.ssl.protocol=${PRODUCER_SSL_PROTOCOL:-TLS}
producer.ssl.truststore.location=${PRODUCER_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
producer.ssl.truststore.password=${PRODUCER_SSL_TRUSTSTORE_PASSWORD:-password}
producer.ssl.keystore.location=${PRODUCER_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
producer.ssl.keystore.password=${PRODUCER_SSL_KEY_PASSWORD:-password}
producer.ssl.key.password=${PRODUCER_SSL_KEY_PASSWORD:-password}
sasl.jaas.config=${SASL_JAAS_CONFIG:-org.apache.kafka.common.security.plain.PlainLoginModule required username="${SASL_USER}" password="${SASL_PASSWORD}";}
producer.sasl.jaas.config=${PRODUCER_SASL_JAAS_CONFIG:-org.apache.kafka.common.security.plain.PlainLoginModule required username="${SASL_USER}" password="${SASL_PASSWORD}";}
consumer.sasl.jaas.config=${CONSUMER_SASL_JAAS_CONFIG:-org.apache.kafka.common.security.plain.PlainLoginModule required username="${SASL_USER}" password="${SASL_PASSWORD}";}
sasl.mechanism=${SASL_MECHANISM:-PLAIN}
producer.sasl.mechanism=${PRODUCER_SASL_MECHANISM:-PLAIN}
consumer.sasl.mechanism=${CONSUMER_SASL_MECHANISM:-PLAIN}
EOF
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTPS" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.ssl.keystore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
key.converter.schema.registry.ssl.keystore.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
key.converter.schema.registry.ssl.key.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
key.converter.basic.auth.credentials.source=${KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
key.converter.basic.auth.user.info=${KEY_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
key.converter.schema.registry.ssl.truststore.type=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
key.converter.schema.registry.ssl.truststore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.truststore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.keystore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
value.converter.schema.registry.ssl.keystore.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
value.converter.schema.registry.ssl.key.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
value.converter.schema.registry.url=${VALUE_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
value.converter.basic.auth.credentials.source=${VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
value.converter.basic.auth.user.info=${VALUE_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
value.converter.schema.registry.ssl.truststore.type=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
schema.registry.url=${SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
schema.registry.ssl.truststore.password=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD:-password}
schema.registry.ssl.truststore.location=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
schema.registry.ssl.keystore.password=${SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
schema.registry.ssl.keystore.location=${SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
schema.registry.ssl.key.password=${SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
schema.registry.basic.auth.credentials.source=${SCHEMA_REGISTRY_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
schema.registry.basic.auth.user.info=${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO:-user1:password}
EOF
fi
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTP" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
value.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
schema.registry.url=${SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
EOF
fi
fi

# Broker listener configured in PLAINTEXT

if [[ "$BROKER_LISTENER_MODE" == "PLAINTEXT" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
security.protocol=${SECURITY_PROTOCOL:-PLAINTEXT}
consumer.request.timeout.ms=${CONSUMER_REQUEST_TIMEOUT_MS:-20000}
consumer.retry.backoff.ms=${CONSUMER_RETRY_BACKOFF_MS:-500}
consumer.security.protocol=${CONSUMER_SECURITY_PROTOCOL:-PLAINTEXT}
producer.request.timeout.ms=${PRODUCER_REQUEST_TIMEOUT_MS:-20000}
producer.retry.backoff.ms=${PRODUCER_RETRY_BACKOFF_MS:-500}
producer.security.protocol=${PRODUCER_SECURITY_PROTOCOL:-PLAINTEXT}
EOF
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTPS" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.ssl.keystore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
key.converter.schema.registry.ssl.keystore.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
key.converter.schema.registry.ssl.key.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
key.converter.basic.auth.credentials.source=${KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
key.converter.basic.auth.user.info=${KEY_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
key.converter.schema.registry.ssl.truststore.type=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
key.converter.schema.registry.ssl.truststore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.truststore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.keystore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
value.converter.schema.registry.ssl.keystore.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
value.converter.schema.registry.ssl.key.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
value.converter.schema.registry.url=${VALUE_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
value.converter.basic.auth.credentials.source=${VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
value.converter.basic.auth.user.info=${VALUE_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
value.converter.schema.registry.ssl.truststore.type=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
schema.registry.url=${SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
schema.registry.ssl.truststore.password=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD:-password}
schema.registry.ssl.truststore.location=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
schema.registry.ssl.keystore.password=${SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
schema.registry.ssl.keystore.location=${SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
schema.registry.ssl.key.password=${SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
schema.registry.basic.auth.credentials.source=${SCHEMA_REGISTRY_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
schema.registry.basic.auth.user.info=${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO:-user1:password}
EOF
fi
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTP" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
value.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
schema.registry.url=${SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
EOF
fi
fi

# Broker configured in SSL

if [[ "$BROKER_LISTENER_MODE" == "SSL" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
security.protocol=${SECURITY_PROTOCOL:-SSL}
ssl.protocol=${SSL_PROTOCOL:-TLS}
ssl.truststore.location=${SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
ssl.truststore.password=${SSL_TRUSTSTORE_PASSWORD:-password}
ssl.keystore.location=${SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
ssl.keystore.password=${SSL_KEYSTORE_PASSWORD:-password}
ssl.key.password=${SSL_KEY_PASSWORD:-password}
ssl.endpoint.identification.algorithm=${SSL_ENDPOINT_IDENTIFICATION_ALGORITHM:-}
consumer.ssl.endpoint.identification.algorithm=${CONSUMER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM:-}
consumer.request.timeout.ms=${CONSUMER_REQUEST_TIMEOUT_MS:-20000}
consumer.retry.backoff.ms=${CONSUMER_RETRY_BACKOFF_MS:-500}
consumer.security.protocol=${CONSUMER_SECURITY_PROTOCOL:-SSL}
consumer.ssl.protocol=${CONSUMER_SSL_PROTOCOL:-TLS}
consumer.ssl.truststore.location=${CONSUMER_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
consumer.ssl.truststore.password=${CONSUMER_SSL_TRUSTSTORE_PASSWORD:-password}
consumer.ssl.keystore.location=${CONSUMER_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
consumer.ssl.keystore.password=${CONSUMER_SSL_KEYSTORE_PASSWORD:-password}
consumer.ssl.key.password=${CONSUMER_SSL_KEY_PASSWORD:-password}
producer.ssl.endpoint.identification.algorithm=${PRODUCER_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM:-}
producer.request.timeout.ms=${PRODUCER_REQUEST_TIMEOUT_MS:-20000}
producer.retry.backoff.ms=${PRODUCER_RETRY_BACKOFF_MS:-500}
producer.security.protocol=${PRODUCER_SECURITY_PROTOCOL:-SSL}
producer.ssl.protocol=${PRODUCER_SSL_PROTOCOL:-TLS}
producer.ssl.truststore.location=${PRODUCER_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
producer.ssl.truststore.password=${PRODUCER_SSL_TRUSTSTORE_PASSWORD:-password}
producer.ssl.keystore.location=${PRODUCER_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
producer.ssl.keystore.password=${PRODUCER_SSL_KEY_PASSWORD:-password}
EOF
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTPS" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.ssl.keystore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
key.converter.schema.registry.ssl.keystore.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
key.converter.schema.registry.ssl.key.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
key.converter.basic.auth.credentials.source=${KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
key.converter.basic.auth.user.info=${KEY_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
key.converter.schema.registry.ssl.truststore.type=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
key.converter.schema.registry.ssl.truststore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.truststore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.keystore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
value.converter.schema.registry.ssl.keystore.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
value.converter.schema.registry.ssl.key.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
value.converter.schema.registry.url=${VALUE_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
value.converter.basic.auth.credentials.source=${VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
value.converter.basic.auth.user.info=${VALUE_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
value.converter.schema.registry.ssl.truststore.type=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
schema.registry.url=${SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
schema.registry.ssl.truststore.password=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD:-password}
schema.registry.ssl.truststore.location=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
schema.registry.ssl.keystore.password=${SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
schema.registry.ssl.keystore.location=${SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
schema.registry.ssl.key.password=${SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
schema.registry.basic.auth.credentials.source=${SCHEMA_REGISTRY_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
schema.registry.basic.auth.user.info=${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO:-user1:password}
EOF
fi
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTP" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
value.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
schema.registry.url=${SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
EOF
fi
fi

# Broker configured in SASL_PLAINTEXT

if [[ "$BROKER_LISTENER_MODE" == "SASL_PLAINTEXT" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
security.protocol=${SECURITY_PROTOCOL:-SASL_PLAINTEXT}
consumer.request.timeout.ms=${CONSUMER_REQUEST_TIMEOUT_MS:-20000}
consumer.retry.backoff.ms=${CONSUMER_RETRY_BACKOFF_MS:-500}
consumer.security.protocol=${CONSUMER_SECURITY_PROTOCOL:-SASL_PLAINTEXT}
producer.request.timeout.ms=${PRODUCER_REQUEST_TIMEOUT_MS:-20000}
producer.retry.backoff.ms=${PRODUCER_RETRY_BACKOFF_MS:-500}
producer.security.protocol=${PRODUCER_SECURITY_PROTOCOL:-SASL_PLAINTEXT}
sasl.jaas.config=${SASL_JAAS_CONFIG:-org.apache.kafka.common.security.plain.PlainLoginModule required username="${SASL_USER}" password="${SASL_PASSWORD}";}
producer.sasl.jaas.config=${PRODUCER_SASL_JAAS_CONFIG:-org.apache.kafka.common.security.plain.PlainLoginModule required username="${SASL_USER}" password="${SASL_PASSWORD}";}
consumer.sasl.jaas.config=${CONSUMER_SASL_JAAS_CONFIG:-org.apache.kafka.common.security.plain.PlainLoginModule required username="${SASL_USER}" password="${SASL_PASSWORD}";}
sasl.mechanism=${SASL_MECHANISM:-PLAIN}
producer.sasl.mechanism=${PRODUCER_SASL_MECHANISM:-PLAIN}
consumer.sasl.mechanism=${CONSUMER_SASL_MECHANISM:-PLAIN}
EOF
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTPS" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.ssl.keystore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
key.converter.schema.registry.ssl.keystore.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
key.converter.schema.registry.ssl.key.password=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
key.converter.basic.auth.credentials.source=${KEY_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
key.converter.basic.auth.user.info=${KEY_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
key.converter.schema.registry.ssl.truststore.type=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
key.converter.schema.registry.ssl.truststore.location=${KEY_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.truststore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/cert.pem}
value.converter.schema.registry.ssl.keystore.location=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
value.converter.schema.registry.ssl.keystore.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
value.converter.schema.registry.ssl.key.password=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
value.converter.schema.registry.url=${VALUE_CONVERTER_SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
value.converter.basic.auth.credentials.source=${VALUE_CONVERTER_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
value.converter.basic.auth.user.info=${VALUE_CONVERTER_BASIC_AUTH_USER_INFO:-user1:password}
value.converter.schema.registry.ssl.truststore.type=${VALUE_CONVERTER_SCHEMA_REGISTRY_SSL_TRUSTSTORE_TYPE:-PEM}
schema.registry.url=${SCHEMA_REGISTRY_URL:-https://127.0.0.1:8082}
schema.registry.ssl.truststore.password=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_PASSWORD:-password}
schema.registry.ssl.truststore.location=${SCHEMA_REGISTRY_SSL_TRUSTSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka.truststore.jks}
schema.registry.ssl.keystore.password=${SCHEMA_REGISTRY_SSL_KEYSTORE_PASSWORD:-password}
schema.registry.ssl.keystore.location=${SCHEMA_REGISTRY_SSL_KEYSTORE_LOCATION:-$KAFKA_HOME/etc/ssl/kafka-broker-0.keystore.jks}
schema.registry.ssl.key.password=${SCHEMA_REGISTRY_SSL_KEY_PASSWORD:-password}
schema.registry.basic.auth.credentials.source=${SCHEMA_REGISTRY_BASIC_AUTH_CREDENTIALS_SOURCE:-USER_INFO}
schema.registry.basic.auth.user.info=${SCHEMA_REGISTRY_BASIC_AUTH_USER_INFO:-user1:password}
EOF
fi
if [[ "$SCHEMA_REGISTRY_MODE" == "HTTP" ]]; then
cat << EOF >> $KAFKA_HOME/etc/kafka/connect-distributed.properties
key.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
value.converter.schema.registry.url=${KEY_CONVERTER_SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
schema.registry.url=${SCHEMA_REGISTRY_URL:-http://127.0.0.1:8081}
EOF
fi
fi

connect-distributed $KAFKA_HOME/etc/kafka/connect-distributed.properties  & echo $! > $KAFKA_HOME/etc/kafka/connect-distributed.pid &
sleep infinity
