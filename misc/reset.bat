@echo off
;If the script doesn't work, uncomment and adjust the following:
;set PATH=c:\Ruby192\bin;%PATH%
cd server
rake.bat -f Rakefile dradis:reset
