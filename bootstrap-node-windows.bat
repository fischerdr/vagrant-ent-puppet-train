if not exist "C:\Windows\Temp\puppet.msi" (
  powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://downloads.puppetlabs.com/windows/puppet-x64-latest.msi', 'C:\Windows\Temp\puppet.msi')" <NUL
)

:: http://docs.puppetlabs.com/pe/latest/install_windows.html
msiexec /qn /i C:\Windows\Temp\puppet.msi /log C:\Windows\Temp\puppet.log

netsh advfirewall Firewall set rule group="Remote Desktop" new enable=yes
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

powershell -Command "$env:chocolateyVersion='0.10.8'; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex"


