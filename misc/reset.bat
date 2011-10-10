@echo off
title Dradis Framework: Resetting the environment...

::If the script doesn't work, uncomment and adjust the following:
::set PATH=c:\Ruby187\bin;%PATH%

set RAILS_ENV=production
set BASE=%~dp0
cd %BASE%\server\

IF NOT EXIST Gemfile.lock goto installgems
goto end

:installgems
:: Include the Ruby DevKit in the path
call "%BASE%\DevKit\devkitvars.bat"

:: Install dependencies
call bundle install --without=test development

:end
bundle exec thor dradis:reset
rem end
