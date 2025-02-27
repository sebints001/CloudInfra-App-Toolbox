Param
(
[Parameter(Mandatory=$true)][String]$subscriptionID,
[Parameter(Mandatory=$true)][String]$rgName,
[Parameter(Mandatory=$true)][String]$appGatewayName,
[Parameter(Mandatory=$true)][String]$vNetName,
[Parameter(Mandatory=$true)][String]$vnetRG,
[Parameter(Mandatory=$true)][String]$appGatewaySubnetName,
[Parameter(Mandatory=$true)][String]$location,
[Parameter(Mandatory=$true)][String]$publicIpName,
[Parameter(Mandatory=$true)][String]$dnsPrefix,
[Parameter(Mandatory=$true)][String]$backendAddressType,
[Parameter(Mandatory=$true)][String]$backendFqdnorAddress,
[Parameter(Mandatory=$true)][String]$keyVaultName,
[Parameter(Mandatory=$true)][String]$keyvaultCertificateName,
[Parameter(Mandatory=$true)][String]$applicationId,
[Parameter(Mandatory=$true)][String]$secret
)


#FrontEnd
$frontendPortName = 'frontendport' 
$listenerName = 'http-listener'
$frontendConfigName = 'frontendipconfig'
$fronendPortNumber = 443
$listenerProtocol = 'Https'
$routingRuleType = 'Basic'
$certificateName = "cloudintegrationtest"

#Backend
$backendPoolName = 'backendpool'

#Http Settings
$httpSettings = 'http-Settings'
$cookieAffinityStatus = 'Disabled'
$requestTimeout = 30
$httpSettingsPort = '443'
$httpSettingsProtocol = 'Https'

#Probe
$probeName = 'health-probe'
$healthprobeMatch = '200-401'
$healthprobePath = '/'
$healthprobeInterval = 30
$healthprobeTimeout = 120

#Rule
$ruleName = 'http-rule1' 

#sku
$skuName = 'WAF_v2'
$skuTier = 'WAF_v2'

#autoscale
$minCapacity = 2
$maxCapacity = 10

#Firewall
$firewallMode = 'Prevention'
$rulesetType = 'OWASP'
$rulesetVersion = '3.1'
$fileUploadLimit = 100
$maxRequestSize = 128

#Public IP
$pipSku = 'Standard'
$pipAllocationMethod = 'Static'

$policyType = 'Custom'
$tlsVersion = 'TLSv1_2'
$enableHttp2 = $false
$keyvaultIdentityName = "$($appGatewayName)".Replace("APG", "MID").Replace("WAF", "MID")
$cipherSuites = @("TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256")

$tenantId = '5b973f99-77df-4beb-b27d-aa0c70b8482c'
$securePassword = $secret | ConvertTo-SecureString -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $securePassword

Login-AzAccount
Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $tenantId

#Select-AzSubscription -SubscriptionId $subscriptionID
Set-AzContext -SubscriptionId $subscriptionID

try
{
    # ---------validation---------------
    if($backendAddressType -ne "fqdn" -and $backendAddressType -ne "ipaddress")
    {
      Write-Output "The backend address type should be either fqdn or ipaddress"
      return
    }

    $appGateway = Get-AzApplicationGateway -ResourceGroupName $rgName -Name $appGatewayName -ErrorAction SilentlyContinue

    if($appGateway)
    {
      Write-Output "The given application gateway already exist"
      return
    }

    $pip = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $rgName -ErrorAction SilentlyContinue
    if(!$pip)
    {
      $pip = New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $rgName -AllocationMethod $pipAllocationMethod -DomainNameLabel $dnsPrefix -Location $location -Sku $pipSku
    }

    #Create the IP configurations and frontend port
    $vnet   = Get-AzVirtualNetwork -ResourceGroupName $vnetRG -Name $vNetName
    $appGwsubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $appGatewaysubnetName

    $gipconfig = New-AzApplicationGatewayIPConfiguration `
      -Name $pip.Name `
      -Subnet $appGwsubnet
    $fipconfig = New-AzApplicationGatewayFrontendIPConfig `
      -Name $frontendConfigName `
      -PublicIPAddress $pip
    $frontendport = New-AzApplicationGatewayFrontendPort `
      -Name $frontendPortName `
      -Port $fronendPortNumber

    #Create the backend pool
    if($backendAddressType -eq 'fqdn')
    {
      $backendPool = New-AzApplicationGatewayBackendAddressPool `
      -Name $backendPoolName `
      -BackendFqdns $backendFqdnorAddress 
    }
    elseif($backendAddressType -eq 'ipaddress')
    {
      $backendPool = New-AzApplicationGatewayBackendAddressPool `
      -Name $backendPoolName `
      -BackendIPAddresses $backendFqdnorAddress 
    }


    # Define the status codes to match for the probe
    $match=New-AzApplicationGatewayProbeHealthResponseMatch -StatusCode $healthprobeMatch

    # Create a probe with the PickHostNameFromBackendHttpSettings switch for web apps
    $httpProbeconfig = New-AzApplicationGatewayProbeConfig -name $probeName -Protocol $httpSettingsProtocol -Path $healthprobePath -Interval $healthprobeInterval -Timeout $healthprobeTimeout -UnhealthyThreshold 3 -Match $match -HostName $backendFqdnorAddress


    $poolSettings = New-AzApplicationGatewayBackendHttpSettings `
      -Name $httpSettings `
      -Port $httpSettingsPort `
      -Protocol $httpSettingsProtocol `
      -CookieBasedAffinity $cookieAffinityStatus `
      -RequestTimeout $requestTimeout `
      -PickHostNameFromBackendAddress `
      -Probe $httpProbeconfig `


    #Managed Identity
    $identity = New-AzUserAssignedIdentity -Name $keyvaultIdentityName `
      -Location $location -ResourceGroupName $rgName
    $appgwIdentity = New-AzApplicationGatewayIdentity -UserAssignedIdentityId $identity.Id
    Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ObjectId $identity.PrincipalId -PermissionsToSecrets get -PermissionsToCertificates get  -BypassObjectIdValidation

    #Get certificate from keyvault
    $keyvaultCertificate = Get-AzKeyVaultCertificate -VaultName $keyVaultName -Name $keyvaultCertificateName
    $secretId = $keyvaultCertificate.SecretId.Replace($keyvaultCertificate.Version, "")

    $sslCertificate = New-AzApplicationGatewaySslCertificate -Name $keyvaultCertificateName -KeyVaultSecretId $secretId



    #Create the listener and add a rule
    $defaultlistener = New-AzApplicationGatewayHttpListener `
      -Name $listenerName `
      -Protocol $listenerProtocol `
      -FrontendIPConfiguration $fipConfig `
      -FrontendPort $frontendport `
      -SslCertificate $sslCertificate

    $frontendRule = New-AzApplicationGatewayRequestRoutingRule `
      -Name $ruleName `
      -RuleType $routingRuleType `
      -HttpListener $defaultlistener `
      -BackendAddressPool $backendPool `
      -BackendHttpSettings $poolSettings

    # Configure an existing backend http settings
    #Set-AzApplicationGatewayBackendHttpSettings -Name $httpSettings -ApplicationGateway $appgw -PickHostNameFromBackendAddress -Port 80 -Protocol http -CookieBasedAffinity Disabled -RequestTimeout 30 -Probe $probe


    #Create the application gateway
    $wafConfig = New-AzApplicationGatewayWebApplicationFirewallConfiguration -Enabled $true -FirewallMode $firewallMode -RuleSetType $rulesetType -RuleSetVersion $rulesetVersion -FileUploadLimitInMb $fileUploadLimit -MaxRequestBodySizeInKb $maxRequestSize 
    $sku = New-AzApplicationGatewaySku `
      -Name $skuName `
      -Tier $skuTier

    $autoScaleConfig = New-AzApplicationGatewayAutoscaleConfiguration -MinCapacity $minCapacity -MaxCapacity $maxCapacity

     New-AzApplicationGateway `
      -Name $appGatewayName `
      -Identity $appgwIdentity `
      -ResourceGroupName $rgName `
      -Location $location `
      -BackendAddressPools $backendPool `
      -BackendHttpSettingsCollection $poolSettings `
      -Probes $httpProbeconfig `
      -FrontendIpConfigurations $fipconfig `
      -GatewayIpConfigurations $gipconfig `
      -FrontendPorts $frontendport `
      -HttpListeners $defaultlistener `
      -RequestRoutingRules $frontendRule `
      -Sku $sku `
      -SslCertificates $sslCertificate `
      -AutoscaleConfiguration $autoScaleConfig `
      -WebApplicationFirewallConfiguration $wafConfig

    #Update the ciphers
    $appGateway = Get-AzApplicationGateway -ResourceGroupName $rgName -Name $appGatewayName 
    # set the TLS policy on the application gateway
    Set-AzApplicationGatewaySslPolicy -ApplicationGateway $appGateway -PolicyType $policyType -MinProtocolVersion $tlsVersion -CipherSuite $cipherSuites 

    # update the gateway with validated TLS policy
    Set-AzApplicationGateway -ApplicationGateway $appGateway
}
catch [Exception]
{
    Write-Output $_.Exception | format-list -force
}
