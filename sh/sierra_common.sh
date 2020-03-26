#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"

login_providers_file=${NIFI_HOME}/conf/login-identity-providers.xml
login_providers_property_xpath='//loginIdentityProviders/provider/property'

authorizers_file=${NIFI_HOME}/conf/authorizers.xml
user_group_property_xpath='//userGroupProvider/property'
access_policy_property_xpath='//accessPolicyProvider/property'

# 1 - property name
# 2 - xpath
# 3 - xml file
read_xml_property () {
    xmlstarlet sel -t -m "$2[@name='$1']" -v . -n $3
}

# 1 - key to search for
# 2 - file to look property in
read_property () {
  target_file=${2:-${nifi_props_file}}
  echo $(cat ${target_file} | grep $1 | cut -d'=' -f2)
}

# 1 - xpath
# 2 - attribute name
# 3 - attribute value
# 4 - xml file
add_xml_property () {
    last_element_name=xmlstarlet sel -t -m "$1[last()]" -v "name()" -n $4
    xmlstarlet ed -a "$1[@name=\""${last_element_name}"\"]" \
              -t 'elem' -n 'property' -v $3 \
              -i "$1[not(@name)]" \
              -t 'attr' -n 'name' -v $2
}