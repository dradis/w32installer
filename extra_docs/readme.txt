Dradis version 2.5.0 installation
-------------------------------

General Information
-------------------

dradis is an open source tool for sharing information during Security Testing. 

The official home of dradis is:
    http://dradis.sourceforge.net/
Please query the website for information and documentation on the system.


The dradis installation gives the users the option to install the following components:
- Ruby
- sqlite3 files and sqlite3-ruby gem
- rake gem
- rack gem 
- RedCloth gem 
- dradis server

Note when installing as a limited access user:
The sqlite3 and wxruby gems are dependant on the following dlls to be in the system32: 
- sqlite3.dll
- msvcrt.dll
If installer did not have access to the system32 then these files need to be copied 
manually. Simply copy them from the dradis install directory to the $windows\system32 
folder.

Ruby
----
The ruby installation downloads the ruby one click installer and executes it. 
The ruby installation is independent of the dradis installation.


sqlite3
-------
The installer copies the sqlite3.dll file to the $WINDOWS\system32 folder. 
It also copies the sqlite3-ruby gem (version 1.2.3) binary file to the installation folder 
and it then installs the gem locally. 


rake
----
The installer uses a the rake-0.8.7.gem file to install the rake gem locally.


rack
----
The rack gem is installed locally from the rack-1.1.0.gem file. Rack is required
by Rails


RedCloth
--------
The RedCloth gem is installed locally from the RedCloth-4.2.2-x86-mswin32-60.gem file. RedCloth is used to render the mark-up styled notes to HTML in the browser.


dradis server
-------------
All the dardis sever files are copied to the installation folder. 
The sqlite database is created by calling the rake function. 
The rest of the server configuration is left as is. 
The installer creates a short cut to start the server in the Start Menu.  


Uninstall
---------
The uninstaller removes the dradis client and the dradis server from the 
local system. Because other applications might be dependent on the gems or 
the Sqlite3.dll it is left to the user to remove these manually. This can be done with by following these steps:
- run "gem uninstall sqlite3-ruby" in the command line
- run "gem uninstall rake" in the command line
- run "gem uninstall rack" in the command line
- run "gem uninstall RedCloth" in the command line

3 Februart 2010