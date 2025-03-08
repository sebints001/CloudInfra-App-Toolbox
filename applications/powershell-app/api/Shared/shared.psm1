$RootFolder = ((Get-Item $PSScriptRoot).Parent).FullName

Import-Module "$RootFolder\Shared\enum.psm1"

function Get-AzureTokenUsingMSI{
  Param(
   [Parameter(Mandatory = $true)][string]$ClientIdKeyName,
   [Parameter(Mandatory = $true)][string]$SecretKeyName,
   [Parameter(Mandatory = $true)][ValidateSet("MSGraph","Management")][string]$AccessType,
   [Parameter(Mandatory = $true)][string]$TenantId
  )
  $msiToken = Get-MSIToken -ResourceUri "https://vault.azure.net"
  $clientId = GetKeyvaultSecret -KeyVaultName $env:KeyVaultName -SecretName $ClientIdKeyName -AccessToken $msiToken
  $secret = GetKeyvaultSecret -KeyVaultName $env:KeyVaultName -SecretName $SecretKeyName -AccessToken $msiToken
  if ($AccessType -eq "Management") {
    $token = Get-ResourceAccessToken -TenantId $TenantId -ClientId $clientId  -ClientSecret $secret
  }
  elseif ($AccessType -eq "MSGraph"){
    $token = Get-AccessToken -TenantId $TenantId -ClientId $clientId  -ClientSecret $secret
  }
  
  return $token
}

function Get-Credentials($Username, $KeyVault, $SecretReferenceName) {
    $secret = Get-AzKeyVaultSecret -VaultName $KeyVault -Name $SecretReferenceName -AsPlainText
    $password = ConvertTo-SecureString $secret -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ($Username, $password) 
    
    return $creds
}


function GetKeyvaultSecret{
  Param(
   [Parameter(Mandatory = $true)][string]$KeyVaultName,
   [Parameter(Mandatory = $true)][string]$SecretName,
   [Parameter(Mandatory = $true)][PSCustomObject]$AccessToken
  )
  $uri="https://$($KeyVaultName).vault.azure.net//secrets/$($SecretName)?api-version=7.3"

  $response = GET-RestAPI -url $uri -AccessToken $AccessToken
  
  return $response
}

function Get-MSIToken{
  Param(
    [Parameter(Mandatory = $true)][string]$ResourceUri
   )
  $tokenAuthUri = $env:MSI_ENDPOINT + "?resource=$ResourceUri&api-version=2017-09-01"
  $headers = @{ "Secret" =  "$env:MSI_SECRET"}
  
  $response = Invoke-RestMethod -Method Get -Uri $tokenAuthUri -Headers $headers

  return $response
}

# Get the Resource access token
function Get-ResourceAccessToken{
  Param(
   [Parameter(Mandatory = $true)][string]$TenantId,
   [Parameter(Mandatory = $true)][string]$ClientId,
   [Parameter(Mandatory = $true)][string]$ClientSecret,
   [Parameter(Mandatory = $false)][string]$Resource = "https://management.core.windows.net/"
   )

   $RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

   $Body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"
   $token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $Body -ContentType 'application/x-www-form-urlencoded'
   
   return $token
}


# Get the graph token
function Get-AccessToken{
    <#
    .SYNOPSIS
        Create access token for connecting to the rest apis
    #>    
       Param(
         [Parameter(Mandatory = $true)][string]$ClientId,
         [Parameter(Mandatory = $false)][string]$AzureCloud="AzureCloud",
         [Parameter(Mandatory = $true)][string]$ClientSecret,
         [Parameter(Mandatory = $true)][string]$TenantId
       )
    
      $Body = @{    
       Grant_Type    = "client_credentials"
       Scope         = "https://graph.microsoft.com/.default"
       client_Id     = $ClientId
       Client_Secret = $ClientSecret
      }
      
      switch($AzureCloud)
        {
            'AzureCloud' {$azureEndpoint="login.microsoftonline.com"}
            default {Write-Output "Specify an existing AzureCloud. Available values: 'AzureCloud','AzureChinaCloud'"}
        } 
    
      $token = Invoke-RestMethod -Uri "https://$azureEndpoint/$TenantId/oauth2/v2.0/token" `
                                        -Method POST -Body $Body
    
      return $token
}
