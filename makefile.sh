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

