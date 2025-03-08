$RootFolder = ((Get-Item $PSScriptRoot).Parent).FullName

Import-Module "$RootFolder\Shared\shared.psm1"

function GetDBToken{
    $dbToken = Get-MSIToken -ResourceUri "https://database.windows.net"
    return $dbToken.access_token
}
function ExecuteStoredProcedure{
    Param(
    [Parameter(Mandatory = $true)][string]$ConnectionString,
    [Parameter(Mandatory = $true)][string]$ProcedureName,
    [Parameter(Mandatory = $true)][hashtable]$Parameters,
    [switch] $IsSelect
    )
    $dbConnection = $null
    try {
        $dbConnection = New-Object System.Data.SqlClient.SqlConnection
        $dbConnection.ConnectionString = $ConnectionString
        $dbConnection.AccessToken = GetDBToken
        $dbConnection.Open()

        # construct command
        $command = New-Object System.Data.SqlClient.SqlCommand
        $command.Connection = $dbConnection
        $command.CommandType = [System.Data.CommandType]::StoredProcedure
        $command.CommandText = "$ProcedureName"

        foreach ($key in $Parameters.Keys) {
            $command.Parameters.AddWithValue($key, $Parameters[$key])
        }
        if($IsSelect){
            Write-Information "Executing Select Stored Procedure" -InformationAction Continue
            # fetch all results
            $dataSet = New-Object System.Data.DataSet
            $dataAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
            $dataAdapter.Fill($dataSet) | Out-Null 
        
            if($dataSet) {
                $result = $dataSet.Tables[0]
            }
        }
        else{
            Write-Information "Executing Non-Select Stored Procedure" -InformationAction Continue
            $command.ExecuteNonQuery() | Out-Null 
            $result = $true
        }
    
        return $result
        
    }
    catch {
        Write-Information "Sql Exception occured - $($_.Exception.Message)" -InformationAction Continue
        $result = $false
        throw
    }
    finally {
        if($null -ne $dbConnection){
            $dbConnection.Close()
        }
    }
}

