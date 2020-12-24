#!/bin/sh

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
RULE=$(printf "%'.3d\n" $(cat source/adserversVN.txt | grep -v '!' | wc -l))
RULE_VN=$(printf "%'.3d\n" $(cat source/adserversVN.txt | grep -v '!' | wc -l))

# update titles
