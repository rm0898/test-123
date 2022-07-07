#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   02/02/21   Ensure no duplicate user names exist

passing="" output=""

cut -f1 -d":" /etc/passwd | sort -n | uniq -c | (while read -r x usrname ; do
	[ -z "$x" ] && break
	if [ "$x" -gt 1 ]; then
		passing=""
		[ -z "$output" ] && output="FAILED: user name \"$usrname\" is a duplicate" || output="$output, user name \"$usrname\" is a duplicate"
	else
		[ -z "$output" ] && passing=true
	fi
done

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ]; then
	echo "PASSED: There are no duplicate user names on the system"
	exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
	echo "$output"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi
)