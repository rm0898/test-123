#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name       Date       Description
# -------------------------------------------------------------------
# E. Pinnell 03/17/21   Check AppArmor Profiles
#

passing="" test1="" test2="" output="" output2=""

if command -v apparmor_status >/dev/null; then
   pem=$(apparmor_status | awk '(/profiles are in enforce\s+mode/) {print $1}')
   pcm=$(apparmor_status | awk '(/profiles are in complain\s+mode/) {print $1}')
   apl=$(apparmor_status | awk '/ profiles are loaded/ {print $1}')
   apuc=$(apparmor_status | awk '/processes are unconfined but have a profile defined/ {print $1}')
   ngp=$((pcm+pem))
   if [ "$apl" -gt 0 ]; then
      [ "$apuc" = 0 ] && test1=passed || output="$apuc processes are unconfined but have a profile defined"
      if [ "$XCCDF_VALUE_REGEX" = complain ]; then
         [ "$ngp" = "$apl" ] && test2=passed || output2="Not all profiles are in complain or enforcing mode"
      elif [ "$XCCDF_VALUE_REGEX" = enforce ]; then
         [ "$pem" = "$apl" ] && test2=passed || output2="Not all profiles are in enforcing mode"
      fi
   else
      output2="No profiles are loaded"
   fi
   [ "$test1" = passed ] && [ "$test2" = passed ] && passing=true
else
   output="Command apparmor_status doesnt exist. Confirm AppArmor is installed"
fi


# If passing is true, we pass
if [ "$passing" = true ] ; then
   echo "PASSED! All AppArmor Profiles are in correct mode"
   exit "${XCCDF_RESULT_PASS:-101}"
else
   # print the reason why we are failing
   echo "FAILED!"
   [ -n "$output" ] && echo "$output"
   [ -n "$output2" ] && echo "$output2"
   exit "${XCCDF_RESULT_FAIL:-102}"
fi