#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   04/09/21   Check grub options exists
# E. Pinnell   07/27/21   Modified to correct error and simplify script

output="" grubfile="" grubdir="" gdsn="" grubext="" passing=""

grubfile=$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -El '^\s*(kernelopts=|linux|kernel)' {} \;)
# grubdir=$(dirname "$grubfile")
gfsn=$(basename "$grubfile")
# grubext="$(echo "$gfsn" | cut -d. -f2)"

if [ -f "$grubfile" ]; then
	if [ "$gfsn" = "grub.conf" ]; then
		! grep -P "^\s*kernel" "$grubfile" | grep -Pvq "\b$XCCDF_VALUE_REGEX\b" && passing=true
		output="$(grep -P '^\h*kernel.*$' "$grubfile" | grep -P "\b$XCCDF_VALUE_REGEX\b")"
	elif [ "$gfsn" = "grub.cfg" ]; then
		! grep -P "^\h*linux.*$" "$grubfile" | grep -Pvq "\b$XCCDF_VALUE_REGEX\b" && passing=true
		output="$(grep -P "^\h*linux.*$" "$grubfile" | grep -P "\b$XCCDF_VALUE_REGEX\b")"
	elif [ "$gfsn" = "grubenv" ]; then
		! grep -P "^\h*kernelopts=.*$" "$grubfile" | grep -Pvq "\b$XCCDF_VALUE_REGEX\b" && passing=true
		output="$(grep -P "^\h*kernelopts=.*$" "$grubfile" | grep -P "\b$XCCDF_VALUE_REGEX\b")"
	fi
fi

# If passing is true we pass
if [ "$passing" = true ] ; then
	echo "PASSED"
	echo "\"$grubfile\" contains: "
	echo $output
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	echo "FAILED:"
	echo "\"$grubfile\" doesn't contain: \"$XCCDF_VALUE_REGEX\""
	exit "${XCCDF_RESULT_FAIL:-102}"
fi