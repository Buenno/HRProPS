# Dot-source private functions
Get-ChildItem -Path (Join-Path $PSScriptRoot "private") -Recurse -Filter *.ps1 |
ForEach-Object {
    . $_.FullName
}

# Dot-source public functions
Get-ChildItem -Path (Join-Path $PSScriptRoot "public") -Recurse -Filter *.ps1 |
ForEach-Object {
    . $_.FullName
}

. (Join-Path $PSScriptRoot "private\Invoke-HRPAPI.ps1")

# Export only public functions
$public = Get-ChildItem -Path (Join-Path $PSScriptRoot "public") -Recurse -Filter *.ps1 | ForEach-Object {$_.BaseName}

Export-ModuleMember -Function $public