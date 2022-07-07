#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   06/23/21   Verify file is group-owned by group (file and group need to be seporated by a ':')

passing=""
FILE=$(echo "$XCCDF_VALUE_REGEX" | awk -F : '{print $1}')
GRP=$(echo "$XCCDF_VALUE_REGEX" | awk -F : '{print $2}')

stat -c "%G" "$FILE" | grep -Eq "^$GRP\s*$" && passing=true

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
	echo "PASS. \"$FILE\" is group-owned by \"$(stat -c "%G" "$FILE")\""
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	echo "FAIL. \"$FILE\" is group-owned by \"$(stat -c "%G" "$FILE")\""
	exit "${XCCDF_RESULT_FAIL:-102}"
fi
