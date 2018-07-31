FROM microsoft/iis
RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

RUN powershell Remove-WebSite -Name 'Default Web Site'
RUN powershell Import-Module WebAdministration;New-Item –Path IIS:\AppPools\NDFAsiaPool;New-Item -Path $env:systemdrive\inetpub\NDFADir -Type Directory;New-WebSite -Name NDFAsiaSite -Port 8080 -PhysicalPath "$env:systemdrive\inetpub\NDFADir" -ApplicationPool NDFAsiaPool -Force;

WORKDIR /inetpub/NDFADir
COPY content/Xp.NDFAsia .

EXPOSE 8080