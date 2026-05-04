# Execute setup script. Imports the correct module for the environment. 
. (Join-Path $PSScriptRoot "..\..\TestSetup.ps1")

Describe "Get-HRPCompany" {
    BeforeAll {
        $testResponse = @{
            CompanyID = 12345
            Email     = "test@company.com"
        }

        Mock Invoke-HRPAPI -ModuleName HRProPS {
            $testResponse
        }
    }
    
    Context "When the function is executed" {
        it "returns the expected response from the API" {
            $response = Get-HRPCompany

            $response | Should -BeOfType [PSCustomObject]
            $response.CompanyID | Should -Be 12345
            $response.Email | Should -Be "test@company.com"
        }
        
        It "returns nothing when API returns nothing" {
            Mock Invoke-HRPAPI -ModuleName HRProPS { $null }
            $response = Get-HRPCompany
            $response | Should -Be $null
        }
    }
}