#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   06/08/21   Check that audit log files are not read or write-accessible by unauthorized users

passing=""

alfdir=$(dirname "$(awk -F = '/^\s*log_file\s*=\s*\S+/ {print $2}' /etc/audit/auditd.conf)")
output="$(find $alfdir -maxdepth 1 -type f ! -user root)"

[ -z "$output" ] && passing=true

# If passing is true, we pass
if [ "$passing" = true ] ; then
	echo "Passed.  All file in \"$alfdir\" are are owned by root"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	echo "Failed!"
	for file in $output; do
		echo "file: \"$file\" is owned by \"$(stat -c "%U" "$file")\""
	done
	exit "${XCCDF_RESULT_FAIL:-102}"
fi