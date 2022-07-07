#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   02/01/21   Ensure all users last password change date is in the past

passing="" output=""

for usr in $(cut -d: -f1 /etc/shadow); do
	lpcd=$(chage --list "$usr" | grep '^Last password change' | cut -d: -f2)
	if [ -n "$lpcd" ] && [ "$(date --date="$lpcd" +%s)" -le "$(date "+%s")" ]; then
		[ -z "$output" ] && passing=true
	else
		passing=""
		[ -z "$output" ] && output="FAILED: User: \"$usr\" last password change was \"$lpcd\"" || output=", User: \"$usr\" last password change was \"$lpcd\""
	fi
done

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
	echo "PASSED: All uses last password change in the past"
	exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
	echo "$output"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi