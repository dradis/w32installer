# dradis-setup.nsi
#
# Desc:
#   This is the code for the dradis windows installer
#
#   The majority of the code was generated with the HM NIS Script Wizard.
#   This is mostly code regarding the general framework of the installer
#   and the creation and copying of the installation files
#
# License:
#   See dradis.rb or LICENSE.txt for copyright and licensing information.

; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "dradis"
!define PRODUCT_VERSION "2.9"
!define PRODUCT_PUBLISHER "Dradis Framework Team"
!define PRODUCT_WEB_SITE "http://dradisframework.org"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!define RUBYINSTALLER_KEY "SOFTWARE\RubyInstaller\MRI\1.9.3"

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
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of Dradis version 2.9 \r\n \r\nClick next to continue."
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

!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "Initialise Dradis"
!define MUI_FINISHPAGE_RUN_FUNCTION "DradisReset"

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
OutFile "dradis-v2.9.0-setup.exe"
InstallDir "$APPDATA\dradis-2.9"
ShowInstDetails show
ShowUnInstDetails show

; place the creation of the start menu folder here because we need the folder in the other sections
Section
  SetOutPath "$INSTDIR\dlls"
  File "misc\dlls\README.dlls.txt"
  CreateDirectory "$INSTDIR\images"
  SetOutPath "$INSTDIR\images"
  File "images\dradis.ico"
  CreateDirectory "$SMPROGRAMS\Dradis Framework"
  CreateShortCut "$SMPROGRAMS\Dradis Framework\dradisframework.org.lnk" "$INSTDIR\dradisframework.org.url"
  CreateShortCut "$SMPROGRAMS\Dradis Framework\Dradis web interface.lnk" "$INSTDIR\dradis web interface.url" "$INSTDIR\images\dradis.ico"
  CreateShortCut "$SMPROGRAMS\Dradis Framework\Uninstall.lnk" "$INSTDIR\uninst.exe"lp
SectionEnd

; this section handles the installation of ruby
Section "Ruby 1.9.3" SEC01
  ClearErrors
  ; read the registry to check if there is not already a local installation of ruby
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ${If} $0 != ''
    ; ruby installed
    MessageBox MB_OK 'Ruby 1.9.3 is already installed on the system. The automated installation of Ruby will not proceed'
  ${Else}
    ; no ruby installer
    MessageBox MB_OK 'The Ruby 1.9.3 installer will now be downloaded and executed. Tick the *Add Ruby executable to your PATH*  checkbox.'
    ; download and install ruby
    NSISdl::download /NOIEPROXY "http://rubyforge.org/frs/download.php/75465/rubyinstaller-1.9.3-p0.exe" "rubyinstaller-1.9.3-p0.exe"
    Pop $R0
    ${If} $R0 == 'success'
      ; ruby download successful
      StrCpy $0 ''
      ; rum the one click installer
      ExecWait '"rubyinstaller-1.9.3-p0.exe"' $0
      ${If} $0 == ''
        ; execution of one click installer failed
        MessageBox MB_OK "Ruby 1.9.3 install failed. Please install Ruby manually: http://rubyinstaller.org/"
      ${EndIf}
      ; delete the ruby one click installer
      Delete "rubyinstaller-1.9.3-p0.exe"
    ${Else}
      Delete "rubyinstaller-1.9.3-p0.exe"
      ; ruby download not successfull
      MessageBox MB_OK "Ruby download failed. Please download and install Ruby manually: http://rubyinstaller.org/"
    ${EndIf}
  ${EndIf}
SectionEnd

Section "Dradis Framework Core" SEC02
  !include "server_install.nsh"
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 == ''
    MessageBox MB_OK "Ruby 1.9.3 is not installed. No shortcuts to start the Dradis Framework will not be created. Start Dradis from the commandline: cd $INSTDIR; server.bat"
  ${Else}
    # create shortcuts to start the dradis server from the start menu or install directory
    CreateShortCut "$SMPROGRAMS\Dradis Framework\start server.lnk" "$INSTDIR\server.bat" "" "$INSTDIR\images\dradis.ico"
    CreateShortCut "$SMPROGRAMS\Dradis Framework\reset (deletes database and attachments).lnk" "$INSTDIR\reset.bat"
  ${EndIf}
SectionEnd

Section "SQLite3 1.3.5" SEC03
  # check if ruby is installed and install the gem gem locally if so
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ${If} $0 != ''
    ; ruby installed copies the sqlite dll to the <ruby>\bin folder
    SetOutPath "$0\bin"
    File "misc\dlls\sqlite3.dll"
    ; sqlite dll is dependant on msvcrt dll
    File "misc\dlls\msvcrt.dll"
    SetOutPath "$INSTDIR\dlls"
    File "misc\gems\sqlite3-1.3.5-x86-mingw32.gem"

    StrCpy $1 ''
    ; install the wxruby locally
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri sqlite3-1.3.5-x86-mingw32.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the sqlite3-ruby (version 1.3.5) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby 1.9.3 is not installed. Please install ruby and then run the installer again or install the sqlite3-ruby (version 1.3.5) gem manually"
  ${EndIf}
  Delete "sqlite3-1.3.5-x86-mingw32.gem"
SectionEnd

Section "Bundler 1.0.21" SEC04
  SetOutPath "$INSTDIR\"
  File "misc\gems\bundler-1.0.21.gem"
  # check if ruby is installed and install the Bundler gem locally if so
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri bundler-1.0.21.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the bundler (version 1.0.21) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby 1.9.3 is not installed. Please install ruby and then run the installer again or install the bundler (version 1.0.21) gem manually"
  ${EndIf}
  Delete "bundler-1.0.21.gem"
SectionEnd

Section "Rake 0.9.2" SEC05
  SetOutPath "$INSTDIR\"
  File "misc\gems\rake-0.9.2.gem"
  # check if ruby is installed and install the Bundler gem locally if so
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ${If} $0 != ''
    ; ruby installed
    StrCpy $1 ''
    ; install the rake locally
    ExecWait '"$0\bin\gem.bat" install --no-rdoc --no-ri rake-0.9.2.gem' $1
    ${If} $1 == ''
      MessageBox MB_OK "Gem install failed. Please install the rake (version 0.9.2) gem manually"
    ${EndIf}
  ${Else}
    ; ruby not installed
    MessageBox MB_OK "Ruby is not installed. Please install ruby and then run the installer again or install the rake (version 0.9.2) gem manually"
  ${EndIf}
  Delete "rake-0.9.2.gem"
SectionEnd

; this section handles the installation of ruby
Section "Ruby DevKit" SEC06
  ClearErrors

  MessageBox MB_OK 'The Ruby DevKit installer will now be downloaded and executed.'
  ; download and install ruby DevKit
  NSISdl::download /NOIEPROXY "http://cloud.github.com/downloads/oneclick/rubyinstaller/DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe" "DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
  Pop $R0
  ${If} $R0 == 'success'
    ; ruby download successful
    StrCpy $0 ''
    ; rum the one click installer
    ExecWait '"DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe" -o"$INSTDIR\DevKit" -y' $0
    ${If} $0 == ''
      ; execution of DevKit failed
      MessageBox MB_OK "Ruby DevKit install failed. Please install the Ruby DevKit manually: http://rubyinstaller.org/"
    ${EndIf}
    ; delete the ruby DevKit installer
    Delete "DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
  ${Else}
    Delete "DevKit-tdm-32-4.5.2-20111229-1559-sfx.exe"
    ; ruby DevKit download not successfull
    MessageBox MB_OK "Ruby DevKit download failed. Please download and install the Ruby DevKit manually: http://rubyinstaller.org/"
  ${EndIf}
SectionEnd

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
  File "misc\server.bat"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  SetOutPath "$INSTDIR\server"
SectionEnd

Function .onInit
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ;readRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE65B110-8786-47EA-A4A0-05742F29C221}_is1" "Inno Setup: App Path"
  ${If} $0 != ''
    ; ruby installed
    ; remove the option to select ruby to be installed
    SectionSetFlags ${SEC01} ${SF_RO}
  ${EndIf}
  IntOp $0 ${SF_SELECTED} | ${SF_RO}
  SectionSetFlags ${SEC02} $0
  SectionSetFlags ${SEC03} $0
  SectionSetFlags ${SEC04} $0
  SectionSetFlags ${SEC05} $0
  SectionSetFlags ${SEC06} $0
FunctionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC01} "Installs Ruby 1.9.3 runtime. The installer will download the Ruby One-Click installer and execute it. Alternatively you can install Ruby manually: http://rubyinstaller.org"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC02} "Installs Dradis core components."
  ; TODO: Maybe we can rely on Bundler to install SQLite3?
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC03} "Install SQLite3 and the sqlite3-ruby gem. This library requires Ruby to be installed."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC04} "Installs the Bundler to manage Ruby dependencies. The library requires Ruby to be installed."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC05} "Installs the Rake gem (to run tasks, similar to GNU Make). The library requires Ruby to be installed."
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC06} "Ruby DevKit, required to compile some Ruby gems with native code"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Function DradisReset
  readRegStr $0 HKLM "${RUBYINSTALLER_KEY}" InstallLocation
  ${If} $0 != ''
    ; If Ruby is not in the PATH (e.g. we just installed it and the installer has the old PATH env variable)
    ; we need to ensure that the utils used by reset.bat (i.e. bundler, rake) are in the installer's PATH
    ReadEnvStr $R0 "PATH"
    StrCpy $R0 "$0\bin;$R0"
    System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r0'
    StrCpy $1 ''
    ExecWait '"$INSTDIR\reset.bat"' $1
  ${Else}
    MessageBox MB_OK "Ruby is not installed. After you install Ruby 1.9.3 use the Start menu link to reset the Dradis environment."
  ${EndIf}

FunctionEnd

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

  Delete "$SMPROGRAMS\Dradis Framework\Uninstall.lnk"
  Delete "$SMPROGRAMS\Dradis Framework\dradisframework.org.lnk"
  Delete "$SMPROGRAMS\Dradis Framework\Dradis web interface.lnk"
  Delete "$SMPROGRAMS\Dradis Framework\start server.lnk"
  Delete "$SMPROGRAMS\Dradis Framework\reset (deletes database and attachments).lnk"
  
  Delete "$INSTDIR\start dradis server.lnk"
  Delete "$INSTDIR\reset.bat"
  Delete "$INSTDIR\server.bat"

  SetOutPath "$INSTDIR"
  Delete "$INSTDIR\schema.rb"
  
  !include "server_uninstall.nsh"
  RMDir /r "$INSTDIR\server\tmp"
  RMDir /r "$INSTDIR\server\log"
  RMDir "$INSTDIR\server\attachments"
  RMDir "$INSTDIR\server\backups"
  ; Files that have been created as a result of running Dradis at least once:
  Delete "$INSTDIR\server\config\first_login.txt"
  Delete "$INSTDIR\server\config\database.yml"
  Delete "$INSTDIR\server\public\javascripts\all.js"
  Delete "$INSTDIR\server\public\stylesheets\all.css"
  RMDir "$INSTDIR\server\public\javascripts"
  RMDir "$INSTDIR\server\public\stylesheets"
  RMDir "$INSTDIR\server\public"

  RMDir "$INSTDIR\server\config"
  Delete "$INSTDIR\server\Gemfile.lock"
  RMDir "$INSTDIR\server"
  RMDir /r "$INSTDIR\dlls"
  RMDir /r "$INSTDIR\images"
  RMDir "$INSTDIR"
  RMDir "$SMPROGRAMS\Dradis Framework"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  SetAutoClose true
SectionEnd
