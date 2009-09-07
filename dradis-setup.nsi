# dradis-v2_0-setup.nsi
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
!define PRODUCT_VERSION "2.3"
!define PRODUCT_PUBLISHER "dradis software"
!define PRODUCT_WEB_SITE "http://dradis.sourceforge.net"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

; MUI 1.67 compatible ------
!include "MUI.nsh"

; inlude logic lib for more readable code logic
!include LogicLib.nsh

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "images\dradis.ico"
;!define MUI_ICON "C:\Program Files\NSIS\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
# this is the text to be displayed at the start of installation
!define MUI_WELCOMEPAGE_TEXT "This wizard wil guide you through the installation of dradis version 2.3 \r\n \r\nClick next to continue."
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "extra_docs\LICENSE"
; Components page
!insertmacro MUI_PAGE_COMPONENTS
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
Section
SetOutPath "$INSTDIR\server"
readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
${If} $0 != ''
  !define MUI_FINISHPAGE_RUN_TEXT "Initialise the database"
  !define MUI_FINISHPAGE_RUN "$0\bin\rake.bat"
  !define MUI_FINISHPAGE_RUN_PARAMETERS "-f $\"$INSTDIR\server\Rakefile$\" db:migrate"
${EndIf}
SectionEnd
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\readme.txt"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
# this is the text to be displayed to the user at the end of uninstallation
!define MUI_FINISHPAGE_TEXT "The following components was successfully removed: \r\n - dradis client\r\n - dradis server\r\n \r\nThe the dradis server folder was not removed from the install location.\r\nIt contains the database files that was created since installation.\r\nPlease remove manually.\r\nIf you want to remove ruby, wxruby or sqlite3 please do so manually.\r\n - ruby: uninstall option in the ruby start menu folder\r\n - wxruby: execute 'gem uninstall wxruby' from the command line\r\n - sqlite3: execute 'gem uninstall sqlite3-ruby' from the command line\r\n"
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "English"

; MUI end ------

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "dradis-v2.3.0-setup.exe"
InstallDir "$APPDATA\dradis"
ShowInstDetails show
ShowUnInstDetails show

; place the creation of the start menu folder here because we need the folder in the other sections
Section
  CreateDirectory "$SMPROGRAMS\dradis"
  SetOutPath "$INSTDIR\dlls"
  File "extra_docs\README.dlls.txt"
  CreateDirectory "$SMPROGRAMS\dradis"
  CreateShortCut "$SMPROGRAMS\dradis\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\dradis\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

; this section handles the installation of ruby
Section "ruby" SEC01
  ClearErrors
  ; read the registry to check if there is not already a local installation of ruby
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 != ''
    ; ruby installed
    MessageBox MB_OK 'Ruby is already installed on the system. The automated installation of Ruby will not proceed'
  ${Else}
    ; no ruby installer
    MessageBox MB_OK 'The ruby installer will now be downloaded and executed. This might take a few moments.'
    ; download and install ruby
    NSISdl::download /NOIEPROXY "http://rubyforge.org/frs/download.php/29263/ruby186-26.exe" "ruby186-26.exe"
    Pop $R0
    ${If} $R0 == 'success'
      ; ruby download successful
      StrCpy $0 ''
      ; rum the one click installer
      ExecWait '"ruby186-26.exe"' $0
      ${If} $0 == ''
        ; execution of one click installer failed
        MessageBox MB_OK "Ruby install failed. Please install Ruby manually"
      ${EndIf}
      ; delete the ruby one click installer
      Delete "ruby186-26.exe"
    ${Else}
      Delete "ruby186-26.exe"
      ; ruby download not successfull
      MessageBox MB_OK "Ruby download failed. Please download and install Ruby manually"
    ${EndIf}
  ${EndIf}
SectionEnd

Section "wxruby" SEC02
  SetOutPath "$WINDIR\system32"
  SetOverwrite off
  ; dependant dll's
  File "extra_docs\msvcr71.dll"
  File "extra_docs\MSVCP71.DLL"
  SetOVerwrite ifnewer
  
  SetOutPath "$INSTDIR\dlls"
  File "extra_docs\msvcr71.dll"
  File "extra_docs\MSVCP71.DLL"
  SetOutPath "$INSTDIR\client"
  File "extra_docs\wxruby-1.9.9-x86-mswin32-60.gem"
  # check if ruby is installed and install the wxruby gem locally if so
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the wxruby locally
    ExecWait '"$0\bin\gem.bat" install wxruby-1.9.9-x86-mswin32-60.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the wxruby (version 1.9.9) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the wxruby (version 1.9.9) gem manually"
  ${EndIf}
  Delete "wxruby-1.9.9-x86-mswin32-60.gem"
SectionEnd

Section "sqlite3" SEC03
  ; copies the sqlite dll to the system 32 folder
  SetOutPath "$WINDIR\system32"
  File "extra_docs\sqlite3.dll"
  SetOverwrite off
  ; sqlite dll is dependant on msvcrt dll
  File "extra_docs\msvcrt.dll"
  SetOVerwrite ifnewer
  SetOutPath "$INSTDIR\dlls"
  File "extra_docs\sqlite3.dll"
  File "extra_docs\msvcrt.dll"
  File "extra_docs\sqlite3-ruby-1.2.3-mswin32.gem"
  # check if ruby is installed and install the gem gem locally if so
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the wxruby locally
    ExecWait '"$0\bin\gem.bat" install sqlite3-ruby-1.2.3-mswin32.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the sqlite3-ruby (version 1.2.3) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the sqlite3-ruby (version 1.2.3) gem manually"
  ${EndIf}
  Delete "sqlite3-ruby-1.2.3-mswin32.gem"
SectionEnd

Section "client" SEC04
  !include "client_install.nsh"
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 == ''
    MessageBox MB_OK "Ruby is not installed. A shortcut to start the dradis client will not be created. Start the client from the commandline: ruby $INSTDIR\client\dradis.rb. Use -g as a commandline argument for the graphical user interface"
  ${Else}
    SetOutPath "$INSTDIR\client"
    # create a shortcuts to start the dradis client from the start menu
    CreateShortCut "$SMPROGRAMS\dradis\start client (command line).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb"'
    CreateShortCut "$SMPROGRAMS\dradis\start client (graphical).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb" -g'
    # create a shortcuts to start the dradis client in the install directory
    CreateShortCut "$INSTDIR\start client (command line).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb"'
    CreateShortCut "$INSTDIR\start client (graphical).lnk" "$0\bin\ruby.exe" '"$INSTDIR\client\dradis.rb" -g'
  ${EndIf}
SectionEnd

Section "server" SEC05
  !include "server_install.nsh"
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 == ''
    MessageBox MB_OK "Ruby is not installed. A shortcut to start the dradis client will not be created. Start the client from the commandline: ruby $INSTDIR\client\dradis.rb. Use -g as a commandline argument for the graphical user interface"
  ${Else}
    SetOutPath "$INSTDIR\server"
    # create shortcuts to start the dradis server from the start menu or install directory
    CreateShortCut "$SMPROGRAMS\dradis\start dradis server.lnk" "$0\bin\ruby.exe" '"$INSTDIR\server\script\server"'
    CreateShortCut "$INSTDIR\start dradis server.lnk"  "$0\bin\ruby.exe" '"$INSTDIR\server\script\server"'
    CreateShortCut "$SMPROGRAMS\dradis\reset server (deletes db and attachments).lnk" "$0\bin\rake.bat" "dradis:reset"
    CreateShortCut "$INSTDIR\reset server (deletes db and attachments).lnk" "$0\bin\rake.bat" "dradis:reset"
  ${EndIf}
SectionEnd

Section "Meta-Server" SEC06
  !include "meta-server_install.nsh"
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 == ''
    MessageBox MB_OK "Ruby is not installed. A shortcut to start the dradis client will not be created. Start the client from the commandline: ruby $INSTDIR\client\dradis.rb. Use -g as a commandline argument for the graphical user interface"
  ${Else}
    SetOutPath "$INSTDIR\meta-server"
    # create shortcuts to start the dradis meta-server from the start menu or install directory
    CreateShortCut "$SMPROGRAMS\dradis\start dradis meta-server.lnk" "$0\bin\ruby.exe" '"$INSTDIR\meta-server\script\server"'
    CreateShortCut "$INSTDIR\start dradis meta-server.lnk"  "$0\bin\ruby.exe" '"$INSTDIR\meta-server\script\server"'
    CreateShortCut "$SMPROGRAMS\dradis\create meta-server database.lnk" "$0\bin\rake.bat" "db:migrate"
    CreateShortCut "$INSTDIR\create meta-server database.lnk" "$0\bin\rake.bat" "db:migrate"
  ${EndIf}
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
SectionEnd

Section -Post
  SetOutPath "$INSTDIR"
  File "extra_docs\readme.txt"
  File "extra_docs\CHANGELOG"
  File "extra_docs\RELEASE_NOTES"
  File "extra_docs\LICENSE"
  File "extra_docs\LICENSE.logo"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  SetOutPath "$INSTDIR\server"
SectionEnd

Function .onInit
  readRegStr $0 HKLM "SOFTWARE\RubyInstaller" Path
  ${If} $0 != ''
    ; ruby installed
    ; remove the option to select ruby to be installed
    SectionSetFlags ${SEC01} ${SF_RO}
  ${EndIf}
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  SectionSetFlags ${SEC03} $0
  SectionSetFlags ${SEC04} $0
  SectionSetFlags ${SEC05} $0

  ; don't install the Meta-Server by default
  SectionSetFlags ${SEC06} 0
FunctionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Installs ruby. The installer will download the ruby one click installer and execute. Alternatively you can install ruby manually."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Installs the wxruby gem. The gem requires ruby to be installed. Only used by the GUI."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "Install sqlite3 and the sqlite3 ruby gem. This requires ruby to be installed."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "Installs the dradis client components (console and GUI)."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "Installs the dradis server component."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06} "Installs the dradis Meta-Server component. This is useful if you want a dedicated server to manage multiple projects. It is not a required."
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
  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\readme.txt"
  Delete "$INSTDIR\CHANGELOG"
  Delete "$INSTDIR\RELEASE_NOTES"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\LICENSE.logo"

  Delete "$SMPROGRAMS\dradis\Uninstall.lnk"
  Delete "$SMPROGRAMS\dradis\Website.lnk"
  
  Delete "$SMPROGRAMS\dradis\start dradis server.lnk"
  Delete "$SMPROGRAMS\dradis\start client (command line).lnk"
  Delete "$SMPROGRAMS\dradis\start client (graphical).lnk"
  Delete "$SMPROGRAMS\dradis\reset server (deletes db and attachments).lnk"
  Delete "$SMPROGRAMS\dradis\create meta-server database.lnk"
  Delete "$SMPROGRAMS\dradis\start dradis meta-server.lnk"
    
  Delete "$INSTDIR\start dradis server.lnk"
  Delete "$INSTDIR\start client (command line).lnk"
  Delete "$INSTDIR\start client (graphical).lnk"
  Delete "$INSTDIR\reset server (deletes db and attachments).lnk"
  Delete "$INSTDIR\create meta-server database.lnk"
  Delete "$INSTDIR\start dradis meta-server.lnk"
  
  SetOutPath "$INSTDIR"
  File "server\db\*"
  Delete "$INSTDIR\schema.rb"
  ;RMDir /r "$INSTDIR\client"
  ;RMDir /r "$INSTDIR\server"
  !include "client_uninstall.nsh"
  !include "server_uninstall.nsh"
  !include "meta-server_uninstall.nsh"
  RMDir /r "$INSTDIR\server\tmp"
  RMDir /r "$INSTDIR\dlls"
  RMDir "$SMPROGRAMS\dradis"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd