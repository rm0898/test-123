#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   02/02/21   Ensure no duplicate UIDs exist

passing="" output=""

cut -f3 -d":" /etc/passwd | sort -n | uniq -c | (while read -r x usruid ; do
	[ -z "$x" ] && break
	if [ "$x" -gt 1 ]; then
		passing=""
		[ -z "$output" ] && output="FAILED: UID \"$usruid\" is a duplicate" || output="$output, UID \"$usruid\" is a duplicate"
	else
		[ -z "$output" ] && passing=true
	fi
done

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
	echo "PASSED: There are no duplicate UIDs on the system"
	exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
	echo "$output"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi
)