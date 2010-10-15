# dradis-v2_5-setup.nsi
# 20 January 2009
# siebert lubbe (siebertlubbe at googlemail dot com)
#
# Desc:
#   This is the code for the dradis windows installer
#
#   The majority of the code was generated with the HM NIS Script Wizard.
#   This is mostly code regarding the general framework of the installer
#   and the creation and copying of the installation files
#
# Version:
#  v1.0 [20 January 2009]: first released
#
# License:
#   See dradis.rb or LICENSE.txt for copyright and licensing information.

; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "dradis"
!define PRODUCT_VERSION "2.6"
!define PRODUCT_PUBLISHER "Dradis Framework Team"
!define PRODUCT_WEB_SITE "http://dradisframework.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; inlude logic lib for more readable code logic
!include LogicLib.nsh

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "images\dradis.ico"
!define MUI_UNICON "images\dradis_uninstall.ico"

; Welcome page
# this is the image file that is displayed to the left of the welcome pages
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "images\welcome.bmp"
# this is the text to be displayed at the start of installation
!define MUI_WELCOMEPAGE_TEXT "This wizard wil guide you through the installation of dradis version 2.5 \r\n \r\nClick next to continue."
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "misc\LICENSE.txt"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
Section
SetOutPath "$INSTDIR"
readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
;readRegStr $0 HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\{BD5F3A9C-22D5-4C1D-AEA0-ED1BE83A1E67}_is1" "Inno Setup: App Path"
${If} $0 != ''
  !define MUI_FINISHPAGE_RUN_TEXT "Initialise dradis"
  !define MUI_FINISHPAGE_RUN "$INSTDIR\reset.bat"
;  !define MUI_FINISHPAGE_RUN "$0\bin\rake.bat"
;  !define MUI_FINISHPAGE_RUN_PARAMETERS "-f $\"$INSTDIR\server\Rakefile$\" dradis:reset"
${EndIf}
SectionEnd
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.txt"
!define MUI_FINISHPAGE_LINK "http://dradisframework.org"
!define MUI_FINISHPAGE_LINK_LOCATION "http://dradisframework.org"
!define MUI_FINISHPAGE_LINK_COLOR "0000FF"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
# this is the text to be displayed to the user at the end of uninstallation
!define MUI_FINISHPAGE_TEXT "The following components was successfully removed: \r\n - dradis server\r\n \r\nThe the dradis server folder was not removed from the install location.\r\nIt contains the database files that was created since installation.\r\nPlease remove manually.\r\nIf you want to remove ruby, RedCloth or sqlite3 please do so manually.\r\n - ruby: uninstall option in the ruby start menu folder\r\n - RedCloth: execute 'gem uninstall RedCloth' from the command line\r\n - sqlite3: execute 'gem uninstall sqlite3-ruby' from the command line\r\n"
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "dradis-v2.6.0-setup.exe"
InstallDir "$APPDATA\dradis-2.6"
ShowInstDetails show
ShowUnInstDetails show

; place the creation of the start menu folder here because we need the folder in the other sections
Section
  CreateDirectory "$SMPROGRAMS\dradis"
  SetOutPath "$INSTDIR\dlls"
  File "misc\dlls\README.dlls.txt"
  CreateDirectory "$INSTDIR\images"
  SetOutPath "$INSTDIR\images"
  File "images\dradis.ico"
  CreateDirectory "$SMPROGRAMS\dradis"
  CreateShortCut "$SMPROGRAMS\dradis\dradisframework.org.lnk" "$INSTDIR\dradisframework.org.url"
  CreateShortCut "$SMPROGRAMS\dradis\dradis web interface.lnk" "$INSTDIR\dradis web interface.url" "$INSTDIR\images\dradis.ico"
  CreateShortCut "$SMPROGRAMS\dradis\Uninstall.lnk" "$INSTDIR\uninst.exe"lp
SectionEnd

; this section handles the installation of ruby
Section "ruby" SEC01
  ClearErrors
  ; read the registry to check if there is not already a local installation of ruby
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    MessageBox MB_OK 'Ruby 1.9.2 is already installed on the system. The automated installation of Ruby will not proceed'
  ${Else}
    ; no ruby installer
    MessageBox MB_OK 'The Ruby 1.9.2 installer will now be downloaded and executed. This might take a few moments.'
    ; download and install ruby
    ;NSISdl::download /NOIEPROXY "http://rubyforge.org/frs/download.php/47082/ruby186-27_rc2.exe" "ruby186-27_rc2.exe"
    NSISdl::download /NOIEPROXY "http://rubyforge.org/frs/download.php/72170/rubyinstaller-1.9.2-p0.exe" "rubyinstaller-1.9.2-p0.exe"
    Pop $R0
    ${If} $R0 == 'success'
      ; ruby download successful
      StrCpy $0 ''
      ; rum the one click installer
      ExecWait '"rubyinstaller-1.9.2-p0.exe"' $0
      ${If} $0 == ''
        ; execution of one click installer failed
        MessageBox MB_OK "Ruby 1.9.2 install failed. Please install Ruby manually: http://rubyinstaller.org/"
      ${EndIf}
      ; delete the ruby one click installer
      Delete "rubyinstaller-1.9.2-p0.exe"
    ${Else}
      Delete "rubyinstaller-1.9.2-p0.exe"
      ; ruby download not successfull
      MessageBox MB_OK "Ruby download failed. Please download and install Ruby manually: http://rubyinstaller.org/"
    ${EndIf}
  ${EndIf}
SectionEnd

;Section "Graphical Library (wxruby 1.9.9)" SEC02
;  SetOutPath "$WINDIR\system32"
;  SetOverwrite off
  ; dependant dll's
;  File "misc\msvcr71.dll"
;  File "misc\MSVCP71.DLL"
;  SetOVerwrite ifnewer
  
;  SetOutPath "$INSTDIR\dlls"
;  File "misc\msvcr71.dll"
;  File "misc\MSVCP71.DLL"
;  SetOutPath "$INSTDIR\client"
;  File "misc\wxruby-1.9.9-x86-mswin32-60.gem"
;  # check if ruby is installed and install the wxruby gem locally if so
;  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
;  ${If} $0 != ''
;    ; ruby installed
;    StrCpy $1 ''
;    ; install the wxruby locally
;    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri wxruby-1.9.9-x86-mswin32-60.gem' $1
;    ${If} $1 == ''
;      MessageBox MB_OK "Gem install failed. Please install the wxruby (version 1.9.9) gem manually"
;    ${EndIf}
;  ${Else}
;    ; ruby not installed
;    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the wxruby (version 1.9.9) gem manually"
;  ${EndIf}
;  Delete "wxruby-1.9.9-x86-mswin32-60.gem"
;SectionEnd

Section "Database Layer (sqlite3 1.2.3)" SEC03
  ; copies the sqlite dll to the system 32 folder
  SetOutPath "$WINDIR\system32"
  File "misc\dlls\sqlite3.dll"
  SetOverwrite off
  ; sqlite dll is dependant on msvcrt dll
  File "misc\dlls\msvcrt.dll"
  SetOVerwrite ifnewer
  SetOutPath "$INSTDIR\dlls"
  File "misc\dlls\sqlite3.dll"
  File "misc\dlls\msvcrt.dll"
  File "misc\gems\sqlite3-ruby-1.2.3-mswin32.gem"
  # check if ruby is installed and install the gem gem locally if so
  ;readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the wxruby locally
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri sqlite3-ruby-1.2.3-mswin32.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the sqlite3-ruby (version 1.2.3) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the sqlite3-ruby (version 1.2.3) gem manually"
  ${EndIf}
  Delete "sqlite3-ruby-1.2.3-mswin32.gem"
SectionEnd

;Section "Dradis Client" SEC04
;  !include "client_install.nsh"
;  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
;  ${If} $0 == ''
;    MessageBox MB_OK "Ruby is not installed. A shortcut to start the dradis client will not be created. Start the client from the commandline: ruby $INSTDIR\client\dradis.rb. Use -g as a commandline argument for the graphical user interface"
;  ${Else}
;    SetOutPath "$INSTDIR\client"
;    # create a shortcuts to start the dradis client from the start menu
;    CreateShortCut "$SMPROGRAMS\dradis\start client (command line).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb"'
;    CreateShortCut "$SMPROGRAMS\dradis\start client (graphical).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb" -g'
;    # create a shortcuts to start the dradis client in the install directory
;    CreateShortCut "$INSTDIR\start client (command line).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb"'
;    CreateShortCut "$INSTDIR\start client (graphical).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb" -g'
;  ${EndIf}
;SectionEnd

Section "Dradis Server" SEC05
  !include "server_install.nsh"
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 == ''
    MessageBox MB_OK "Ruby 1.9.2 is not installed. No shortcuts to start the dradis Framework will not be created. Start dradis from the commandline: cd $INSTDIR; ruby.exe script\rails server"
  ${Else}
    SetOutPath "$INSTDIR\server"
    # create shortcuts to start the dradis server from the start menu or install directory
    CreateShortCut "$SMPROGRAMS\dradis\start dradis server.lnk" "$0\bin\ruby.exe" '"$INSTDIR\server\script\rails server"' "$INSTDIR\images\dradis.ico"
    CreateShortCut "$INSTDIR\start dradis server.lnk"  "$0\bin\ruby.exe" '"$INSTDIR\server\script\rails server"' "$INSTDIR\images\dradis.ico"
    
    SetOutPath "$INSTDIR"
    ;CreateShortCut "$SMPROGRAMS\dradis\reset server (deletes db and attachments).lnk" "$0\bin\rake.bat" "dradis:reset"
    CreateShortCut "$SMPROGRAMS\dradis\reset server (deletes db and attachments).lnk" "$INSTDIR\reset.bat"
    ;CreateShortCut "$INSTDIR\reset server (deletes db and attachments).lnk" "$0\bin\rake.bat" "dradis:reset"
    
  ${EndIf}
SectionEnd

Section "Rake 0.8.7" SEC06
  SetOutPath "$INSTDIR\"
  File "misc\gems\rake-0.8.7.gem"
  # check if ruby is installed and install the rake gem locally if so
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the rake locally
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri rake-0.8.7.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the rake (version 0.8.7) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the rake (version 0.8.7) gem manually"
  ${EndIf}
  Delete "rake-0.8.7.gem"
SectionEnd

Section "Rack 1.1.0" SEC07
  SetOutPath "$INSTDIR\"
  File "misc\gems\rack-1.1.0.gem"
  # check if ruby is installed and install the rack gem locally if so
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the rack locally
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri rack-1.1.0.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the rack (version 1.1.0) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the rack (version 1.1.0) gem manually"
  ${EndIf}
  Delete "rack-1.1.0.gem"
SectionEnd

Section "RedCloth 4.2.2" SEC08
  SetOutPath "$INSTDIR\"
  File "misc\gems\RedCloth-4.2.2-x86-mswin32-60.gem"
  # check if ruby is installed and install the RedCloth gem locally if so
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the RedCloth locally
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri RedCloth-4.2.2-x86-mswin32-60.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the RedCloth (version 4.2.2) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the RedCloth (version 4.2.2) gem manually"
  ${EndIf}
  Delete "RedCloth-4.2.2-x86-mswin32-60.gem"
SectionEnd

;Section "Meta-Server" SEC09
;  !include "meta-server_install.nsh"
;  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
;  ${If} $0 == ''
;    MessageBox MB_OK "Ruby is not installed. A shortcut to start the dradis client will not be created. Start the client from the commandline: ruby $INSTDIR\client\dradis.rb. Use -g as a commandline argument for the graphical user interface"
;  ${Else}
;    SetOutPath "$INSTDIR\meta-server"
;    # create shortcuts to start the dradis meta-server from the start menu or install directory
;    CreateShortCut "$SMPROGRAMS\dradis\start dradis meta-server.lnk" "$0\bin\ruby.exe" '"$INSTDIR\meta-server\script\server"'
;    CreateShortCut "$INSTDIR\start dradis meta-server.lnk"  "$0\bin\ruby.exe" '"$INSTDIR\meta-server\script\server"'
;    CreateShortCut "$SMPROGRAMS\dradis\create meta-server database.lnk" "$0\bin\rake.bat" "db:migrate"
;    CreateShortCut "$INSTDIR\create meta-server database.lnk" "$0\bin\rake.bat" "db:migrate"
;  ${EndIf}
;SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\dradisframework.org.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  WriteIniStr "$INSTDIR\dradis web interface.url" "InternetShortcut" "URL" "https://127.0.0.1:3004"
SectionEnd

Section -Post
  SetOutPath "$INSTDIR"
  File "misc\readme.txt"
  File "misc\CHANGELOG.txt"
  File "misc\RELEASE_NOTES.txt"
  File "misc\LICENSE.txt"
  File "misc\LICENSE.logo.txt"
  File "misc\reset.bat"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  SetOutPath "$INSTDIR\server"
SectionEnd

Function .onInit
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller\MRI\1.9.2" Path
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    ; remove the option to select ruby to be installed
    SectionSetFlags ${SEC01} ${SF_RO}
  ${EndIf}
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  SectionSetFlags ${SEC03} $0
;  SectionSetFlags ${SEC04} $0
  SectionSetFlags ${SEC05} $0
  SectionSetFlags ${SEC06} $0
  SectionSetFlags ${SEC07} $0
  SectionSetFlags ${SEC08} $0

  ; don't install the Meta-Server by default
;  SectionSetFlags ${SEC09} 0
FunctionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Installs Ruby 1.9.2 runtime. The installer will download the Ruby One-Click installer and execute it. Alternatively you can install Ruby manually: http://rubyinstaller.org"
;  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Installs the wxruby gem. The gem requires ruby to be installed. Only used by the GUI."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "Install sqlite3 and the sqlite3 ruby gem. This requires ruby to be installed."
;  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "Installs the dradis client components (console and GUI)."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "Installs the dradis server component."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06} "Updates the internal rake library of Ruby. Dradis requires a newer version to the one shipped with the Ruby installer."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC07} "Installs the rack gem. The gem requires ruby to be installed."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC08} "Installs the RedCloth gem. The gem requires ruby to be installed."
;  !insertmacro MUI_DESCRIPTION_TEXT ${SEC09} "Installs the dradis Meta-Server component. This is useful if you want a dedicated server to manage multiple projects. It is not a required."
!insertmacro MUI_FUNCTION_DESCRIPTION_END


Function un.onUninstSuccess
  HideWindow
  ;MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Delete "$INSTDIR\dradisframework.org.url"
  Delete "$INSTDIR\dradis web interface.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\readme.txt"
  Delete "$INSTDIR\CHANGELOG.txt"
  Delete "$INSTDIR\RELEASE_NOTES.txt"
  Delete "$INSTDIR\LICENSE.txt"
  Delete "$INSTDIR\LICENSE.logo.txt"

  Delete "$SMPROGRAMS\dradis\Uninstall.lnk"
  Delete "$SMPROGRAMS\dradis\dradisframework.org.lnk"
  Delete "$SMPROGRAMS\dradis\dradis web interface.lnk"
  
  Delete "$SMPROGRAMS\dradis\start dradis server.lnk"
;  Delete "$SMPROGRAMS\dradis\start client (command line).lnk"
;  Delete "$SMPROGRAMS\dradis\start client (graphical).lnk"
  Delete "$SMPROGRAMS\dradis\reset server (deletes db and attachments).lnk"
;  Delete "$SMPROGRAMS\dradis\create meta-server database.lnk"
;  Delete "$SMPROGRAMS\dradis\start dradis meta-server.lnk"

  Delete "$INSTDIR\start dradis server.lnk"
;  Delete "$INSTDIR\start client (command line).lnk"
;  Delete "$INSTDIR\start client (graphical).lnk"
   ;Delete "$INSTDIR\reset server (deletes db and attachments).lnk"
   Delete "$INSTDIR\reset.bat"
;  Delete "$INSTDIR\create meta-server database.lnk"
;  Delete "$INSTDIR\start dradis meta-server.lnk"
  
  SetOutPath "$INSTDIR"
  Delete "$INSTDIR\schema.rb"
  ;RMDir /r "$INSTDIR\client"
  RMDir /r "$INSTDIR\server\log"
  RMDir "$INSTDIR\server\attachments"
  RMDir "$INSTDIR\server\backups"
  RMDir "$INSTDIR\server"
  ;!include "client_uninstall.nsh"
  !include "server_uninstall.nsh"
;  !include "meta-server_uninstall.nsh"
  Delete "$INSTDIR\server\config\first_login.txt"
  RMDir "$INSTDIR\server\config"
  RMDir "$INSTDIR\server\backups"
  RMDir /r "$INSTDIR\server\tmp"
  RMDir /r "$INSTDIR\dlls"
  RMDir /r "$INSTDIR\images"
  RMDir "$INSTDIR"
  RMDir "$SMPROGRAMS\dradis"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd
