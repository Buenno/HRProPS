# HRProPS

A PowerShell module for interacting with HR Professional via their REST API.

[![Continuous Integration](https://github.com/Buenno/HRProPS/actions/workflows/ci.yaml/badge.svg)](https://github.com/Buenno/HRProPS/actions/workflows/ci.yaml)

## Description

HRProPS provides cmdlets to interact with HR Professional via their API, allowing you to retrieve company data, employee information, event calendars, and expenses.

## Prerequisites

- PowerShell 5.1 or later
- Microsoft.PowerShell.SecretManagement module
- Microsoft.PowerShell.SecretStore module

## Installation

### Building the Module

Use PSake to build the module:

```powershell
Invoke-psake -buildFile .\psake.ps1 -taskList compile
```

### Installing the Module

Import the module manually:

```powershell
Import-Module .\BuildOutput\HRProPS\{version}\HRProPS.psd1
```

Or move the module to one of the PSModulePath paths for automatic import:

```powershell
$Env:PSModulePath
```

## Configuration

Before using the module, you need to set up your API credentials.

Run the following command to store your credentials securely:

```powershell
Set-HRPCredentials
```

This will prompt for your HR Pro API username and password and store them in a SecretStore vault.

## Functions

### Company

- **Get-HRPCompany**: Returns company data.

### Configuration

- **Get-HRPCredentials**: Retrieves the stored HR Pro API credentials.
- **Set-HRPCredentials**: Prompts for HR Pro API credentials and stores them securely.

### Employees

- **Get-HRPEmployee**: Retrieve a specific employee record from HR Pro using the employee ID number.
- **Get-HRPEmployees**: Retrieve employee records from HR Pro. Will return all employee records.

### Event Calendar

- **Get-HRPEventCalendar**: Returns a list of Event Calendar items for the specified employee.

### Expenses

- **Get-HRPExpense**: Returns a list of Expense objects.
- **Get-HRPExpenseFile**: Returns either a single or list of ExpenseFile objects.

## Usage

List the available commands:

```powershell
Get-Command -Module HRProPS
```

Use PowerShell's native help feature to learn about each command:

```powershell
Get-Help Get-HRPEmployees -Full
```

## Examples

### Get All Employees

```powershell
Get-HRPEmployees
```

### Get a Specific Employee

```powershell
Get-HRPEmployee -ID 12345
```

### Get Company Data

```powershell
Get-HRPCompany
```

### Get Event Calendar for an Employee

```powershell
Get-HRPEventCalendar -ID 12345 -Year 2023
```

### Get Expenses for an Employee

```powershell
Get-HRPExpense -EmployeeID 12345 -SubmitID 67890
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Toby Williams