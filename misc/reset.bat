::If the script doesn't work, uncomment and adjust the following:
::set PATH=c:\Ruby192\bin;%PATH%
cd server
call bundle install
rake.bat -f Rakefile dradis:reset
cd ..