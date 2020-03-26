#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts/sierra'

[ -f "${scripts_dir}/sierra_common.sh" ] && . "${scripts_dir}/sierra_common.sh"

# Add node to initial user identity, bug in current apache/nifi image
if [ -n "${NODE_IDENTITY}" ]; then
    add_xml_property ${user_group_property_xpath} "Initial User Identity ${NODE_IDENTITY}" ${NODE_IDENTITY} ${authorizers_file}
fi
