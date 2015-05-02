@echo off

cd %APPVEYOR_BUILD_FOLDER%

:: Downloand and install blast to C:\blast

set ZIP_URL=https://github.com/npge/npge/releases/download/0.3.0/npge_0.3.0_win32.zip

if not exist c:\blast\blastn.exe (
    curl --silent --fail --max-time 120 --connect-timeout 30 %ZIP_URL% > npge_0.3.0_win32.zip
    7z x npge_0.3.0_win32.zip
    copy npge-0.3.0\blastn.exe c:\blast
    copy npge-0.3.0\makeblastdb.exe c:\blast
    copy npge-0.3.0\vcomp100.dll c:\blast
) else (
    echo BLAST already installed at c:\blast
)
