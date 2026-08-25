# Run Powershell with administrator or else it would fail

# Check for policy
Get-ExecutionPolicy

# Set bypass if needed
Set-ExecutionPolicy Bypass -Scope Process

# Check version
choco