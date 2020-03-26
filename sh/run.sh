#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"


#replace nifi.properties with nifi.properties_base if it exists
if [ -f ${NIFI_HOME}/conf/nifi.properties_base ]; then
        echo "copying nifi.properties from nifi.proprties_base"
        \cp $NIFI_HOME/conf/nifi.properties_base $NIFI_HOME/conf/nifi.properties
fi

# run property mapper

# Set cluster protocol to be secure if auth is tls or ldap
if [[ ${AUTH} =~ ^(tls|ldap)$ ]]; then
    prop_replace 'nifi.cluster.protocol.is.secure' 'true'
fi

# set load balance host
prop_replace 'nifi.cluster.load.balance.host'                    "${NIFI_CLUSTER_LOAD_BALANCE_ADDRESS:-$HOSTNAME}"

if ! ( [ -z ${CA_SERVER} ] || [ -z ${CA_TOKEN} ] ); then
    echo 'hi mom'
    ${CA_PORT:=8443}
    ${KEYSTORE_PATH:=${NIFI_HOME}/conf/keystore.jks}
    ${TRUSTSTORE_PATH:=${NIFI_HOME}/conf/truststore.jks}
    echo 'keystore path'
    echo ${KEYSTORE_PATH}
    cert_path=${NIFI_HOME}/conf/nifi-cert.pem
    config_json_path=${NIFI_HOME}/conf/config.json

    #if these files already exist, then there is no need to request for a new certificate
    if ! ( [ -f ${KEYSTORE_PATH} ] && [ -f ${TRUSTSTORE_PATH} ] && [ -f ${cert_path} ] && [ -f ${config_json_path} ] ); then
        subject_alternative_names=$(hostname -f),${HOSTNAME}
        ${NODE_IDENTITY:="CN="${HOSTNAME}",OU=NIFI"}
        # generate certificate
        ${NIFI_TOOLKIT_HOME}/bin/tls-toolkit.sh client -D ${NODE_IDENTITY} -c ${CA_SERVER} -t ${CA_TOKEN} -p ${CA_PORT} --subjectAlternativeNames ${subject_alternative_names}
            mv ./keystore.jks ${KEYSTORE_PATH}
            mv ./truststore.jks ${TRUSTSTORE_PATH}
            mv ./nifi-cert.pem ${cert_path}
            mv ./config.json ${config_json_path}

        # set security values from config.json
        export KEYSTORE_PASSWORD=$(cat ${config_json_path} | jq -r '.keyStorePassword')
        export TRUSTSTORE_PASSWORD=$(cat ${config_json_path} | jq -r '.trustStorePassword')
        export KEY_PASSWORD=$(cat ${config_json_path} | jq -r '.keyPassword')
        export KEYSTORE_TYPE=$(cat ${config_json_path} | jq -r '.keyStoreType')
        export TRUSTSTORE_TYPE=$(cat ${config_json_path} | jq -r '.trustStoreType')

    fi
fi
export KEYSTORE_PATH
export TRUSTSTORE_PATH
${NIFI_BASE_DIR}/scripts/start.sh