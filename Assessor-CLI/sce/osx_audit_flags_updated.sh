#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         09/17/20   Security Audit has flags configured
# Edward Byrd		  01/20/21	 Updated with updated flags
# Edward Byrd		  10/25/21	 Updated with updated flags

flagfm=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "fm"
)

flagad=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "ad"
)

flagex=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "ex"
)

flagaa=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "aa"
)

flagfr=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "fr"
)

flaglo=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "lo"
)

flagfw=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "fw"
)


flagall=$(
grep -e "^flags:" /etc/security/audit_control | grep -v "all"
)

if ( [$flagfm -n ] && [ $flagad -n ] &&  [ $flagaa -n ]  &&  [ $flaglo -n ] && [ $flagex -n ] && [ $flagfr -n ] && [ $flagfw -n ] ) || ( [$flagfm -n ] && [ $flagad -n ] &&  [ $flagaa -n ]  &&  [ $flaglo -n ] && [ $flagall -n ] ); then
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



