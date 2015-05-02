@echo off

cd %APPVEYOR_BUILD_FOLDER%

:: Downloand and install blast to C:\blast

set ZIP_URL=https://github.com/npge/npge/releases/download/0.3.0/npge_0.3.0_win32.zip

if not exist c:\blast\blastn.exe (
    curl --silent --fail --max-time 120 --connect-timeout 30 -L --output npge_0.3.0_win32.zip %ZIP_URL%
    7z x npge_0.3.0_win32.zip
    mkdir c:\blast 2>NUL
    copy npge-0.3.0\blastn.exe c:\blast
    copy npge-0.3.0\makeblastdb.exe c:\blast
    copy npge-0.3.0\vcomp100.dll c:\blast
    echo BLAST files were copied to c:\blast
) else (
    echo BLAST already installed at c:\blast
)

set PATH=c:\blast;%PATH%
echo c:\blast added to PATH
