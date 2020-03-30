#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts/sierra'

[ -f "${scripts_dir}/sierra_common.sh" ] && . "${scripts_dir}/sierra_common.sh"

admin=$1
node=$2
node=${node:="CN=$(hostname), OU=NIFI"}

edit_xml_property "${user_group_property_xpath}" "Initial User Identity 1" "${admin}" ${authorizers_file}
edit_xml_property "${access_policy_property_xpath}" "Initial Admin Identity" "${admin}" ${authorizers_file}
add_xml_property "${user_group_property_xpath}" "Initial User Identity $(uuidgen)" "${node}" ${authorizers_file}
edit_xml_property "${access_policy_property_xpath}" "Node Identity 1" "${node}" "${authorizers_file}"