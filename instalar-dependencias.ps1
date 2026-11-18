$ErrorActionPreference = "Stop"

function Test-InstalledApplication {
  param(
    [string]$DisplayNamePattern,
    [string[]]$Commands,
    [string[]]$Paths
  )

  foreach ($commandName in $Commands) {
    if (Get-Command -Name $commandName -ErrorAction SilentlyContinue) {
      return $true
    }
  }

  foreach ($path in $Paths) {
    if (Test-Path -LiteralPath $path) {
      return $true
    }
  }

  $uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
  )

  foreach ($key in $uninstallKeys) {
    $application = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue |
      Where-Object { $_.DisplayName -match $DisplayNamePattern } |
      Select-Object -First 1

    if ($application) {
      return $true
    }
  }

  return $false
}

function Install-IfMissing {
  param(
    [string]$Name,
    [string]$PackageId,
    [string]$DisplayNamePattern,
    [string[]]$Commands,
    [string[]]$Paths
  )

  if (Test-InstalledApplication -DisplayNamePattern $DisplayNamePattern -Commands $Commands -Paths $Paths) {
    Write-Host "$Name ja esta instalado; nenhuma instalacao sera feita."
    return
  }

  Write-Host "Instalando $Name pelo Winget..."
  & $script:Winget.Source install --id $PackageId --exact --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    throw "A instalacao de $Name falhou (codigo $LASTEXITCODE)."
  }
}

$script:Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if (-not $script:Winget) {
  $script:Winget = Get-Command winget -ErrorAction SilentlyContinue
}

if (-not $script:Winget) {
  throw "O Winget nao foi encontrado. Instale ou atualize o App Installer pela Microsoft Store e tente novamente."
}

$programFilesX86 = ${env:ProgramFiles(x86)}

Install-IfMissing `
  -Name "Oracle VirtualBox" `
  -PackageId "Oracle.VirtualBox" `
  -DisplayNamePattern "^(Oracle VM )?VirtualBox|^Oracle VirtualBox" `
  -Commands @("VBoxManage") `
  -Paths @(
    (Join-Path $env:ProgramFiles "Oracle\VirtualBox\VBoxManage.exe"),
    (Join-Path $programFilesX86 "Oracle\VirtualBox\VBoxManage.exe")
  )

Install-IfMissing `
  -Name "Vagrant" `
  -PackageId "Hashicorp.Vagrant" `
  -DisplayNamePattern "^(HashiCorp )?Vagrant(\s|$)" `
  -Commands @("vagrant") `
  -Paths @(
    (Join-Path $env:ProgramFiles "Vagrant\bin\vagrant.exe"),
    (Join-Path $env:ProgramFiles "HashiCorp\Vagrant\bin\vagrant.exe"),
    (Join-Path $env:SystemDrive "HashiCorp\Vagrant\bin\vagrant.exe"),
    (Join-Path $programFilesX86 "Vagrant\bin\vagrant.exe")
  )

$workbenchInstalled = Test-InstalledApplication `
  -DisplayNamePattern "^MySQL Workbench(\s|$)" `
  -Commands @("MySQLWorkbench") `
  -Paths @(
    (Join-Path $env:ProgramFiles "MySQL\MySQL Workbench 8.0 CE\MySQLWorkbench.exe"),
    (Join-Path $programFilesX86 "MySQL\MySQL Workbench 8.0 CE\MySQLWorkbench.exe")
  )

if ($workbenchInstalled) {
  Write-Host "MySQL Workbench ja esta instalado."
}
else {
  $installWorkbench = Read-Host "Deseja instalar o MySQL Workbench? (s/N)"
  if ($installWorkbench -match "^(s|sim|y|yes)$") {
    Install-IfMissing `
      -Name "MySQL Workbench" `
      -PackageId "Oracle.MySQLWorkbench" `
      -DisplayNamePattern "^MySQL Workbench(\s|$)" `
      -Commands @("MySQLWorkbench") `
      -Paths @(
        (Join-Path $env:ProgramFiles "MySQL\MySQL Workbench 8.0 CE\MySQLWorkbench.exe"),
        (Join-Path $programFilesX86 "MySQL\MySQL Workbench 8.0 CE\MySQLWorkbench.exe")
      )
  }
  else {
    Write-Host "MySQL Workbench ignorado; ele e opcional."
  }
}

Write-Host "Verificacao concluida. Talvez seja necessario abrir um novo terminal para atualizar o PATH."
