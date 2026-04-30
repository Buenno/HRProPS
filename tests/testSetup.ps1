$isCI = $env:GITHUB_ACTIONS -eq 'true'

Remove-Module -Name HRProPS -Force -ErrorAction SilentlyContinue

if ($isCI) {
    # Import the built module .
    Import-Module (Join-Path $env:GITHUB_WORKSPACE "build\HRProPS\HRProPS.psd1") -Force
}
else {
    # Import the source module.
    $testModulePath = Resolve-Path (Join-Path $PSScriptRoot "..\src\HRProPS\HRProPS.psm1")

    Import-Module $testModulePath -Force
}