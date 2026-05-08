$moduleName = "HRProPS"
$moduleVersion = $env:MODULE_VERSION
$moduleSrcPath = Join-Path $PSScriptRoot ".\src\HRProPS"
$buildOutput = Join-Path $PSScriptRoot "build\$moduleName"
$releaseOutput = Join-Path $PSScriptRoot "build\release\"
$outputDirs = @($buildOutput, $releaseOutput)

if (-not $moduleVersion) {
    $moduleVersion = "0.0.0"
}

task Clean {
    foreach ($dir in $outputDirs) {
        if (Test-Path $dir) {
            Remove-Item $dir -Recurse -Force
        }
    }
}

task ScriptModule Clean, {
    if (-not (Test-Path -Path $buildOutput)) {
            New-Item -Path $buildOutput -ItemType Directory -Force | Out-Null
    }

    $public = Get-ChildItem -Path (Join-Path $moduleSrcPath "public") -Recurse -Filter *.ps1
    $private = Get-ChildItem -Path (Join-Path $moduleSrcPath "private") -Recurse -Filter *.ps1

    $content = @()

    foreach ($file in $public) {
        $content += Get-Content $file -Raw
    }

    foreach ($file in $private) {
        $content += Get-Content $file -Raw
    }

    $exports = $public.BaseName
    $content += "Export-ModuleMember -Function $($exports -join ', ')"

    ($content -join "`n`n") | Set-Content (Join-Path $buildOutput "$moduleName.psm1") -NoNewline
}

task Manifest ScriptModule, {
    $functions = (Get-ChildItem -Path (Join-Path $moduleSrcPath "public") -Recurse -Filter *.ps1).BaseName

    New-ModuleManifest `
        -Path (Join-Path $buildOutput "$moduleName.psd1") `
        -RootModule "$moduleName.psm1" `
        -ModuleVersion $moduleVersion `
        -FunctionsToExport $functions `
        -Author Buenno `
        -CompanyName Buenno `
        -Description "A Powershell module for interacting with HR Professional" `
        -RequiredModules @('Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore')
}

task TestManifest Manifest, {
    Test-ModuleManifest -Path (Join-Path $buildOutput "$moduleName.psd1") | Out-Null
}

task Test TestManifest, {
    Invoke-Pester -Path (Join-Path $PSScriptRoot "tests") -Output Detailed
}

task Package @{
    Inputs = {
        Get-ChildItem -Path $buildOutput -Recurse -File
    }
    Outputs = {
        Join-Path $releaseOutput ($moduleName + '.zip')
    }
    Jobs = @(
        'Manifest' 
        {
        if (-not (Test-Path -Path $releaseOutput)) {
            New-Item -Path $releaseOutput -ItemType Directory -Force | Out-Null
        }

        $zipPath = Join-Path $releaseOutput ($moduleName + '.zip')

        Compress-Archive `
            -Path $buildOutput `
            -DestinationPath $zipPath `
            -Force
        }
    )
}

task Build Manifest

task . Build