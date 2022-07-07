#!/usr/bin/env sh

# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   10/23/19   script to detects uid of the system (Some are 500 newer systems are 1000), finds privlieged commands, and looks for corasponding entries in a auditd rules file
# E. Pinnell   02/10/20   Modified to allow for any key value

passing=true

find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>='"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' -F auid!=4294967295 -k" }' | ( while read -r line
do
  grep -E -- "^\s*$line\s+\S+ *$" /etc/audit/rules.d/*.rules || passing=false
done

# If the regex matched, output would be generated.  If so, we pass
if [ "$passing" = true ] ; then
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "Missing auditd rules."
    exit "${XCCDF_RESULT_FAIL:-102}"
fi
)
