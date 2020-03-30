#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts/sierra'

[ -f "${scripts_dir}/sierra_common.sh" ] && . "${scripts_dir}/sierra_common.sh"

# Add node to initial user identity, bug in current apache/nifi image
if [ -n "${NODE_IDENTITY}" ]; then
    add_xml_property "${user_group_property_xpath}" "Initial User Identity $(uuidgen)" "${NODE_IDENTITY}" ${authorizers_file}

    # TODO: make generic for every property
    sed -i -e 's|<property name="Initial User Identity 1"/>|<property name="Initial User Identity 1"></property>|' ${authorizers_file}
    sed -i -e 's|<property name="Initial Admin Identity"/>|<property name="Initial Admin Identity"></property>|' ${authorizers_file}
    sed -i -e 's|<property name="Node Identity 1"/>|<property name="Node Identity 1"></property>|' ${authorizers_file}

fi
