# Execute setup script. Imports the correct module for the environment. 
. (Join-Path $PSScriptRoot "..\..\TestSetup.ps1")

Describe "Get-HRPCredentials" {
    BeforeEach {
        Mock Get-Module -ModuleName HRProPS {$true} -ParameterFilter { $Name -eq "Microsoft.PowerShell.SecretManagement" }
        Mock Get-Module -ModuleName HRProPS {$true} -ParameterFilter { $Name -eq "Microsoft.PowerShell.SecretStore" }

        Mock Get-SecretVault -ModuleName HRProPS {$null}
        Mock Get-SecretInfo -ModuleName HRProPS {$null}
        Mock Get-Secret -ModuleName HRProPS { 
            [PSCredential]::new("testuser", (ConvertTo-SecureString "Password123" -AsPlainText -Force))
        }
    }

    It "throws error if HRProPS vault does not exist" {
        { Get-HRPCredentials } | Should -Throw "The SecretStore vault `"HRProPS`" does not exist. Run Set-HRPCredentials first."
        Assert-MockCalled Get-SecretVault -ModuleName HRProPS -Times 1 -Exactly 
        Assert-MockCalled Get-SecretInfo -ModuleName HRProPS -Times 0 -Exactly
        Assert-MockCalled Get-Secret -ModuleName HRProPS -Times 0 -Exactly
    }

    It "throws error if credentials are not found in HRProPS vault" {
        Mock Get-SecretVault -ModuleName HRProPS {@{Name = "HRProPS"}}

        { Get-HRPCredentials } | Should -Throw "No HR Pro credentials were found in vault `"HRProPS`". Run Set-HRPCredentials first."
        Assert-MockCalled Get-SecretVault -ModuleName HRProPS -Times 1 -Exactly
        Assert-MockCalled Get-SecretInfo -ModuleName HRProPS -Times 1 -Exactly
        Assert-MockCalled Get-Secret -ModuleName HRProPS -Times 0 -Exactly
    }

    It "returns credentials when the vault and secret exist" {
        Mock Get-SecretVault -ModuleName HRProPS {@{Name = "HRProPS"}}
        Mock Get-SecretInfo -ModuleName HRProPS {@{Name = "HRProPS"}}

        $cred = Get-HRPCredentials
        $cred.Username | Should -Be "testuser"
        $cred.Password | Should -BeOfType [SecureString]
        $cred | Should -BeOfType [PSCredential]


        Assert-MockCalled Get-SecretVault -ModuleName HRProPS -Times 1 -Exactly
        Assert-MockCalled Get-SecretInfo -ModuleName HRProPS -Times 1 -Exactly
        Assert-MockCalled Get-Secret -ModuleName HRProPS -Times 1 -Exactly
    }

    It "throws if SecretManagement is not installed" {
        Mock Get-Module -ModuleName HRProPS {$false} -ParameterFilter {
            $Name -eq "Microsoft.PowerShell.SecretManagement"
        }

        { Get-HRPCredentials } | Should -Throw "Microsoft.PowerShell.SecretManagement module is not installed."
    }

    It "throws if SecretStore is not installed" {
        Mock Get-Module -ModuleName HRProPS {$false} -ParameterFilter { 
            $Name -eq "Microsoft.PowerShell.SecretStore"
        }

        { Get-HRPCredentials } | Should -Throw "Microsoft.PowerShell.SecretStore module is not installed."
    }    
}