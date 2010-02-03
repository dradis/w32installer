The sqlite3 and wxruby gems are dependant on the following dlls to be in the system32: 
- sqlite3.dll
- msvcrt.dll
If installer did not have access to the system32 then these files need to be copied 
manually. Simply copy them from the dradis install directory to the $windows\system32 
folder.