#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"

sierra_scripts_dir=${scripts_dir}'/sierra'

#replace nifi.properties with nifi.properties_base if it exists
if [ -f ${NIFI_HOME}/conf/nifi.properties_base ]; then
        echo "copying nifi.properties from nifi.proprties_base"
        \cp $NIFI_HOME/conf/nifi.properties_base $NIFI_HOME/conf/nifi.properties
fi

# run property mapper
# we use source since we want all the exported variables from map-properties.sh
# to be set in the scope of our script, which does not work if we just use
# ${sierra_scripts_dir}/map-properties.sh
# alternately we could use '.' instead of source
source ${sierra_scripts_dir}/map-properties.sh


# Set cluster protocol to be secure if auth is tls or ldap
if [[ ${AUTH} =~ ^(tls|ldap)$ ]]; then
    prop_replace 'nifi.cluster.protocol.is.secure' 'true'
fi

# set load balance host
prop_replace 'nifi.cluster.load.balance.host'                    "${NIFI_CLUSTER_LOAD_BALANCE_ADDRESS:-$HOSTNAME}"

# we use source since we want all the exported variables from fetch_certificate.sh
# to be set in the scope of our script, which does not work if we just use
# ${sierra_scripts_dir}/fetch_certificate.sh
# alternately we could use '.' instead of source
source ${sierra_scripts_dir}/fetch_certificate.sh

${sierra_scripts_dir}/set_authorizers.sh

${NIFI_BASE_DIR}/scripts/start.sh