@ECHO OFF
::
:: Wrapper for invoking CIS-CAT
::
SET timestamp=%1

@echo off
echo %*
set _tail=%*
call set _tail=%%_tail:*%1=%%
echo %_tail%

SET DEBUG=0

SET JAVA=java

::
:: Detect if Java is in the path
::

%JAVA% 2> NUL > NUL

IF NOT %ERRORLEVEL%==9009 IF NOT %ERRORLEVEL%==3 GOTO RUNCISCAT

::
:: If Java is not in the PATH, try finding it at JAVA_HOME\bin
::

SET JAVA=%JAVA_HOME%\bin\java.exe

%JAVA% 2> NUL > NUL

IF NOT %ERRORLEVEL%==9009 IF NOT %ERRORLEVEL%==3 GOTO RUNCISCAT

::
:: See if x86 JRE8 is in the default location
::

SET JAVA=C:\PROGRA~2\Java\jre8\bin\java.exe

%JAVA% 2> NUL > NUL

IF NOT %ERRORLEVEL%==9009 IF NOT %ERRORLEVEL%==3 GOTO RUNCISCAT

::
:: See if JRE8 is in the default location
::

SET JAVA=C:\PROGRA~1\Java\jre8\bin\java.exe

%JAVA% 2> NUL > NUL

IF NOT %ERRORLEVEL%==9009 IF NOT %ERRORLEVEL%==3 GOTO RUNCISCAT

IF %ERRORLEVEL%==9009 GOTO NOJAVAERROR
IF %ERRORLEVEL%==3 GOTO NOJAVAERROR

::
:: Invoke CIS-CAT Pro Assessor (CLI) with a 2048MB heap
::

:RUNCISCAT

IF %DEBUG%==1 (
	ECHO Found Java at %JAVA%
	ECHO Running CIS-CAT Pro Assessor from "%~dp0"
	%JAVA% -Xmx2048M -jar "..\..\%~dp0\Assessor-CLI.jar" %_tail% --verbose
) ELSE (
	if not exist "%~dp0\..\..\logs" mkdir %~dp0\..\..\logs
	if not exist "%~dp0\..\..\logs\GUI_console_logs" mkdir %~dp0\..\..\logs\GUI_console_logs
	%JAVA% -Xmx2048M -jar "%~dp0\..\..\Assessor-CLI.jar" %_tail% > %~dp0\..\..\logs\GUI_console_logs\batchlog-%timestamp%.txt
)

GOTO EXIT

:NOJAVAERROR

ECHO The Java runtime was not found in PATH, default install locations, or JAVA_HOME.  Please ensure Java is installed.
PAUSE

:EXIT


