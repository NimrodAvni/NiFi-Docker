#!/usr/bin/env bash

scripts_dir='/opt/nifi/scripts'

[ -f "${scripts_dir}/common.sh" ] && . "${scripts_dir}/common.sh"

login_providers_file=${NIFI_HOME}/conf/login-identity-providers.xml
login_providers_property_xpath='//loginIdentityProviders/provider/property'

authorizers_file=${NIFI_HOME}/conf/authorizers.xml
user_group_property_xpath='//userGroupProvider/property'
access_policy_property_xpath='//accessPolicyProvider/property'


# 1 - key to search for
# 2 - file to look property in
read_property () {
  target_file=${2:-${nifi_props_file}}
  echo $(cat ${target_file} | grep $1 | cut --delimiter='=' -f2)
}

# 1 - property name
# 2 - xpath
# 3 - xml file
read_xml_property () {
    xmlstarlet select --template --match "$2[@name='$1']" --value-of . --nl $3
}

# 1 - xpath to property
# 2 - property name
# 3 - new property value
# 4 - xml file

edit_xml_property() {
  property_xpath=$1
  property_name=$2
  property_value=$3
  xml_file=$4
  if [ -n "${property_value}" ]; then
    xmlstarlet edit --inplace --update "${property_xpath}[@name='${property_name}']" -v "${property_value}" ${xml_file}
  fi
}

# 1 - xpath to property
# 2 - property name
# 3 - property value
# 4 - xml file
add_xml_property () {
    last_element_name=`xmlstarlet sel --template --match "$1[last()]" -v "@name" --nl $4`
    xmlstarlet edit --inplace --append $1"[@name=\"${last_element_name}\"]" \
		        --type 'elem' -n 'property' --value "$3" \
			    --insert "$1[not(@name)]" \
			        --type 'attr' -n name \
				--value "$2" $4
}