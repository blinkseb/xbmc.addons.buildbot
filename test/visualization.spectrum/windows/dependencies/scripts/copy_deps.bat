REM This script copy dependencies to the standard folder %LIB_DIR%, %BIN_DIR% and %INC_DIR%

cd "curl-7.21.1-devel-mingw32"

REM Binairies
xcopy "bin\*.dll" %BIN_DIR% /E /Q /I /Y

REM Libs
xcopy "lib\*" %LIB_DIR% /E /Q /I /Y

REM Includes
xcopy "include\curl\*" %INC_DIR% /E /Q /I /Y