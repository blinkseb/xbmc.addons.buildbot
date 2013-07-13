@echo OFF

set errorcode=0

rem get the addon path
set base_dir=%CD%
set addon_dir=%base_dir%\%1

set test_dir=%addon_dir%\test
set test_file=test.reg

set output_dir=%addon_dir%\addon
set output_xml=%output_dir%\addon.xml
set audio_dll=

rem store the paths
set exec_dir=%~dp0
set bin_dir=%exec_dir%bin
set wavwriter=%bin_dir%\wavwriter.exe
set md5=%bin_dir%\md5.exe

rem check if the path provided as a parameter actually exists
if not exist %test_dir% (
  set errorcode=2
  goto failed
)

rem check if the addon.xml exists
if not exist %output_xml% (
  set errorcode=3
  goto failed
)

rem Get the output_file from the path to the addon we got
set audio_dll="%output_dir%\%~nx1.dll"

rem enter the provided path
cd %test_dir%

rem check if the test.reg file exists
if not exist %test_file% (
  set errorcode=4
  goto failed
)

rem unset the %generated% variable
set generated=
for /F "tokens=* delims=" %%t in (%test_file%) do (
  rem we didn't run the test application yet
  if not defined generated (
    rem run the test application and set the %generated% variable
    %wavwriter% %audio_dll% %%t 2>NUL
    
    rem check if the test application returned an error
    if errorlevel 1 (
      set errorcode=5
      goto failed
    )
    
    set generated=1
  ) else (
    rem time to check if the test worked
    for /F "tokens=1,2" %%i in ("%%t") do (
      rem the expected output file doesn't exist
      if not exist %%i (
        set errorcode=6
        goto failed
      )
      
      rem get the MD5 checksum of the output file
      for /F %%m in ('%md5% -n %%i') do (
        rem we don't need the generated output file anymore
        del %%i
        
        rem compare the generated MD5 checksum with the reference checksum
        if %%m == %%j goto success
        
        set errorcode=1
        goto failed
      )
      set generated=
    )
  )
)

:failed
echo 0
rem echo errorcode: %errorcode%
goto end

:success
echo 1
goto end

:end
rem go back to the base directory
cd %base_dir%
exit /B %errorcode%
