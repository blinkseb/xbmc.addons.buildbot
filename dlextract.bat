set current=%CD%
set DEP_FILE=%CD%\scripts\dependencies.txt
cd "%DL_DIR%"

for /F "eol=; tokens=1,2" %%f in (%DEP_FILE%) do (
  
  echo Downloading %%f %%g
  if not exist %%f (
    %WGET% "%%g/%%f"
  )
  copy /b "%%f" "%TMP_DIR%"
)

cd "%TMP_DIR%"

for /F "eol=; tokens=1,2" %%f in (%DEP_FILE%) do (
  %ZIP% x %%f
)

for /F "tokens=*" %%f in ('dir /B "*.tar"') do (
  %ZIP% x -y %%f
)

cd "%current%"