#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   12/11/19   Check ufw open ports
# E. Pinnell   03/12/21   Modified to allow for entries without protocol

passing="true"

for i in $( ss -4tuln | grep LISTEN | grep -Ev "(127\.0\.0\.1|\:\:1)" | sed -E "s/^(\s*)(tcp|udp)(\s+\S+\s+\S+\s+\S+\s+\S+:)(\S+)(\s+\S+\s*$)/\4/") ; do
	ufw status | grep -Eq -- "$i(\/(tcp|udp))?\s+.*(ALLOW|DENY)" || passing=""
done

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "ufw missing a rule for an open port"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi