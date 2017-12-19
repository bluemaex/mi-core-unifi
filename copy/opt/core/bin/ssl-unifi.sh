#!/usr/bin/env bash

# unifi_ssl_import.sh
# UniFi Controller SSL Certificate Import Script for Unix/Linux Systems
# by Steve Jenkins <http://www.stevejenkins.com/>
# Part of https://github.com/stevejenkins/ubnt-linux-utils/
# Incorporates ideas from https://source.sosdg.org/brielle/lets-encrypt-scripts
# Version 2.8
# Last Updated Jan 13, 2017

# Modified for smartos and mi-core-base image

# KEYSTORE BACKUP
# Even though this script attempts to be clever and careful in how it backs up your existing keystore,
# it's never a bad idea to manually back up your keystore (located at $UNIFI_DIR/data/keystore on RedHat
# systems or /$UNIFI_DIR/keystore on Debian/Ubunty systems) to a separate directory before running this
# script. If anything goes wrong, you can restore from your backup, restart the UniFi Controller service,
# and be back online immediately.

# CONFIGURATION OPTIONS
UNIFI_DIR=/opt/local/UniFi
JAVA_DIR=${UNIFI_DIR}
KEYSTORE=${UNIFI_DIR}/data/keystore
LE_LIVE_DIR="/opt/local/etc/letsencrypt/live/$(hostname)"

# CONFIGURATION OPTIONS YOU PROBABLY SHOULDN'T CHANGE
ALIAS=unifi
PASSWORD=aircontrolenterprise

# Use user certificate if provided other check for letsencrypt
if mdata-get nginx_ssl 1>/dev/null 2>&1; then
  LE_MODE=false
  PRIV_KEY=/opt/local/etc/nginx/ssl/nginx.key
  SIGNED_CRT=/opt/local/etc/nginx/ssl/nginx.crt
  CHAIN_FILE=/opt/local/etc/nginx/ssl/chain.crt
elif [ -d ${LE_LIVE_DIR} ]; then
  LE_MODE=true
  PRIV_KEY=${LE_LIVE_DIR}/privkey.pem
  SIGNED_CRT=${LE_LIVE_DIR}/cert.pem
  CHAIN_FILE=${LE_LIVE_DIR}/chain.pem
  # Create local copy of cross-signed CA File (required for keystore import)
  # Verify original @ https://www.identrust.com/certificates/trustid/root-download-x3.html
  cat > "${CA_TEMP}" <<'_EOF'
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
_EOF
fi

# Verify required files exist
if [ ! -f ${PRIV_KEY} ] || [ ! -f ${SIGNED_CRT} ] || [ ! -f ${CHAIN_FILE} ]; then
  printf "\nMissing one or more required files. Check your settings.\n"
  exit 1
fi

# Create double-safe keystore backup
if [ -s "${KEYSTORE}.orig" ]; then
  cp ${KEYSTORE} ${KEYSTORE}.bak
else
  cp ${KEYSTORE} ${KEYSTORE}.orig
fi

# Create temp files
P12_TEMP=$(mktemp)
CA_TEMP=$(mktemp)

# Stop the UniFi Controller
svcadm disable unifi

# Export your existing SSL key, cert, and CA data to a PKCS12 file
openssl pkcs12 -export \
-in ${SIGNED_CRT} \
-inkey ${PRIV_KEY} \
-CAfile ${CHAIN_FILE} \
-out ${P12_TEMP} \
-passout pass:${PASSWORD} \
-caname root -name ${ALIAS}

# Delete the previous certificate data from keystore to avoid "already exists" message
keytool -delete -alias ${ALIAS} -keystore ${KEYSTORE} -deststorepass ${PASSWORD}

# Import the temp PKCS12 file into the UniFi keystore
keytool -importkeystore \
-srckeystore ${P12_TEMP} \
-srcstoretype PKCS12 \
-srcstorepass ${PASSWORD} \
-destkeystore ${KEYSTORE} \
-deststorepass ${PASSWORD} \
-destkeypass ${PASSWORD} \
-alias ${ALIAS} \
-trustcacerts

# Import the certificate authority data into the UniFi keystore
if [ ${LE_MODE} == "true" ]; then
  # Import with additional cross-signed CA file
  java -jar ${JAVA_DIR}/lib/ace.jar import_cert \
  ${SIGNED_CRT} \
  ${CHAIN_FILE} \
  ${CA_TEMP}
else
  # Import in standard mode
  java -jar ${JAVA_DIR}/lib/ace.jar import_cert \
  ${SIGNED_CRT} \
  ${CHAIN_FILE}
fi

# Clean up temp files
rm -f ${P12_TEMP}
rm -f ${CA_TEMP}

# Restart the UniFi Controller to pick up the updated keystore
svcadm enable unifi
exit 0
