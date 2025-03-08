param($name)

$RootFolder = ((Get-Item $PSScriptRoot).Parent).FullName

$path = "$RootFolder\config.json"

$tenantDetails = Get-Content $path | ConvertFrom-Json

$tenantSettings = $tenantDetails.TenantSettings | Where-Object {$_.TenantId -eq $name.TenantId}

$inputData = [System.Tuple]::Create($name,$tenantSettings)

$inputData