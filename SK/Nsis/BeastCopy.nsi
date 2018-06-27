!include "MUI2.nsh"
!include "FileFunc.nsh"

Name "TheBeastDesktop"
InstallDir $LOCALAPPDATA\TheBeast\TheBeastAppsDesktop\ws
OutFile "TheBeastDeskttopInstall.exe"
AllowRootDirInstall true
ShowInstDetails show

;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\beast.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\beast.ico"
Caption "The Beast Desktop"
BrandingText "The Beast App"
RequestExecutionLevel admin

!define MUI_UI "${NSISDIR}\Contrib\UIs\modern.exe"
!define MUI_HEADERIMAGE
;!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\newBeast.bmp"
!define MUI_HEADERIMAGE_RIGHT
;!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\beast-header.bmp"
!define MUI_BGCOLOR "c4c5c4 "
;!define MUI_INSTFILESPAGE_COLORS "c4c5c4 dddddd"
!define MUI_LICENSEPAGE_BGCOLOR "/grey"
!define MUI_ABORTWARNING


!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

;Splace screen
;Function .onInit
;  InitPluginsDir
;  File "/oname=$PluginsDir\spltmp.bmp" "${NSISDIR}\Contrib\Graphics\Header\newBeast.bmp"
;  advsplash::show 2000 600 400 -1 $PluginsDir\spltmp
;  Pop $0
;FunctionEnd
Function CopyFiles
        File F:\BeastCopy\TheBeastAppsDesktop.exe
        File F:\BeastCopy\*.reg
        File F:\BeastCopy\cl32.dll
FunctionEnd

Function checkFile
         IfFileExists $INSTDIR\TheBeastAppsDesktop.exe deleteOld copyNew
          deleteOld:
          Delete "$INSTDIR\TheBeastAppsDesktop.exe"
          DeleteRegKey HKCU "SOFTWARE\TheBEAST"
          Call CopyFiles
          Goto next
          
          copyNew:
          Call CopyFiles
          Goto next
        next:
FunctionEnd

Section "BeastDesktop" BeastApp
        SectionIn RO
        SetOutPath $INSTDIR
        SetDetailsPrint both
        DetailPrint "Copying necessary files"
        SetDetailsPrint none
        
        call checkFile ;Check and Copying files
        ExecWait '"regedit.exe" /I /S $INSTDIR\Desktopreg.reg'
        ;Exec 'mklink "$DESKTOP\TheBeastAppsDesktop.exe $INSTDIR\TheBeastAppsDesktop.exe"' ;Symbolic link create

        SetDetailsPrint both
        DetailPrint "Writing uninstallation details"
        SetDetailsPrint none
        WriteRegStr HKCU "Software\SOFTWARE\TheBEAST\TheBeastAppsDesktop\Uninstall\TheBeastDesktop" "DisplayName" "TheBeastDesktop"
        ;WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastDesktop" "DisplayIcon" "${NSISDIR}\Contrib\Graphics\Icons\beast.ico"
        WriteRegStr HKCU "Software\SOFTWARE\TheBEAST\TheBeastAppsDesktop\Uninstall\TheBeastDesktop" "Publisher" "FintechGlobalCenter"
        WriteRegStr HKCU "Software\SOFTWARE\TheBEAST\TheBeastAppsDesktop\Uninstall\TheBeastDesktop" "HelpLink" "https://www.fintechglobal.center"
        WriteRegStr HKCU "Software\SOFTWARE\TheBEAST\TheBeastAppsDesktop\Uninstall\TheBeastDesktop" "DisplayVersion" "1.0"
        WriteRegStr HKCU "Software\SOFTWARE\TheBEAST\TheBeastAppsDesktop\Uninstall\TheBeastDesktop" "NoModify" "1"
        WriteRegStr HKCU "Software\SOFTWARE\TheBEAST\TheBeastAppsDesktop\Uninstall\TheBeastDesktop" "NoRepair" "1"

        WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastDesktop" "UninstallString" '"$INSTDIR\UninstallTheBeastDesktop.exe"'
        WriteRegStr HKCU Software\ "Install_Dir" "$INSTDIR"
        WriteUninstaller "UninstallTheBeastDesktop.exe"

        CreateShortcut "$DESKTOP\TheBeastDesktop.lnk" "$INSTDIR\TheBeastAppsDesktop.exe"
        
SectionEnd

Section "Uninstall"
        SetDetailsPrint both
        DetailPrint "Uninstalling beast files and configurations"
        SetDetailsPrint none
        DeleteRegKey HKCU Software\TheBeastDesktop
        DeleteRegKey HKCU "SOFTWARE\TheBEAST"
        Delete "$INSTDIR\UninstallTheBeastDesktop.exe"
        Delete "$INSTDIR\TheBeastAppsDesktop.exe"
        Delete "$INSTDIR\cl32.dll"
        Delete "$INSTDIR\Desktopreg.reg"
        Delete "$DESKTOP\TheBeastDesktop.lnk"
SectionEnd