#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Sara Lynn Archacki  04/02/19   Reduce the sudo timeout period
# Eric Pinnell        04/23/20   Fixed Test

output=$(grep timestamp /etc/sudoers)
grep -Eq '\s*Defaults\s+timestamp_timeout\s*=\s*0\b' /etc/sudoers && passing=true

# If results returns pass, otherwise fail.
if [ "$passing" = "true" ] ; then
	echo "PASSED, \"$output\""
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "Failed: \"$output\""
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
