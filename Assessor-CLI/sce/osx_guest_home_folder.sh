#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         09/16/20   Remove Guest home folder
# 

guesthome=$(
ls /Users/ | grep Guest 
)

if [ $guesthome -n ] ; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
