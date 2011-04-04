@echo off

set current_path=%CD%

set SLN="addon.sln"
set RELEASE="Release"
SET WGET="%current_path%\bin\wget"
SET ZIP="%current_path%\bin\7za"
set errorcode=0

set addon_dir=%1
if $%addon_dir%$ == $$ (
  echo Error: addon directory is missing.
  set errorcode=1
  goto end
)

if not exist %addon_dir% (
  echo Error: addon directory does not exist.
  set errorcode=1
  goto end
)

set output_dir=%2
if $%output_dir%$ == $$ (
  echo Error: output directory is missing.
  set errorcode=1
  goto end
)

if exist "%output_dir%" rmdir "%output_dir%" /Q /S
md "%output_dir%"

cd %addon_dir%
if not exist "windows" (
  echo Error: 'windows' directory is missing
  set errorcode=1
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
  set errorcode=1
  goto end
)

cd "windows"

REM download dependencies
if not exist "dependencies" goto nodeps
if not exist "dependencies\scripts" goto nodeps
if not exist "dependencies\scripts\dependencies.txt" goto nodeps

cd "dependencies"
set DEP_DIR=%CD%
set TMP_DIR=%DEP_DIR%\scripts\temp
set DL_DIR=%DEP_DIR%\scripts\download
set LIB_DIR=%DEP_DIR%\lib
set BIN_DIR=%DEP_DIR%\bin
set INC_DIR=%DEP_DIR%\include
set COPY_SCRIPT=%DEP_DIR%\scripts\copy_deps.bat

if exist "%TMP_DIR%" rmdir "%TMP_DIR%" /Q /S
if exist "%DL_DIR%" rmdir "%DL_DIR%" /Q /S
if exist "%LIB_DIR%" rmdir "%LIB_DIR%" /Q /S
if exist "%BIN_DIR%" rmdir "%BIN_DIR%" /Q /S
if exist "%INC_DIR%" rmdir "%INC_DIR%" /Q /S

md "%TMP_DIR%"
md "%DL_DIR%"
md "%LIB_DIR%"
md "%BIN_DIR%"
md "%INC_DIR%"

echo Downloading dependencies...

call "%current_path%\dlextract.bat"

REM don't trust the user. Save the current directory, and restore it as soon as the copy_deps script is done
set saved_dir=%CD%

cd "%TMP_DIR%"
call "%COPY_SCRIPT%"
cd "%saved_dir%"

REM copy dependencies
echo Copy dependencies...

if exist "%DEP_DIR%\scripts\exclude.txt" (
  xcopy "%BIN_DIR%\*" "..\..\addon\" /E /Q /I /Y /EXCLUDE:%DEP_DIR%\scripts\exclude.txt
) else (
  xcopy "%BIN_DIR%\*" "..\..\addon\" /E /Q /I /Y
)

if exist "%TMP_DIR%" rmdir "%TMP_DIR%" /Q /S
if exist "%DL_DIR%" rmdir "%DL_DIR%" /Q /S

cd ..

:nodeps

REM build project
if not exist %SLN% (
  echo Error: %SLN% is missing.
  set errorcode=1
  goto clean
)

echo Building addons...
REM clean the solution
%VS% %SLN% /clean %RELEASE%

REM build the solution
%VS% %SLN% /build %RELEASE%

if errorlevel 1 (
  echo Error: compilation failed
  set errorcode=1
  goto clean
)

cd ..

echo Copying built addons...

cd "addon"

set dir=%CD%
cd %current_path%

xcopy "%dir%\*" %output_dir% /E /Q /I /Y

echo All done.

:clean
if not $%DEP_DIR%$ == $$ (
  if exist "%LIB_DIR%" rmdir "%LIB_DIR%" /Q /S
  if exist "%BIN_DIR%" rmdir "%BIN_DIR%" /Q /S
  if exist "%INC_DIR%" rmdir "%INC_DIR%" /Q /S
)

:end
cd %current_path%

exit /B %errorcode%