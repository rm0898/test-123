#!/usr/bin/env sh

#
# CIS-CAT Script Check Engine
#
# Name         Date       Description
# -------------------------------------------------------------------
# E. Pinnell   11/19/19   Check root's path
# E. Pinnell   12/3/2019  Updated to be POSIX complient
# E. Pinnell   05/11/2021 Updated to ensure only the PATH variable is returned  
#

passing="true"
RPCV="$(sudo -Hiu root env | grep "^PATH=" | cut -d= -f2)"

if echo "$RPCV" | grep -q "::" ; then
	passing="false" 
	EDIP="root's path contains a empty directory (::)"
fi  

if echo "$RPCV" | grep -q ":$" ; then 
	passing="false"
	TCIP="root's path contains a trailing :" 
fi  

for x in $(echo "$RPCV" | tr ":" " ") ; do
	if [ "$x" = "." ] ; then
		passing="false"
		DIRP="root's PATH contains current working directory (.)"
	elif [ -d "$x" ] ; then
		[ "$(ls -ldH "$x" | awk '{print $3}')" != "root" ] && passing="false" && ONR="root doesn't own a directory in its path"
		[ "$(ls -ldH "$x" | awk '{print substr($1,6,1)}')" != "-" ] && passing="false" && DGW="root's path contains a group writable directory"
		[ "$(ls -ldH "$x" | awk '{print substr($1,9,1)}')" != "-" ] && passing="false" && DWW="root's path contains a world writable directory"
	fi
done

# If all tests pass, passing will be true, and we pass
if [ "$passing" = true ] ; then
    exit "${XCCDF_RESULT_PASS:-101}"
else
    # print the reason why we are failing
    [ -n "$EDIP" ] && echo "$EDIP"
    [ -n "$TCIP" ] && echo "$TCIP"
    [ -n "$DIRP" ] && echo "$DIRP"
    [ -n "$ONR" ] && echo "$ONR"
    [ -n "$DGW" ] && echo "$DGW"
    [ -n "$DWW" ] && echo "$DWW"
    exit "${XCCDF_RESULT_FAIL:-102}"
fi