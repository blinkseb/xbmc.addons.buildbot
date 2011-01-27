@echo on

set SLN="addon.sln"
set RELEASE="Release"

set current_path=%CD%

set addon_dir=%1
if $%addon_dir%$ == $$ (
  echo Error: addon directory is missing.
  goto end
)

if not exist %addon_dir% (
  echo Error: addon directory does not exist.
  goto end
)

set output_dir=%2
if $%output_dir%$ == $$ (
  echo Error: output directory is missing.
  goto end
)

if not exist %output_dir% (
  echo Error: output directory does not exist.
  goto end
)

cd %addon_dir%
if not exist "windows" (
  echo Error: 'windows' directory is missing
  goto end
)

REM find vs2k10
if $"%VS100COMNTOOLS%"$ == $""$ (
  echo Error: VS100COMNTOOLS environnement variable is not set.
  goto end
) else if exist "%VS100COMNTOOLS%\..\IDE\VCExpress.exe" (
  set VS="%VS100COMNTOOLS%\..\IDE\VCExpress.exe"
) else if exist "%VS100COMNTOOLS%\..\IDE\devenv.exe" (
  set VS="%VS100COMNTOOLS%\..\IDE\devenv.exe"
) else (
  echo Error: Visual Studio not found.
  goto end
)

cd "windows"

REM download dependencies
if not exist "dependencies" goto nodeps

cd "dependencies"

echo Downloading dependencies...


REM copy dependencies
xcopy "bin\*" "..\..\addon\" /EXCLUDE:exclude.txt
cd ..

REM todo

:nodeps

REM build project
if not exist %SLN% (
  echo Error: %SLN% is missing.
  goto end
)

echo Building addons...
REM clean the solution
%VS% %SLN% /clean %RELEASE%

REM build the solution
%VS% %SLN% /build %RELEASE% /out out.log

if errorlevel 1 (
  echo Error: compilation failed
  goto end
)

cd ..

echo Copying built addons...

cd "addon"
set dir=%CD%

cd %current_path%

xcopy "%dir%\*" %output_dir% /E /Q /I /Y

echo All done.

:end
cd %current_path%