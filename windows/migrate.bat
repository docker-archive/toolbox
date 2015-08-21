:: Batch file that installer can run. Simply runs bash script with the same name
cd %~dp0

:: Add known locations of Git to path to try and find sh.exe
set PATH=%PATH%;%ProgramFiles%\git\bin\;%ProgramFiles(x86)%\Git\bin\

where sh.exe 
if ERRORLEVEL 1 (
    echo "Could not find sh.exe"
    exit 1234
)

sh.exe --login -i migrate.sh  

:end
