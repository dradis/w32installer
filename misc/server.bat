@echo off

::If the script doesn't work, uncomment and adjust the following:
::set PATH=c:\Ruby193\bin;%PATH%

set RAILS_ENV=production
set BASE=%~dp0
cd %BASE%\server\

start "Dradis Framework Server (Ctrl+C to terminate)" bundle exec rails server webrick %*
