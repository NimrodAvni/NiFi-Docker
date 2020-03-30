#!/usr/bin/env bash
# changes the environment variables so if they are not specified
# they will be taken from the corresponding config files
# if the config files are empty they will be assigned a default value by the official apache/nifi start.sh script
scripts_dir='/opt/nifi/scripts/sierra'

[ -f "${scripts_dir}/sierra_common.sh" ] && . "${scripts_dir}/sierra_common.sh"


# nifi.properties environment variables
export NIFI_WEB_HTTP_PORT=${NIFI_WEB_HTTP_PORT:=`read_property 'nifi.web.http.port'`}
export NIFI_WEB_HTTP_HOST=${NIFI_WEB_HTTP_HOST:=`read_property 'nifi.web.http.host'`}
export NIFI_REMOTE_INPUT_HOST=${NIFI_REMOTE_INPUT_HOST:=`read_property 'nifi.remote.input.host'`}
export NIFI_REMOTE_INPUT_SOCKET_PORT=${NIFI_REMOTE_INPUT_SOCKET_PORT:=`read_property 'nifi.remote.input.socket.port'`}
export NIFI_VARIABLE_REGISTRY_PROPERTIES=${NIFI_VARIABLE_REGISTRY_PROPERTIES:=`read_property 'nifi.variable.registry.properties'`}
export NIFI_CLUSTER_IS_NODE=${NIFI_CLUSTER_IS_NODE:=`read_property 'nifi.cluster.is.node'`}
export NIFI_CLUSTER_ADDRESS=${NIFI_CLUSTER_ADDRESS:=`read_property 'nifi.cluster.node.address'`}
export NIFI_CLUSTER_NODE_PROTOCOL_PORT=${NIFI_CLUSTER_NODE_PROTOCOL_PORT:=`read_property 'nifi.cluster.node.protocol.port'`}
export NIFI_CLUSTER_NODE_PROTOCOL_THREADS=${NIFI_CLUSTER_NODE_PROTOCOL_THREADS:=`read_property 'nifi.cluster.node.protocol.threads'`}
export NIFI_CLUSTER_NODE_PROTOCOL_MAX_THREADS=${NIFI_CLUSTER_NODE_PROTOCOL_MAX_THREADS:=`read_property 'nifi.cluster.node.protocol.max.threads'`}
export NIFI_ZK_CONNECT_STRING=${NIFI_ZK_CONNECT_STRING:=`read_property 'nifi.zookeeper.connect.string'`}
export NIFI_ZK_ROOT_NODE=${NIFI_ZK_ROOT_NODE:=`read_property 'nifi.zookeeper.root.node'`}
export NIFI_ELECTION_MAX_WAIT=${NIFI_ELECTION_MAX_WAIT:=`read_property 'nifi.cluster.flow.election.max.wait.time'`}
export NIFI_ELECTION_MAX_CANDIDATES=${NIFI_ELECTION_MAX_CANDIDATES:=`read_property 'nifi.cluster.flow.election.max.candidates'`}
export NIFI_WEB_PROXY_CONTEXT_PATH=${NIFI_WEB_PROXY_CONTEXT_PATH:=`read_property 'nifi.web.proxy.context.path'`}
export KEYSTORE_PATH=${KEYSTORE_PATH:=`read_property 'nifi.security.keystore'`}
export KEYSTORE_TYPE=${KEYSTORE_TYPE:=`read_property 'nifi.security.keystoreType'`}
export KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD:=`read_property 'nifi.security.keystorePasswd'`}
export KEY_PASSWORD=${KEY_PASSWORD:=`read_property 'nifi.security.keyPasswd'`}
export TRUSTSTORE_PATH=${TRUSTSTORE_PATH:=`read_property 'nifi.security.truststore'`}
export TRUSTSTORE_TYPE=${TRUSTSTORE_TYPE:=`read_property 'nifi.security.truststoreType'`}
export TRUSTSTORE_PASSWORD=${TRUSTSTORE_PASSWORD:=`read_property 'nifi.security.truststorePasswd'`}
export NIFI_WEB_HTTPS_PORT=${NIFI_WEB_HTTPS_PORT:=`read_property 'nifi.web.https.port'`}
export NIFI_WEB_HTTPS_HOST=${NIFI_WEB_HTTPS_HOST:=`read_property 'nifi.web.https.host'`}
export NIFI_WEB_PROXY_HOST=${NIFI_WEB_PROXY_HOST:=`read_property 'nifi.web.proxy.host'`}

# login-identity-providers.xml environment variables
export LDAP_AUTHENTICATION_STRATEGY=${LDAP_AUTHENTICATION_STRATEGY:=`read_xml_property 'Authentication Strategy' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_MANAGER_DN=${LDAP_MANAGER_DN:=`read_xml_property 'Manager DN' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_MANAGER_PASSWORD=${LDAP_MANAGER_PASSWORD:=`read_xml_property 'Manager Password' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_KEYSTORE=${LDAP_TLS_KEYSTORE:=`read_xml_property 'TLS - Keystore' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_KEYSTORE_PASSWORD=${LDAP_TLS_KEYSTORE_PASSWORD:=`read_xml_property 'TLS - Keystore Password' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_KEYSTORE_TYPE=${LDAP_TLS_KEYSTORE_TYPE:=`read_xml_property 'TLS - Keystore Type' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_TRUSTSTORE=${LDAP_TLS_TRUSTSTORE:=`read_xml_property 'TLS - Truststore' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_TRUSTSTORE_PASSWORD=${LDAP_TLS_TRUSTSTORE_PASSWORD:=`read_xml_property 'TLS - Truststore Password' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_TRUSTSTORE_TYPE=${LDAP_TLS_TRUSTSTORE_TYPE:=`read_xml_property 'TLS - Truststore Type' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_TLS_PROTOCOL=${LDAP_TLS_PROTOCOL:=`read_xml_property 'TLS - Protocol' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_URL=${LDAP_URL:=`read_xml_property 'Url' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_USER_SEARCH_BASE=${LDAP_USER_SEARCH_BASE:=`read_xml_property 'User Search Base' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_USER_SEARCH_FILTER=${LDAP_USER_SEARCH_FILTER:=`read_xml_property 'User Search Filter' ${login_providers_property_xpath} ${login_providers_file}`}
export LDAP_IDENTITY_STRATEGY=${LDAP_IDENTITY_STRATEGY:=`read_xml_property 'Identity Strategy' ${login_providers_property_xpath} ${login_providers_file}`}

# authorizers.xml environment variables
export INITIAL_ADMIN_IDENTITY=${INITIAL_ADMIN_IDENTITY:=`read_xml_property 'Initial Admin Identity' ${access_policy_property_xpath} ${authorizers_file}`}
export NODE_IDENTITY=${NODE_IDENTITY:=`read_xml_property 'Node Identity 1' ${access_policy_property_xpath} ${authorizers_file}`}

