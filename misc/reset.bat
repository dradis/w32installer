@echo off
title Dradis Framework: Resetting the environment...

::If the script doesn't work, uncomment and adjust the following:
::set PATH=c:\Ruby187\bin;%PATH%

set PATH=c:\Ruby187\lib\ruby\gems\1.8\bin\;%PATH%
set RAILS_ENV=production
set BASE=%~dp0
cd %BASE%\server\

IF NOT EXIST Gemfile.lock call bundle install
thor dradis:reset