@echo off
setlocal ENABLEDELAYEDEXPANSION

call :SETUP_BUILD_TOOLSET
if %ERRORLEVEL% neq 0 (
  >&2 echo ERROR: Could not setup build correctly, exit code is %ERRORLEVEL%
)

echo Set current directory as the local directory
set TARGET_VERSION=latest
set SOURCES_DIR=%~dp0
set BUILDTARGET=Debug

if not [%1] == [] set BUILDTARGET=%1
set OUTPUT_DIR=%SOURCES_DIR%\bin-%BUILDTARGET%

echo Build Started in %BUILDTARGET% mode


"%SOURCES_DIR%\Nuget\Nuget.exe" restore "%SOURCES_DIR%\DF.Build.sln"
if %ERRORLEVEL% neq 0 (
	echo Warning: Nuget restore operation finished with errors, exit code: %ERRORLEVEL%>&2
)

%MSBUILD_COMMAND% "%SOURCES_DIR%\DF.Build.sln" "/p:OutputPath=%OUTPUT_DIR%" /t:Build /p:Configuration=%BUILDTARGET%
if %ERRORLEVEL% neq 0 (
	echo ERROR: Build failed, exit code: %ERRORLEVEL%>&2
	exit /B %ERRORLEVEL%
)

exit /B 0

:SETUP_BUILD_TOOLSET

if exist "%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe" (
 echo INFO: Found msbuild toolset 14
 set MSBUILD_COMMAND="%ProgramFiles(x86)%\MSBuild\14.0\Bin\MSBuild.exe"
) else if  exist "%ProgramFiles(x86)%\MSBuild\15.0\Bin\MSBuild.exe" (
 echo INFO: Found msbuild toolset 15
 set MSBUILD_COMMAND="%ProgramFiles(x86)%\MSBuild\15.0\Bin\MSBuild.exe"
) else (
 echo INFO: Searching for MSBuild
 pushd "%ProgramFiles(x86)%\Microsoft Visual Studio\2017"
 for /F "delims=" %%F in ('dir /B /S msbuild.exe') do (
	set MSBUILD_COMMAND="%%F"
	echo INFO: Found toolset: "%%F"
	popd
	exit /B 0
 )
 popd
 >&2 echo ERROR: Toolset not found for MSBuild ^> 14
 exit /B 1
)
exit /B 0
