# Validate API Management Policies with PSRule

These samples demonstrate how to validate Azure API Management (APIM) policies using [PSRule](https://microsoft.github.io/PSRule). See the following blog posts for more information:
- [Validate API Management policies with PSRule](https://ronaldbosma.github.io/blog/2024/09/02/validate-api-management-policies-with-psrule/)
- [Testing PSRule Rules for API Management Policies with Pester](https://ronaldbosma.github.io/blog/2024/09/26/testing-psrule-rules-for-api-management-policies-with-pester/)

## Execute PSRule on APIM Policy rules

The `.ps-rule` folder contains custom [PSRule](https://microsoft.github.io/PSRule) conventions and rules, which can be used to validate Azure API Management (APIM) policies through static analysis. The `src` folder contains a couple of sample policy files that can be used to test the custom rules. 

Execute the following command to check the policies in the `src` folder against the custom APIM Policy rules:

```powershell
Invoke-PSRule -InputPath ".\src\" -Option ".\.ps-rule\ps-rule.yaml"
```

## Execute tests

The `test` folder contains [Pester](https://pester.dev/) tests for each custom rule. 
To execute the tests, open a PowerShell terminal, navigate to the `tests` folder and execute the following command:

```powershell
.\Invoke-PesterTests.ps1 -ModulePath .
```

You can filter the test files using the `-IncludeTestFiles` parameter. For example, to test only the rules that are in files with `UseBackend` in the name, execute the following command:

```powershell
.\Invoke-PesterTests.ps1 -ModulePath . -IncludeTestFiles "*UseBackend*"
```