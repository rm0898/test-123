#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name       Date       Description
# -------------------------------------------------------------------
# E. Pinnell 03/22/21   Check removable partition mount point options
#

passing="" rmpo="" output=""

if command -v lsblk >/dev/null; then
   for rmpo in $(lsblk -o RM,MOUNTPOINT | awk -F " " '/1/ {print $2}'); do
      if ! findmnt -n "$rmpo" | grep -Evq "\b$XCCDF_VALUE_REGEX\b"; then
         [ -z "$output" ] && passing=true
      else
         [ -z "$output" ] && output="Removable media partition(s): \"$(findmnt -n "$rmpo" | awk '{print $1}')\"" || output="$output; and \"$(findmnt -n "$rmpo" | awk '{print $1}')\""
      fi
   done
else
   output="Command \"lsblk\" not avaliable. Check failed"
   passing=true
fi
[ -z "$output" ] && passing=true



# If passing is true, we pass
if [ "$passing" = true ] ; then
   [ -n "$output" ] && echo "Manual Check Required" || echo "PASSED! Removable media partition(s) include the $XCCDF_VALUE_REGEX option"
   exit "${XCCDF_RESULT_PASS:-101}"
else
   # print the reason why we are failing
   echo "FAILED!"
   [ -n "$output" ] && echo "$output"
   echo "Don't include the $XCCDF_VALUE_REGEX option"
   exit "${XCCDF_RESULT_FAIL:-102}"
fi