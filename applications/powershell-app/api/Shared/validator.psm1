$RootFolder = ((Get-Item $PSScriptRoot).Parent).FullName

Import-Module "$RootFolder\Shared\shared.psm1"
Import-Module "$RootFolder\Shared\enum.psm1"
function ValidateInput {
    param (
        [Parameter(Mandatory = $true)][Hashtable]$Request
    )
    $errorMessage = $null
    
    $environment = $Request.Environment
    $type = $Request.Type
    $requestor = $Request.Requestor
  
    $errorMessage = ValidateRequiredInput -TenantId $tenantId -DeploymentId $deploymentId -EngagementId $engagementId `
                                          -FreeText $freeText -Environment $environment -SubOwners $subOwners -RoleGroupOwners $roleGroupOwners `
                                          -ServiceLine $serviceLine -Type $type -Requestor $requestor
    
    if ($null -eq $errorMessage){
        if($allowedTenantIds -notcontains $tenantId -or $deploymentId -match '[^a-zA-Z0-9]' -or
           ($null -ne $freeText -and $freeText -match '[^a-zA-Z0-9]') -or
           $engagementId -match '[^a-zA-Z0-9_\-]'-or $allowedEnvironments -notcontains $environment -or
           $requestor -notmatch '^[\w\.-]+@[\w\.-]+\.\w+$' -or $allowedServiceLines -notcontains $serviceLine) {
 
            if ($allowedTenantIds -notcontains $tenantId) {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredTenantIdMessage
            }
            if ($deploymentId -match '[^a-zA-Z0-9]') {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredDeploymentIdMessage
            }
            if ($null -ne $freeText -and $freeText -match '[^a-zA-Z0-9]') {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredSubNameMessage
            }
            if ($engagementId -match '[^a-zA-Z0-9_\-]') {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredEngagementIdMessage
            }
            if ($allowedEnvironments -notcontains $environment) {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredEnvironmentMessage
            }
            if ($requestor -notmatch '^[\w\.-]+@[\w\.-]+\.[\w]+$') {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredRequestorMessage
            }
            if ($allowedTenantIds -contains $tenantId -and $allowedServiceLines -notcontains $serviceLine) {
                $errorMessage += "`n" + (Get-ValidationMessage).RequiredServiceLineMessage
            }
        }
        else{
            if ($null -ne $freeText) {
                if ($freeText.Length -gt 16) {
                    $freeText = (($freeText.Replace(" ","_"))).Substring(0,16)
                }
                else {
                    $freeText = ($freeText.Replace(" ","_"))
                }
                $Request.FreeText = $freeText
            }
             #-----Remove space from the serviceline input-----
            $Request.ServiceLine = $serviceLine.Replace(" ", "")
        }

       if($null -ne $subOwners){
            $subOwnerDelimitter = Get-Delimiter -Input $subOwners

            if($subOwnerDelimitter){
                $subOwners = $subOwners -split $subOwnerDelimitter
                if($subOwners.Count -ge 3)
                {
                    $subUniqueList = $subOwners | Select-Object -Unique
                    $subDuplicates = Compare-Object -ReferenceObject $subUniqueList -DifferenceObject $subOwners
                    if($null -ne $subDuplicates){
                        $errorMessage += "`n" + (Get-ValidationMessage).DistinctEmailMessage
                    }
                    else{
                        $subOwners | ForEach-Object {
                            $mail = $_
                            if($mail -match '[^a-zA-Z0-9@._ -]'){
                                $errorMessage += "`n" + (Get-ValidationMessage).InvalidEmailMessage
                            }
                        }
                    }
                }
                else{
                    $errorMessage += "`n" + (Get-ValidationMessage).MinSubOwnerMessage
                }
            }
       }
       if($null -ne $roleGroupOwners){

            if(!(IsSelfService -Type $type)){
                $groupOwnerDelimitter = Get-Delimiter -InputItem $roleGroupOwners
                if($groupOwnerDelimitter){
                    $groupOwners = $roleGroupOwners -split $groupOwnerDelimitter
                    if($groupOwners.Count -ge 3)
                    {
                        $uniqueList = $groupOwners | Select-Object -Unique
                        $duplicates = Compare-Object -ReferenceObject $uniqueList -DifferenceObject $groupOwners
                        if($null -ne $duplicates){
                            $errorMessage += "`n" + (Get-ValidationMessage).DistinctRoleOwnerEmailMessage
                        }
                        else{
                            $groupOwners | ForEach-Object {
                                $mail = $_
                                if($mail -match '[^a-zA-Z0-9@._ -]'){
                                    $errorMessage += "`n" + (Get-ValidationMessage).InvalidRoleOwnerEmailMessage
                                }
                            }
                        }
                    }
                    else{
                        $errorMessage += "`n" + (Get-ValidationMessage).MinRolegroupOwnerMessage
                    }
                }
            }
       } 
    }
    return $errorMessage
}
