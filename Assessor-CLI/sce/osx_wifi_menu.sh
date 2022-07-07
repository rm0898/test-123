#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name		       Date       Description
# -------------------------------------------------------------------
# Edward Byrd 	 02/25/21   Check WiFi in the Menu Bar
#

UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | grep "IOPlatformUUID" | sed -e 's/^.* "\(.*\)"$/\1/')

for DIR in $(find /Users -type d -maxdepth 1); do
	PREF=$DIR/Library/Preferences/ByHost/com.apple.controlcenter.$UUID
	if [ -e $PREF.plist ]; then
		BTMenu=$(defaults read $PREF.plist WiFi 2>&1)
		if [ $BTMenu -ne 18 ]&& echo $BTMenu; then
			[ -z "$output" ] && output="User: \"$DIR\" does not have WiFi in their menu bar" 
		fi
	fi
done

# If test passed, then no output would be generated. If so, we pass
if [ -z "$output" ] ; then
	echo "PASSED: All users have WiFi in the Menu Bar"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "FAILED: The following users' do not have WiFi in their Menu Bar"
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi

