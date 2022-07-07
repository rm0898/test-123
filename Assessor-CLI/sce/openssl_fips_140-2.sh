#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
# 
# Name         Date       Description
# -------------------------------------------------------------------
# T. Harrison  6/19/18    Ensure FIPS 140-2 OpenSSL Cryptography Is Used
#

output=$(cat /proc/sys/crypto/fips_enabled)

if [ "$output" = 1 ] ; then
    echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    #test for fips capable system
    openssl_version=$(openssl version)
    fips_capable=$(echo "$openssl_version" | egrep "(?!^OpenSSL.+-)fips(?=.+$)")
    
    echo $output
    echo $openssl_version
    # print the reason why we are failing
    if [ "$fips_capable" = 'fips' ] ; then
        echo "FIPS not enabled"
    else
        echo "System is not FIPS capable"
    fi
    exit "${XCCDF_RESULT_FAIL:-102}"
fi