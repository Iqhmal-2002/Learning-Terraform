# Run Powershell with administrator or else it would fail

# Check for policy
Get-ExecutionPolicy

# Set bypass if needed
Set-ExecutionPolicy Bypass -Scope Process

# chocolatey install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Check version
choco