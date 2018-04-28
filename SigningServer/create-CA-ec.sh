#! /usr/bin/env bash

#  create-CA-ec.sh 
#
#  Copyright (C) 2010 by Manfred Morgner
#  manfred@morgner.com
#
#  This script creates a CA for the Signing Service
# 
#  The intermediate CAs require a file with the following content:
# 
#     [ v3_ext ]
#     subjectKeyIdentifier   = hash
#     authorityKeyIdentifier = keyid:always,issuer:always
#     basicConstraints       = CA:true
#     [alt_names]
#     DNS.1                  = ${CN}
#

#  secp224r1 : NIST/SECG curve over a 224 bit prime field
#  secp256k1 : SECG curve over a 256 bit prime field
#  secp384r1 : NIST/SECG curve over a 384 bit prime field
#  secp521r1 : NIST/SECG curve over a 521 bit prime field
#  prime256v1: X9.62/SECG curve over a 256 bit prime field

#CURVE=secp224r1
#CURVE=secp256k1
CURVE=secp384r1
#CURVE=secp521r1
#CURVE=prime256v1


CART="cert.flow.info"
SVCA="server-CA"
CLCA="client-CA"

SORGAN="'flow' Working Group (fwg)"
SCNTRY="CH"

CORGAN="'flow' User Group (fug)"
CCNTRY="CH"

WORKDIR=`pwd`
SCRPTDIR=`dirname $0`
HISTORY="${WORKDIR}/CERTIFICATES"
rm -f ${HISTORY}

mkdir -p CA

DIR_CA="${WORKDIR}/CA"


#######################################################################
#
# Root CA
#
echo "Creating CA Root"

cd ${DIR_CA}

NAME="${CART}"
ORGANISATION="${SORGAN}"
COUNTRY="${SCNTRY}"
STATE="Bern"
LOCATION="City of Bern"

openssl ecparam -genkey -name ${CURVE} -out "${DIR_CA}/${NAME}.key"
openssl req     -new -utf8 -sha256 \
                -x509 \
                -days 7305 \
                -subj "/CN=${NAME}/O=${ORGANISATION}/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}" \
                -key "${DIR_CA}/${NAME}.key" \
                -out "${DIR_CA}/${NAME}.crt"
echo "CA Root Certificate is: ${DIR_CA}/${NAME}.crt" | tee -a ${HISTORY}


# version 3 extensions for IM-CA
SSL_CONFIG="${WORKDIR}/ssl.conf"
echo "[v3_ext]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:true
" > "${SSL_CONFIG}"

#######################################################################
#
# Server CA
#
echo "Creating Server CA"

NAME="${SVCA}"
CN="Server CA"
ORGANISATION="${SORGAN}"
openssl ecparam -out "${DIR_CA}/${NAME}.key" -name ${CURVE} -genkey
openssl req -new -utf8 -sha256 \
            -days 7301 \
            -subj "/CN=${CN}/O=${ORGANISATION}/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}" \
            -key "${DIR_CA}/${NAME}.key" \
            -out "${DIR_CA}/${NAME}.csr"
SERIAL="`od -An -N2 -d < /dev/urandom | sed -e 's/\s//g'`"
CA=${CART}
CATO=`openssl x509 -noout -dates -in "${DIR_CA}/${CA}.crt" | tail -1 | sed -e "s/^.*=\(.*\) ..:..:.. \(....\).*$/\1 \2/"`
DAYS="$((($(date -d "${CATO}" '+%s') - $(date '+%s'))/(24*3600)-1))"
openssl x509 -req -days ${DAYS} \
             -extfile "${SSL_CONFIG}" -extensions v3_ext \
             -in "${DIR_CA}/${NAME}.csr" \
             -CA "${DIR_CA}/${CA}.crt" -CAkey "${DIR_CA}/${CA}.key" -set_serial "${SERIAL}" \
             -out "${DIR_CA}/${NAME}.crt"
echo "SERVER:${SERIAL}:Server CA Certificate is: ${DIR_CA}/${NAME}.crt (${DAYS} days)" | tee -a ${HISTORY}


#######################################################################
#
#  Client CA
#
echo "Creating Client CA"

NAME=${CLCA}
CN="Client CA"
ORGANISATION="${CORGAN}"
COUNTRY="${CCNTRY}"
openssl ecparam -out "${DIR_CA}/${NAME}.key" -name ${CURVE} -genkey
openssl req -new -utf8 -sha256 \
            -days 7301 \
            -subj "/CN=${CN}/O=${ORGANISATION}/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}" \
            -key "${DIR_CA}/${NAME}.key" \
            -out "${DIR_CA}/${NAME}.csr"
SERIAL="`od -An -N2 -d < /dev/urandom | sed -e 's/\s//g'`"
CA=${CART}
CATO=`openssl x509 -noout -dates -in "${DIR_CA}/${CA}.crt" | tail -1 | sed -e "s/^.*=\(.*\) ..:..:.. \(....\).*$/\1 \2/"`
DAYS="$((($(date -d "${CATO}" '+%s') - $(date '+%s'))/(24*3600)-1))"
openssl x509 -req -days ${DAYS} \
             -extfile "${SSL_CONFIG}" -extensions v3_ext \
             -in "${DIR_CA}/${NAME}.csr" \
             -CA "${DIR_CA}/${CA}.crt" -CAkey "${DIR_CA}/${CA}.key" -set_serial "${SERIAL}" \
             -out "${DIR_CA}/${NAME}.crt"
echo "CLIENT:${SERIAL}:Client CA Certificate is: ${DIR_CA}/${NAME}.crt (${DAYS} days)" | tee -a ${HISTORY}


rm "${SSL_CONFIG}"

cd "${WORKDIR}"

