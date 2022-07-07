#!/bin/bash

#DIR="$(dirname "$0")"
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/make-jre-directories.sh"
. "$DIR/detect-os-variant.sh"
. "$DIR/map-to-benchmark.sh"

#
# This script is intended to reside on a centralized file share that is accessible by the computers
# to be assess by CIS-CAT. 
#
# The default configuration of this script expects the following target-facing file structure:
# 
#        /cis
#        /cis/Assessor-CLI
#        ...      
#        /cis/Assessor-CLI/Assessor-CLI.jar
#        ...
#        /cis/reports
#        /cis/jres
#        /cis/jres/AIX
#        ...
#        /cis/jres/AIX/bin/java
#        ...
#        /cis/jres/Debian
#        /cis/jres/HPUX
#        /cis/jres/Linux
#        /cis/jres/OSX
#        /cis/jres/RedHat
#        /cis/jres/Solaris
#        /cis/jres/SolarisSparc
#        /cis/jres/SUSE

#
#       Note: cis-cat-centralized.sh --make-jre-directories  will create the jres/* directories. However,
#                you will need to download and unzip the appropriate JRE into these folders. JREs can be
#                obtained from the following URLS:
#
#                === IBM AIX === 
#                URL:
#                http://www.ibm.com/developerworks/java/jdk/aix/service.html
# 
#                Notes: 
#                IBM creates a redistributable "latest" JRE .bin. They also have a JRE .tar. 
# 
#                === Linux ===# 
#                URL: http://java.com/en/download/manual.jsp
# 
#                Note: This JRE is expected to work for RedHat, Debian, and SUSE.
# 
#                === Solaris ===# 
#                URL: http://java.com/en/download/manual.jsp
# 
#                Notes: one for SPARC and one for X86
#  
#                === HP-UX ===
#                URL: http://h18012.www1.hp.com/java/
#                URL: https://h20392.www2.hp.com/portal/swdepot/displayProductInfo.do?productNumber=HPUXJAVAHOME
# 
#                === Apple OSX === 
#                URL: http://support.apple.com/downloads/Java_for_Mac_OS_X_10_5_Update_4
#                URL: http://support.apple.com/kb/DL1360
#                URL: http://support.apple.com/kb/DL1421
#

#
# Modify the following three variables to align with target-facing file structure implemented 
# in your environment.
#
CISCAT_DIR=/cis/Assessor-CLI
REPORTS_DIR=/cis/Assessor-CLI/reports
JRE_BASE=/cis/jres

#
# There is no need to make modifications below this point unless you want to override the benchmark profile 
# CIS-CAT uses. The default configuration of this script will cause CIS-CAT to run the "Level 2" equivalent
# profile, which includes all "Level 1" profile checks. 
#

# determine if this execution is setting up jre directories or not. 
if [ $1 ]; then
	if [ "$1" == "--make-jre-directories" ]; then
		make_jre_directories;
		exit 1;
	fi
fi

SSLF='0'
BENCHMARK='<UnknownBenchmark>'
PROFILE1='<UnknownProfile>'
PROFILE2='<UnknownProfile>'
DISTRO='<UnknownDistribution>'
VER='<UnknownVersion>'
OSV='<UnknownOSVersion>'
ARFORXML='-arf'

# sets DISTRO and VER
detect_os_variant

JAVA_HOME=$JRE_BASE/$DISTRO

# sets BENCHMARK and PROFILE
map_to_benchmark $DISTRO $VER

#
# Configure CIS-CAT report generation options:
#
# -html : Generate an HTML report
# -txt  : Generate a Text report
# -csv  : Generate a CSV report
# -narf : Do NOT generate an Asset Reporting Format (ARF) report
# -json : Generate a JSON report
# -npr  : Generate the "non-passing results" report in JSON
# -nts  : Do NOT append the timestamp to the report names
#
CISCAT_OPTS=" -html -csv -txt -rd $REPORTS_DIR -b $CISCAT_DIR/benchmarks/$BENCHMARK "
CISCAT_CMD="$JAVA_HOME/bin/java -Xmx2048M -jar $CISCAT_DIR/Assessor-CLI.jar $CISCAT_OPTS"

echo
echo "Detected OS as $DISTRO $VER"
echo "Using JRE located at '$JAVA_HOME'"
echo "Using CISCAT located at '$CISCAT_DIR/Assessor-CLI.jar'"
echo "Using Benchmark '$BENCHMARK'"
if [ "$SSLF" -eq "1" ]; then
	echo "Using Profile '$PROFILE2'"
else
	echo "Using Profile '$PROFILE1'"
fi
echo "Storing Reports at '$REPORTS_DIR'"
echo

GOOD=1

if [ ! -d "$CISCAT_DIR" ]; then
        echo "ERROR: CISCAT_DIR does not point to a valid directory"
        GOOD=0
fi

if [ ! -e "$CISCAT_DIR/Assessor-CLI.jar" ]; then
        echo "ERROR: Assessor-CLI.jar does not exist at '$CISCAT_DIR/Assessor-CLI.jar'"
        GOOD=0
fi

if [ ! -d "$REPORTS_DIR" ]; then
        echo "ERROR: REPORTS_DIR does not point to a valid directory"
        GOOD=0
fi

if [ ! -d "$JRE_BASE" ]; then
        echo "ERROR: JRE_BASE does not point to a valid directory"
        GOOD=0
fi

if [ ! -d "$JAVA_HOME" ]; then
        echo "ERROR: JAVA_HOME does not point to a valid directory"
        GOOD=0
fi

if [ ! -e "$JAVA_HOME/bin/java" ]; then
        echo "ERROR: java does not exist at '$JAVA_HOME/bin/java'"
        GOOD=0
fi

if [ ! -e "$CISCAT_DIR/benchmarks/$BENCHMARK" ]; then
        echo "ERROR: Benchmark '$BENCHMARK' does not exist in directory '$CISCAT_DIR/benchmarks'  "
        GOOD=0
fi

if [ "$GOOD" -eq "1" ]; then
        echo
        echo "Running CISCAT with the following options: "
        echo
        
        if [ "$SSLF" -eq "1" ]; then
		echo "  $CISCAT_OPTS" -p "$PROFILE2"
		echo

		$CISCAT_CMD -p "$PROFILE2"
	else
		echo "  $CISCAT_OPTS" -p "$PROFILE1"
		echo
		
		$CISCAT_CMD -p "$PROFILE1"
	fi
else
        echo
        echo "Please review errors listed above, make corrective actions, and retry."
        echo
fi
