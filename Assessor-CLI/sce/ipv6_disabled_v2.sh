#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   02/02/21   Check if IPv6 is disabled
# E. Pinnell   04/08/21   Modified - enhanced setting grub files location
# E. Pinnell   05/14/21   Modified to work with Fedora 28 distributions
# E. Pinnell   07/18/21   Modified to correct false negative
# E. Pinnell   7/27/21    Modified to simplify script.  No change to assessed values
# E. Pinnell   8/12/21    Modified find to accound for possible multiple returns
# E. Pinnell   11/02/21   Modified to simplify

passing=""
grubfile=$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)

if [ -s "$grubfile" ]; then
	! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
	[ "$passing" = true ] && output="IPv6 Disabled in \"$grubfile\""
fi

# Check network files
if grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" \
   /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && \
   grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" \
   /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && \
   sysctl net.ipv6.conf.all.disable_ipv6 | \
   grep -Pqs -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
   sysctl net.ipv6.conf.default.disable_ipv6 | \
   grep -Pqs -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$"; then
	[ -n "$output" ] && output="$output, and in sysctl config" || output="ipv6 disabled in sysctl config"
	passing="true"
fi

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
	echo "$output"
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	echo "IPv6 is enabled on the system"
	exit "${XCCDF_RESULT_FAIL:-102}"
fi