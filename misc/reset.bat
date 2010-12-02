@echo off
title Dradis Framework: Resetting the environment...

::If the script doesn't work, uncomment and adjust the following:
::set PATH=c:\Ruby192\bin;%PATH%
set RAILS_ENV=production
set BASE=%~dp0
cd %BASE%\server\

IF NOT EXIST Gemfile.lock call bundle install
rake.bat -f Rakefile dradis:reset