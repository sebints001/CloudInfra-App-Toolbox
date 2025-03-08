param($Context)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

$userInput = ($Context.Input | ConvertFrom-Json)

if($null -ne $userInput){

    Write-Information "Executing the orchestrator"

    $inputData = Invoke-DurableActivity -FunctionName 'CreateInputData' -Input $userInput
    
    if($null -eq $inputData) {
        Write-Error "Invalid Tenant"
    }
    else {

        Write-Information "Input data created successfully"
    }   
}




