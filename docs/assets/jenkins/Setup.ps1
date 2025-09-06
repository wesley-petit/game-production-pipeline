$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = "Stop"

New-Item -Path Temp -ItemType Directory -Force

# Install Winget tool : https://learn.microsoft.com/en-us/windows/package-manager/winget/
Write-Information "Downloading WinGet and its dependencies..."

# Install Winget tool : https://learn.microsoft.com/fr-fr/windows/package-manager/winget/#install-winget
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
winget --help

Write-Information "Done"

# Workload components : https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022#msbuild-tools
# Command line arguments : https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022
Write-Information "Downloading Visual Studio..."
winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools --add Microsoft.VisualStudio.Component.VC.14.36.17.6.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --wait --quiet" --silent
# winget install --id Microsoft.VisualStudio.2022.BuildTools --override "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools --add Microsoft.VisualStudio.Workload.UniversalBuildTools --add Microsoft.VisualStudio.Workload.NativeGame --wait --quiet" --silent
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
Write-Information "Installing JDK 17..."
winget install Microsoft.OpenJDK.17
Write-Information "Done"

# Install Jenkins
Write-Information "Downloading Jenkins..."
Invoke-WebRequest -Uri https://ftp.belnet.be/mirror/jenkins/windows-stable/latest -OutFile Temp\jenkins.msi
Write-Information "Done"

Write-Information "Installing Jenkins..."
Start-Process msiexec.exe -ArgumentList "/i .\Temp\jenkins.msi /quiet" -Wait
Write-Information "Done"

Remove-Item -Path ".\Temp" -Force