#!/usr/bin/env sh

# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   04/01/20   Check that TMOUT is configured
# E. Pinnell   03/29/21   Corrected regex and simplified script

output1="" output2=""

[ -f /etc/bashrc ] && BRC="/etc/bashrc"
[ -f /etc/bash.bashrc ] && BRC="/etc/bash.bashrc"

for f in "$BRC" /etc/profile /etc/profile.d/*.sh ; do
	if [ -f "$f" ] ; then
		grep -Pq '^\s*([^#]+\s+)?TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$f" && grep -Pq '^\s*([^#]+;\s*)?readonly\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" && grep -Pq '^\s*([^#]+;\s*)?export\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" && output1="$f"
	else
		break
	fi
done
grep -Pq '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" && output2=$(grep -P '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh $BRC)

# If the tests all pass, we pass
if [ -n "$output1" ] && [ -z "$output2" ]; then
	echo "TMOUT is configured in: \"$output1\""
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	[ -z "$output1" ] && echo "TMOUT is not configured"
	[ -n "$output2" ] && echo "TMOUT is incorrectly configured in: \"$output2\""
	exit "${XCCDF_RESULT_FAIL:-102}"
fi