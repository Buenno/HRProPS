$moduleName = "HRProPS"
$root = $PSScriptRoot
$output = Join-Path $root "build\$moduleName"
$moduleSrcPath = Join-Path $root ".\src\HRProPS"

task Clean {
    if (Test-Path -Path $output) {
        Remove-Item -Path $output -Recurse -Force
    }
}

task Stage {
    New-Item -Path $output -ItemType Directory -Force | Out-Null
}

task ScriptModule Stage, {
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

    ($content -join "`n`n") | Set-Content (Join-PAth $output "$moduleName.psm1") -NoNewline
}

task Manifest ScriptModule, {
    $functions = (Get-ChildItem -Path (Join-Path $moduleSrcPath "public") -Recurse -Filter *.ps1).BaseName

    New-ModuleManifest `
        -Path "$output\$moduleName.psd1" `
        -RootModule "$moduleName.psm1" `
        -FunctionsToExport $functions `
        -Author Buenno `
        -CompanyName Buenno `
        -Description "A Powershell module for interacting with HR Professional" `
        -RequiredModules @('Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.SecretStore')
}

task TestManifest Manifest, {
    Test-ModuleManifest -Path (Join-Path $output "$moduleName.psd1") | Out-Null
}

task Test TestManifest, {
    Invoke-Pester -Path (Join-Path $root "tests") -Output Detailed
}

#task Package Build `
#    -Inputs (Get-ChildItem $output -Recurse) `
#    -Outputs "$output/$moduleName.zip" {
#    Compress-Archive -Path $output `
#        -DestinationPath (Join-Path $root "build\$moduleName.zip") `
#        -Force
#}

task Build Clean, Test

task . Build