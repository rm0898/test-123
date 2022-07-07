#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
# 
# Name                Date       Description
# -------------------------------------------------------------------
# Edward Byrd         10/28/20   User a separate timestamp for each user/tty combo
# 

ttyticket=$(
grep -E -s '!tty_tickets' /etc/sudoers
)

ttyticketd=$(
grep -E -s '!tty_tickets' /etc/sudoers.d/*
)

timestamptype=$(
grep -E -s 'timestamp_type' /etc/sudoers | cut -d '=' -f2 | grep -v 'tty'
)

timestamptyped=$(
grep -E -s 'timestamp_type' /etc/sudoers.d/* | cut -d '=' -f2 | grep -v 'tty'
)

if [ $ttyticket -n ] && [ $ttyticketd -n ] && [ $timestamptype -n ] && [ $timestamptyped -n ]; then
  output=True
else
  output=False
fi

# If result returns 0 pass, otherwise fail.
if [ "$output" == True ] ; then
	echo "$output"
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    echo "$output"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi


