#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   02/02/21   Ensure no duplicate group names exist

passing="" output=""

cut -f1 -d":" /etc/group | sort -n | uniq -c | (while read -r x grpname; do
	[ -z "$x" ] && break
	if [ "$x" -gt 1 ]; then
		passing=""
		[ -z "$output" ] && output="FAILED: group name \"$grpname\" is a duplicate" || output="$output, group name \"$grpname\" is a duplicate"
	else
		[ -z "$output" ] && passing=true
	fi
done

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
	echo "PASSED: There are no duplicate group names on the system"
	exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
	echo "$output"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi
)