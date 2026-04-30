# Execute setup script. Imports the correct module for the environment. 
. (Join-Path $PSScriptRoot "..\..\TestSetup.ps1")

Describe "Set-HRPCredentials" {
    BeforeEach {
        $cred = [PSCredential]::new("testuser", (ConvertTo-SecureString "Password123" -AsPlainText -Force))

        Mock Get-Module -ModuleName HRProPS {$true} -ParameterFilter {$Name -eq "Microsoft.PowerShell.SecretManagement"}
        Mock Get-Module -ModuleName HRProPS {$true} -ParameterFilter {$Name -eq "Microsoft.PowerShell.SecretStore"}

        Mock Get-SecretVault -ModuleName HRProPS {$null}
        Mock Register-SecretVault -ModuleName HRProPS {@{Name = "HRProPS"}}
        Mock Set-Secret -ModuleName HRProPS {$true}
        Mock Get-Credential -ModuleName HRProPS { 
            $cred
        }
    }

    It "creates the vault if it does not exist" {
        Set-HRPCredentials | Out-Null

        Assert-MockCalled Register-SecretVault -ModuleName HRProPS -Times 1 -Exactly
        Assert-MockCalled Set-Secret -ModuleName HRProPS -Times 1 -Exactly
    }

    It "does not attempt to create the vault if it exists" {
        Mock Get-SecretVault -ModuleName HRProPS {@{Name = "HRProPS"}}

        Set-HRPCredentials

        Assert-MockCalled Register-SecretVault -ModuleName HRProPS -Times 0 -Exactly
        Assert-MockCalled Set-Secret -ModuleName HRProPS -Times 1 -Exactly
    }

    It "stores the credentials in the vault" {
        Set-HRPCredentials

        Assert-MockCalled Set-Secret -ModuleName HRProPS -Times 1 -Exactly -ParameterFilter {
            $Name -eq "HRProPS" -and
            $Secret -eq $cred
            $Vault -eq "HRProPS"
        }
    }

    It "throws if SecretManagement is not installed" {
        Mock Get-Module -ModuleName HRProPS {$false} -ParameterFilter {
            $Name -eq "Microsoft.PowerShell.SecretManagement"
        }

        { Set-HRPCredentials } | Should -Throw "Microsoft.PowerShell.SecretManagement module is not installed."
    }

    It "throws if SecretStore is not installed" {
        Mock Get-Module -ModuleName HRProPS {$false} -ParameterFilter { 
            $Name -eq "Microsoft.PowerShell.SecretStore"
        }

        { Set-HRPCredentials } | Should -Throw "Microsoft.PowerShell.SecretStore module is not installed."
    }
}