#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   06/20/20   Check that Uncomplicated Firewall (UFW) is not required (either nftables or iptables is being used)
# E. Pinnell   07/10/20   Modified

passing=""
ufwni=""
ufwne=""
noufw=""
nftd=""
iptpi=""

# Check UFW status
if ! dpkg-query -s ufw 2>/dev/null | grep -q 'Status: install ok installed'; then
	ufwni=y
else
	ufwni=n
	ufw status | grep 'Status: inactive' && ufwne=y
	ufw status | grep 'Status: active' && ufwne=n
fi
if [ "$ufwni" = y ] || [ "$ufwne" = y ]; then
	noufw=y
fi
# Check nftables status
systemctl is-enabled nftables 2>/dev/null | grep -q 'enabled' && nftd=n
# Check IPTables
dpkg-query -s iptables-persistent 2>/dev/null | grep -q 'Status: install ok installed' && iptpi=y
# check if ufw is not the firewall configuration methiod in use
if [ "$nftd" = n ] || [ "$iptpi" = y ]; then
	[ "$noufw" = y ] && passing=true
fi

# If passing is true, we pass
if [ "$passing" = true ] ; then
	[ "$iptpi" = y ] && echo "IPTables are being used on this system"
	[ "$nftd" = n ] && echo "NFTables are being used on this system"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
	[ "$ufwne" = n ] && echo "Uncomplicated Firewall is active on the system"
    [ "$nftd" != n ] && [ "$iptpi" != y ] && echo "Both IPTables and NFTables are not configured"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi