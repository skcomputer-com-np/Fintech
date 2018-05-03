!include "MUI2.nsh"
!include "FileFunc.nsh"

Name "TheBeast"
OutFile "TheBeastInstall.exe"
AllowRootDirInstall true
ShowInstDetails show

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\beast.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\beast.ico"
Caption "The Beast App"
BrandingText "The Beast App"
RequestExecutionLevel admin

!define MUI_UI "${NSISDIR}\Contrib\UIs\modern.exe"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\newBeast.bmp"
!define MUI_HEADERIMAGE_RIGHT
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\beast-header.bmp"
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

Function CheckAndInstallDotNet
    ClearErrors
    ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" "Release"
    IfErrors NotDetected

    ${If} $0 >= 378389
        DetailPrint "Microsoft .NET Framework 4.5 is installed ($0)"
    ${Else}

    NotDetected:
        DetailPrint "Installing Microsoft .NET Framework 4.5"
        SetDetailsPrint none
        ExecWait '"$INSTDIR\PreReqSoft\vb_dot_net4.exe" /passive /norestart'
        ${If} $0 == 3010
        ${OrIf} $0 == 1641
            DetailPrint "Microsoft .NET Framework 4.5 installer requested reboot"
            SetRebootFlag true
        ${EndIf}
        SetDetailsPrint lastused
        DetailPrint "Microsoft .NET Framework 4.5 installer returned $0"
    ${EndIf}
FunctionEnd

;Splace screen
Function .onInit
  InitPluginsDir
  File "/oname=$PluginsDir\spltmp.bmp" "${NSISDIR}\Contrib\Graphics\Header\newBeast.bmp"
  advsplash::show 2000 600 400 -1 $PluginsDir\spltmp
  Pop $0
FunctionEnd

Section "BeastApp" BeastApp
        SectionIn RO

        SetOutPath $INSTDIR
        SetDetailsPrint both
        DetailPrint "Copying BeastApplication Folder"
        SetDetailsPrint none
        File /r C:\Users\admin\Desktop\Nsis\BeastApplication

        SetDetailsPrint both
        DetailPrint "Copying BeastClients Folder"
        SetDetailsPrint none
        File /r C:\Users\admin\Desktop\Nsis\BeastClients

        SetDetailsPrint both
        DetailPrint "Copying TheBeast folder"
        SetDetailsPrint none
        File /r C:\Users\admin\Desktop\Nsis\TheBeast

        SetDetailsPrint both
        DetailPrint "Copying prerequisite software"
        SetDetailsPrint none
        SetOutPath "$INSTDIR\PreReqSoft"
        File C:\Users\admin\Desktop\Nsis\PreReqSoft\*.exe
        File C:\Users\admin\Desktop\Nsis\PreReqSoft\*.msi
        File C:\Users\admin\Desktop\Nsis\PreReqSoft\*.reg
        SetDetailsPrint none

         ReadRegDword $R1 HKLM "SOFTWARE\Wow6432Node\Microsoft\VisualStudio\10.0\VC\Runtimes\x64" "Installed"
         ReadRegDword $R2 HKLM "SOFTWARE\ODBC\ODBCINST.INI\SQL Server Native Client 11.0" "SQLLevel"
/*
         SetDetailsPrint both
         DetailPrint "Detecting whether .NET install or not on your system"
         SetDetailsPrint none
         ;call CheckAndInstallDotNet
*/
         ${If} $R2 != "1"
               SetDetailsPrint both
               DetailPrint "Installing required SQL native client version..."
               SetDetailsPrint none
               ExecWait 'msiexec /i "$INSTDIR\PreReqSoft\sqlncli.msi" /passive IACCEPTSQLNCLILICENSETERMS=YES'
         ${EndIf}

         ${If} $R1 != "1"
               SetDetailsPrint both
               DetailPrint "Detecting VC++..."
               SetDetailsPrint none
               ExecWait '"$INSTDIR\PreReqSoft\vcredist.exe" /q'
         ${EndIf}

        ;install services
        SetOutPath "$INSTDIR\PreReqSoft"
        SetDetailsPrint both
        DetailPrint "Installing ApplicationController services.."
        SetDetailsPrint none
        ExecWait '"$INSTDIR\TheBeast\bin\ApplicationController.exe" -install'
        SetDetailsPrint both
        DetailPrint "Installing SessionServer services.."
        SetDetailsPrint none
        ExecWait '"$INSTDIR\TheBeast\bin\SessionServer.exe" -install'

        ;register entitlementservice as service
        SetDetailsPrint both
        DetailPrint "Installing EntitlementService services.."
        SetDetailsPrint none
        ExecWait '"$INSTDIR\TheBeast\bin\EntitlementService.exe" /service'


        ;Register Entitlementservice DLL
        SetDetailsPrint both
        DetailPrint "Registring entitlement service"
        SetDetailsPrint none
        SetOutPath "$WINDIR\SysWOW64"
        File C:\Users\admin\Desktop\Nsis\TheBeast\bin\EntitlementServiceps.dll
        RegDLL $WINDIR\SysWOW64\EntitlementServiceps.dll
        ExecWait '"%systemroot%\SysWOW64\regsvr32" /s "C:\Windows\SysWOW64\EntitlementServiceps.dll"'

        ;Copying d_agent file
        SetDetailsPrint both
        DetailPrint "Copying agent files"
        SetDetailsPrint none
        SetOutPath $PROGRAMFILES
        File C:\Users\admin\Desktop\Nsis\TheBeast\bin\d_agent.exe

        SetDetailsPrint both
        DetailPrint "Installing watchdog services.."
        SetDetailsPrint none
        ExecWait '"$INSTDIR\TheBeast\bin\watchdog.exe" -install'

        ;Register .reg file
        SetDetailsPrint both
        DetailPrint "Registring subkeys..."
        SetDetailsPrint none
        ;ExecWait '"regedit.exe" /I /S C:\Users\admin\Desktop\PreReqSoft\watchdog.reg'

        #Create Firewall Rule
        SetDetailsPrint both
        DetailPrint "Creating new firewall rules for beast application"
        SetDetailsPrint none
        Exec "netsh advfirewall firewall add rule name=BeastApp dir=in action=allow localport=8000-9500 protocol=tcp"

        SetDetailsPrint both
        DetailPrint "Creating new firewall rules for beast application"
        SetDetailsPrint none
        Exec "netsh advfirewall firewall add rule name=BeastApp{} dir=in action=allow localport=514 protocol=udp"

        SetDetailsPrint both
        DetailPrint "Writing uninstallation details"
        SetDetailsPrint none
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "DisplayName" "TheBeastApp"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "DisplayIcon" "${NSISDIR}\Contrib\Graphics\Icons\beast.ico"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "Publisher" "FintechGlobalCenter"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "HelpLink" "https://www.fintechglobal.center"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "DisplayVersion" "1.0"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "NoModify" "1"
        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "NoRepair" "1"

        WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeastApp" "UninstallString" '"$INSTDIR\UninstallTheBeast.exe"'
        WriteRegStr HKLM Software\ "Install_Dir" "$INSTDIR"
        WriteUninstaller "UninstallTheBeast.exe"

        ;Create shortcuts
        SetDetailsPrint both
        DetailPrint "Creating shortcut in start menu folder"
        SetDetailsPrint none
       CreateDirectory "$SMPROGRAMS\TheBeast"
       CreateShortcut "$SMPROGRAMS\TheBeast\Uninstall.lnk" "$INSTDIR\UninstallTheBeast.exe" "" "$INSTDIR\UninstallTheBeast.exe" 0
       CreateShortcut "$DESKTOP\The Beast App.lnk" "$INSTDIR"

SectionEnd

LangString DESC_BeastApp ${LANG_ENGLISH} "It will install BeastApp with some auto configuation for it."
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${BeastApp} $(DESC_BeastApp)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"

        SetDetailsPrint both
        DetailPrint "Uninstalling beast files and configurations"
        SetDetailsPrint none
        DeleteRegKey HKLM Software\TheBeast
        DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\TheBeast"
        Delete $PROGRAMFILES\d_agent.exe
        Delete "$INSTDIR\UninstallTheBeast.exe"
        Delete "$DESKTOP\The Beast App.lnk"

        RMDir /r "$INSTDIR\PreReqSoft"
        RMDir /r  "$INSTDIR\BeastApplication"
        RMDir /r  "$INSTDIR\BeastClients"
        RMDir /r  "$INSTDIR\TheBeast"
        RMDir /r "$SMPROGRAMS\TheBeast"

        Exec '"sc" stop ApplicationController'
        Exec '"sc" stop SessionServer'
        Exec '"sc" stop watchdog'
        Exec '"sc" stop EntitlementService'

        Exec "SC DELETE watchdog"
        Exec "SC DELETE EntitlementService"
        Exec "SC DELETE ApplicationController"
        Exec "SC DELETE SessionServer"

        Exec "netsh advfirewall firewall delete rule BeastApp"
        Exec "netsh advfirewall firewall delete rule BeastApp{}"
        ExecWait '"%systemroot%\SysWOW64\regsvr32" /s /u "C:\Windows\SysWOW64\EntitlementServiceps.dll"'
        UnRegDLL $WINDIR\SysWOW64\EntitlementServiceps.dll
        Delete $WINDIR\SysWOW64\EntitlementServiceps.dll

SectionEnd