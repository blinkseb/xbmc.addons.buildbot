This script is meant to build XBMC binary addons on Windows platform.

Usage
=====
`buildbot.bat "<path_to_addon>" "<output_dir>"`

You can try the build script using:
`buildbot.bat "test\visualization.spectrum" "output\visualization.spectrum"`

Rules
=====
- Addon directory must contains a "windows" subdirectory
- Addon must be compilable with Visual C++ 2010 Express, and your solution must be named "addon.sln", and must reside in the "windows" folder.
- The release build must be named 'Release'
- No binairies in the repository. Dependencies will be downloaded automatically before building. See the 'Dependencies' subsection for more informations
- Your solution must copy the final built dll to then 'addon' folder. You can use the 'Custom Build Step' in project properties, with a command line like that:
    - `xcopy $(OutDir)$(TargetName)$(TargetExt) $(SolutionDir)..\addon\`
    - don't forget to set 'Outputs' to `'$(SolutionDir)..\addon\$(TargetName)$(TargetExt)'`
- For automatic testing (which is optional) there must be a "test" directory. For more details see the Test section of this document.


Dependencies
============
Since you can't have any binairies in the repository, you must provide a way to download them, either from your own repository or from the dependency's own website.

- You need a 'dependencies' folder in the 'windows' folder. When building, the script will look for a file named 'dependencies.txt', located in the 'scripts' folder (\windows\dependencies\scripts\). That file contains which dependencies need to be downloaded, with the following structure (';' are for comments) :

<pre>
; filename                              path
curl-7.21.1-devel-mingw32.zip           http://www.gknw.de/mirror/curl/win32/old_releases/
</pre>

With that dependencies file, the build system will download 'curl-7.21.1-devel-mingw32.zip' from 'http://www.gknw.de/mirror/curl/win32/old_releases/', and will extract it.

- You also need to provide a 'copy_deps.bat' script, located in the 'scripts' folder, which should handle dependencies copy. For that, you have three variables:
  - %LIB_DIR% : this folder contains .lib files needed to build the addon (\windows\dependencies\lib\)
  - %INC_DIR% : this folder contains include files needed to build the addon (\windows\dependencies\include\)
  - %BIN_DIR% : this folder contains all binairies needed to run the addon (\windows\dependencies\bin\). Every files in this folder will be copied into the 'addon' folder
  
  When the script is executed, the current directory is already set to the folder where dependencies are extracted. Here's an example for the curl dependency:

<pre>
cd "curl-7.21.1-devel-mingw32"

REM Binairies
xcopy "bin\*.dll" %BIN_DIR% /E /Q /I /Y

REM Libs
xcopy "lib\*" %LIB_DIR% /E /Q /I /Y

REM Includes
xcopy "include\curl\*" %INC_DIR% /E /Q /I /Y
</pre>

  If you want to exclude something from being copied, just provide a 'exclude.txt' file in the 'dependencies' folder. (see http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/xcopy.mspx?mfr=true for the /exclude parameter)

  Note: don't store *anything* in the dependencies folder, except the scripts folder. The 'lib', 'bin' and 'include' folders are automatically removed as soon as the build is completed.

Tests
=====
For automatic testing of the addon there must be a "test" directory in the root directory of the addon. Depending on the type of the addon (i.e. which extension point it provides) there are different tests to pass. For every test there must be a directory with the name of the extension point it tests in the "tests" directory. Every test is initiated by calling the "test.bat" script in that directory with the path to the addon that needs to be tested as a parameter. The "test.bat" must either return 1 if the test passed or 0 (with an errorlevel > 0) if the test failed.

For different extension points there are different tests and every test has its own requirements which need to be met. The available tests and their requirements are:

- xbmc.player.audiocodec:
  The "test" directory must contain at least a "test.reg" file which must contain two lines where the first line describes the parameters passed to the test application and the second line contains the path to the file to be checked and the MD5 checksum it should have. An example "test.reg" file could look like this:

<pre>
test.flac -ss 0030:0040 -o test.wav
test.wav abcdef12352123abcde
</pre>