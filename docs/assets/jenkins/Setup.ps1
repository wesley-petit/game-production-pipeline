# Install Winget tool : https://learn.microsoft.com/en-us/windows/package-manager/winget/
Write-Information "Downloading WinGet and its dependencies..."

Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Temp\Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Temp\Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Temp\Microsoft.UI.Xaml.2.8.x64.appx
Add-AppxPackage Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Fix "No applicable app licenses error" : https://www.virtualizationhowto.com/2021/11/install-winget-in-windows-server-2022-no-applicable-app-licenses-error/
Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.8.1791/fb2830f66c95424aa35457b05e88998a_License1.xml -OutFile Temp\fb2830f66c95424aa35457b05e88998a_License1.xml
Add-AppxProvisionedPackage -Online -PackagePath Temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -LicensePath Temp\fb2830f66c95424aa35457b05e88998a_License1.xml -Verbose

Write-Information "Done"

# Workload components : https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022#msbuild-tools
# Command line arguments : https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
Write-Information "Downloading Visual Studio..."
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools --add Microsoft.VisualStudio.Component.VC.14.36.17.6.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --wait --quiet" --silent
Write-Information "Done"

# Install .NET Core
Write-Information "Downloading .NET..."
Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile Temp\dotnet-install.ps1
Write-Information "Done"

Write-Information "Installing .NET..."
.\Temp\dotnet-install.ps1 -Channel LTS
dotnet --version
Write-Information "Done"

# Install Java SDK to run Jenkins
Write-Information "Installing JDK 11..."
winget install Microsoft.OpenJDK.11
Write-Information "Done"

# Install Jenkins
Write-Information "Downloading Jenkins..."
Invoke-WebRequest -Uri https://ftp.belnet.be/mirror/jenkins/windows-stable/latest -OutFile Temp\jenkins.msi
Write-Information "Done"

Write-Information "Installing Jenkins..."
Start-Process msiexec.exe -ArgumentList "/i .\Temp\jenkins.msi /quiet" -Wait
Write-Information "Done"

Remove-Item -Path ".\Temp" -Force