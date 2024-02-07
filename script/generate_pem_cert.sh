#!/bin/bash
openssl x509 -in ca-cert -out cert.pem
openssl x509 -in cert.pem -inform pem -out ca.der -outform der
keytool -importcert -alias ca -keystore /u01/cnfkfk/java/lib/security/cacerts -storepass changeit -noprompt -file ca.der

