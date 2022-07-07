#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   04/08/21   Check that bootloader password is set
# E. Pinnell   07/19/21   Modified to correct error
# E. Pinnell   07/27/21   Modified to simplify script

tst1="" tst2="" output="" grubdir="" grubfile="" userfile=""

#efidir=$(find /boot/efi/EFI/* -type d -not -name 'BOOT')
#gbdir=$(find /boot -maxdepth 1 -type d -name 'grub*')
grubfile=$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -El '^\s*(kernelopts=|linux|kernel)' {} \;)
grubdir=$(dirname "$grubfile")
gfsn=$(basename "$grubfile")
userfile="$grubdir/user.cfg"

if [ -f "$userfile" ]; then
	grep -Pq '^\h*GRUB2_PASSWORD\h*=\h*.+$' "$userfile" && output="bootloader password set in \"$userfile\""
fi
if [ -z "$output" ]; then
	if [ -f "$grubfile" ]; then
		if [ "$gfsn" = "grub.conf" ]; then
			grep -Piq '^\h*password\h+\H+\h+.+$' "$grubfile" && output="bootloader password set in \"$grubfile\""
		elif [ "$gfsn" = "grub.cfg" ]; then
			grep -Piq '^\h*set\h+superusers\h*=\h*"?[^"\n\r]+"?(\h+.*)?$' "$grubfile" && tst1=pass
			grep -Piq '^\h*password(_pbkdf2)?\h+\H+\h+.+$' "$grubfile" && tst2=pass
			[ "$tst1" = pass ] && [ "$tst2" = pass ] && output="bootloader password set in \"$grubfile\""
		fi
	fi
fi

# If passing is true we pass
if [ -n "$output" ] ; then
	echo "PASSED"
	echo "$output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	echo "FAILED"
	[ -f "$userfile" ] && echo "bootloader password is not set in \"$userfile\""
	[ "$grubext" = "cfg" ] && [ ! -f "$userfile" ] && echo "\"$userfile\" doesn't exist"
	[ -f "$grubfile" ] && echo "bootloader password is not set in \"$grubfile\""
	exit "${XCCDF_RESULT_FAIL:-102}"
fi