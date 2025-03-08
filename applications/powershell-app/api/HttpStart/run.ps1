using namespace System.Net

param($Request, $TriggerMetadata)

$FunctionName = $Request.Params.FunctionName

$RootFolder = ((Get-Item $PSScriptRoot).Parent).FullName

#Loading methods and modules
Import-Module  "$RootFolder\Shared\shared.psm1"

$statusUri = $null
$reqBody = $Request.Body
$validationResponse = ValidateInput -Request $reqBody
Write-Information "$($reqBody | ConvertTo-Json)" -InformationAction Continue
$errorMessage = $validationResponse
Write-Information "Error Message $errorMessage" -InformationAction Continue

if($Request.Body -and $null -eq $errorMessage) {
    Write-Information "$($Request)" -InformationAction Continue
    try{
        Write-Information "HttpStart Context input -  $($Request)" -InformationAction Continue

        $req = ($Request| ConvertTo-Json)
        Write-Information "HttpStart request $($req)" -InformationAction Continue
        $InstanceId = Start-DurableOrchestration -FunctionName $FunctionName -Input $req

        Write-Information "Started orchestration with ID = '$InstanceId'" -InformationAction Continue
        $response = New-DurableOrchestrationCheckStatusResponse -Request $Request -InstanceId $InstanceId
        $status = [HttpStatusCode]::OK
        Write-Information "Response = $($response.Body.statusQueryGetUri)" -InformationAction Continue
        $statusUri = $response.Body.statusQueryGetUri
    }
    catch{
        Write-Information "$($_)"
        $errorMessage = (Get-StatusMessage -SubscriptionName $subName).CustomServerError
    }
    finally {
        $failSafe = $false
    }
}
else {
    if($null -eq $errorMessage){
        $errorMessage = (Get-ValidationMessage).InvalidInputMessage
    }
    $status = [HttpStatusCode]::BadRequest

    try {
        $requestor = $reqBody.Requestor
        Write-Information "Requestor - $requestor" -InformationAction Continue
    }
    catch {
        Write-Information "Validation Email Notification Error: $($_.Exception.Message)"
    }
}

$body = [PSCustomObject]@{
    FailSafe = $failSafe
    StatusUri = $statusUri
    Message = $errorMessage
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body = $body | ConvertTo-Json
})
