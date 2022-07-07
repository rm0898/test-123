#!/usr/bin/env bash

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   04/21/21   Check kernel parameter
# E. Pinnell   12/03/21   Modified to deal with potential white space in the XCCDF_VALUE_REGEX variable

tst1="" tst2="" tst3="" passing=""

kpname=$(printf "%s" "$XCCDF_VALUE_REGEX" | awk -F= '{print $1}' | xargs)
kpvalue=$(printf "%s" "$XCCDF_VALUE_REGEX" | awk -F= '{print $2}' | xargs)

sysctl "$kpname" | grep -q -- "$kpvalue" && tst1=pass
grep -Psq -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" /run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf && tst2=pass
! grep -Psq -- "^\h*$kpname\h*=\h*[^$kpvalue]\b\h*(.*)?$" /run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf && tst3=pass

[ "$tst1" = pass ] && [ "$tst2" = pass ] && [ "$tst3" = pass ] && passing=true

# If the regex matched, output would be generated. If so, we pass
if [ "$passing" = true ] ; then
	echo "PASSED: kernel parameter: \"$kpname\" is set too: \"$kpvalue\""
	exit "${XCCDF_RESULT_PASS:-101}"
else
	# print the reason why we are failing
	echo "FAILED:"
	[ "$tst1" != pass ] && echo "\"$kpname\" not set correctly in the running config"
	[ "$tst2" != pass ] && echo "\"$kpname\" not set in any kernel configuration file"
	[ "$tst3" != pass ] && echo "\"$kpname\" set incorrectly in: \"$(grep -Pls -- "^\h*$kpname\h*=\h*[^$kpvalue]\b\h*(.*)?$" /run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf | grep -Pv -- "$kpvalue")\""
	exit "${XCCDF_RESULT_FAIL:-102}"
fi