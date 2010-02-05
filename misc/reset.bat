@echo off
set PATH=c:\Ruby\bin;%PATH%
cd server
"c:\Ruby\bin\rake.bat" -f Rakefile dradis:reset
