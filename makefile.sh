#!/bin/sh

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
RULE_VN=$(printf "%'.3d\n" $(cat source/adserversVN.txt | grep -v '!' | wc -l))

# update titles
sed -e "s/_time_stamp_/$TIME_STAMP/g" -e "s/_version_/$VERSION/g" -e "s/_rule_vn_/$RULE_VN/g" tmp/title-adserverVN.txt > tmp/title-adserverVN.tmp

echo "Creating adserver file..."
# create temp adserver files
cat source/adserversVN.txt | grep -v '!' | awk '{print $1}' >> tmp/adserversVN.tmp
cat source/exceptions.txt | grep -v '!' |awk '{print $1}' >> tmp/exceptions.tmp

# create adserver files
cat tmp/adserversVN.tmp | awk '{print "||"$1"^"}' >> tmp/adserversVN-rule.tmp
cat tmp/exceptions.tmp | awk '{print "@@||"$1"^|"}' >> tmp/adserversVN-rule.tmp
cat tmp/adserversVN.tmp | awk '{print "*"$1" = 0.0.0.0"}' >> tmp/adserversVN-config.tmp

echo "Creating rule file..."
# create rule
cat source/config-rule.txt | awk '{print "HOST-KEYWORD,"$1",REJECT"}' > option/quantumult-rule.conf
cat tmp/adserversVN.tmp | awk '{print "HOST-SUFFIX,"$1",REJECT"}' >> option/quantumult-rule.conf
cat source/config-rule.txt | awk '{print "DOMAIN-KEYWORD,"$1}' > option/surge-rule.conf
cat tmp/adserversVN.tmp | awk '{print "DOMAIN-SUFFIX,"$1}' >> option/surge-rule.conf
cat source/config-rule.txt | awk '{print "DOMAIN-KEYWORD,"$1",REJECT"}' > tmp/shadowrocket-rule.tmp
cat tmp/adserversVN.tmp | awk '{print "DOMAIN-SUFFIX,"$1",REJECT"}' >> tmp/shadowrocket-rule.tmp

# create exceptions rule
cat tmp/exceptions.tmp | awk '{print "HOST,"$1",DIRECT"}' > option/quantumult-exceptions-rule.conf
cat tmp/exceptions.tmp | awk '{print "DOMAIN,"$1}' > option/surge-exceptions-rule.conf
cat tmp/exceptions.tmp | awk '{print "DOMAIN,"$1",DIRECT"}' >> tmp/shadowrocket-exceptions-rule.tmp


echo "Creating rewrite file..."
# create rewrite
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1}' > option/quantumult-rejection.conf
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" reject"}' > tmp/rewrite-shadowrocket.tmp
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "URL-REGEX,"$1}' > option/surge-rewrite.conf
cat source/config-hostname.txt > option/quantumultX-rewrite.conf
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" url reject-img"}' >> option/quantumultX-rewrite.conf
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print $1" - reject-img"}' > option/loon-rewrite.conf

echo "Creating config file..."
# create config
sed -e "s/_time_stamp_/$TIME_STAMP/g" tmp/title-config-quantumultX.txt > option/quantumultX.conf
sed -e "s/!_hostname_/$HOSTNAME/g" -e '/!_rejection_quantumult_/r option/quantumult-rejection.conf' -e '/!_rejection_quantumult_/d' -e '/!_rule_quantumult_/r option/quantumult-rule.conf' -e '/!_rule_quantumult_/d' -e '/!_rule_exceptions_quantumult_/r option/quantumult-exceptions-rule.conf' -e '/!_rule_exceptions_quantumult_/d' tmp/title-config-quantumult.txt > option/quantumult.conf
sed -e "s/!_hostname_/$HOSTNAME/g" -e '/!_rewrite_shadowrocket_/r tmp/rewrite-shadowrocket.tmp' -e '/!_rewrite_shadowrocket_/d' -e '/!_rule_shadowrocket_/r tmp/shadowrocket-rule.tmp' -e '/!_rule_shadowrocket_/d' -e '/!_rule_exceptions_shadowrocket_/r tmp/shadowrocket-exceptions-rule.tmp' -e '/!_rule_exceptions_shadowrocket_/d' tmp/title-config-shadowrocket.txt > option/shadowrocket.conf

echo "Adding to file..."
# add to files
cat tmp/title-adserverVN.tmp tmp/adserversVN-rule.tmp > filters/adserversVN.txt
cat tmp/title-config-surge.tmp tmp/adserversVN-config.tmp > option/hostsVN.conf

echo "Creating block OTA file..."
cat source/OTA.txt | grep -v '!' | awk '{print "HOST-SUFFIX,"$1",REJECT"}' > option/hostsVN-quantumult-OTA.conf
cat source/OTA.txt | grep -v '!' | awk '{print "DOMAIN-SUFFIX,"$1}' > option/hostsVN-surge-OTA.conf

# remove tmp file
rm -rf tmp/*.tmp

# check duplicate
echo "Checking duplicate..."
sort option/domain.txt | uniq -d
sort filters/adservers-all.txt | uniq -d
read -p "Completed! Press enter to close
