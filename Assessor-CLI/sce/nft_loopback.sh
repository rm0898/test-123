#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   02/12/20   Check nftables Loopback
# E. Pinnell   05/18/20   Modified to allow for multiple methiods of disableing IPv6

test1=""
test2=""
test3=""

command -v nft && nft list ruleset | awk '/hook input/,/}/' | grep -Eq '^\s*iif\s+"lo"\s+accept' && test1="pass"
command -v nft && nft list ruleset | awk '/hook input/,/}/' | grep -Eq '^\s*ip\s+saddr\s+127\.0\.0\.0\/8\s+counter\s+packets\s+0\s+bytes\s+0\s+drop' && test2="pass"

#Test if IPv6 is disabled, if it's not disabled, check if IPv6 loobback is configured
# Check if IPv6 is disabled in grub.cfg
if [ -f /boot/grub/grub.cfg ]; then
	[ -z "$(grep "^\s*linux" /boot/grub/grub.cfg | grep -v "ipv6.disable=1")" ] && test3="pass"
elif [ -f /boot/grub2/grub.cfg ]; then
	[ -z "$(grep "^\s*linux" /boot/grub2/grub.cfg | grep -v "ipv6.disable=1")" ] && test3="pass"
fi
# If IPv6 hasn't been disabled in grub, check if it's disabled in /etc/sysctl.conf or a .conf file in  the /etc/sysctl.d directory
if [ "$test3" != pass ]; then
	grep -Eq '^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b' /etc/sysctl.conf /etc/sysctl.d/*.conf && grep -Eq '^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b' /etc/sysctl.conf /etc/sysctl.d/*.conf && sysctl net.ipv6.conf.all.disable_ipv6 | grep -Eq '^\s*net\.ipv6\.conf\.all\.disable_ipv6\s*=\s*1\b' && sysctl net.ipv6.conf.default.disable_ipv6 | grep -Eq '^\s*net\.ipv6\.conf\.default\.disable_ipv6\s*=\s*1\b' && test3="pass"
fi
# If IPv6 isn't disabled, then check the IPv6 loopback
if [ "$test3" != pass ]; then
	command -v nft && nft list ruleset | awk '/hook input/,/}/' | grep -Eq '^\s*ip6\s+saddr\s+\:\:1\s+counter\s+packets\s+0\s+bytes\s+0\s+drop' && test3="pass"
fi
# Check to see if loopback is configured, if all tests are set to pass, passing will be true
[ "$test1" = pass ] && [ "$test2" = pass ] && [ "$test3" = pass ] && passing="true"

# If the tests pass, passing is set to true.  If so, we pass
if [ "$passing" = true ] ; then
	echo "nftables loopback is configured"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    [ "$test1" != pass ] && echo "\"iif \"lo\" accept\" is not set"
    [ "$test2" != pass ] && echo "Packets sourced from \"127.0.0.1\" are not set to drop"
    [ "$test3" != pass ] && echo "IPv6 is enabled, but packets sourced from \"::1\" are not set to drop"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi