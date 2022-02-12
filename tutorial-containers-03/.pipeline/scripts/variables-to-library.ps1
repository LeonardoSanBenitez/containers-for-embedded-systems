<#
.SYNOPSIS
Create or Update a variable group. A more generic approach.
​
.DESCRIPTION
Updates a specified variable group with the values provided
in the $variables parameter. Variables that are not existing in the 
variable group will be added.
Group will be created if it does not exist.
The token that is provided must have access endpoints and library create and manage permissions.
​
.PARAMETER accessToken
Access Token to authorize to the DevOps API. 
Can use $(System.AccessToken) if the project Build Service account 
has administrator permissions for the variable group.
Should use PAT with access to endpoints and creator library permissions.
​
.PARAMETER variableGroupName
The name of the variable group that should be modified.
​
.PARAMETER variables
A dictionary with string key and value pairs that represent the variable names and values that should be updated or added to the variable group.
​
#>
function Update-VariablesInGroup([string] $accessToken, [string] $variableGroupId, [psobject] $variables, [string] $prefix) {
  $header = @{ Authorization = "Basic $accessToken" }
  ## Getting current variable group state
  $variableGroupUri = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$($env:SYSTEM_TEAMPROJECTID)/_apis/distributedtask/variablegroups/$($variableGroupId)?api-version=5.0-preview.1"
  Write-Host "Getting Variable Group from Library"
  $group = Invoke-RestMethod -Uri $variableGroupUri -Headers $header
  Write-Output "Adding and updating variables."
  @($variables.PSObject.Properties) | ForEach-Object {
    $variableName = "$($prefix)$($_.Name)"
    if ($_.Value.GetType() -eq [string]) {
      $variableValue = (New-Object PSObject -Property @{ value = $_.Value })
    }
    else {
      $variableValue = $_.Value
    }
    if ($null -eq $group.variables.$variableName) {
      ## Adding variable if it not already exists
      Add-Member -InputObject $group.variables -MemberType NoteProperty -Name $variableName -Value $variableValue
    }
    else {
      ## Updating value of variable if it already exists
      $group.variables.$variableName.value = $variableValue.value
    }
  }
  ## Converting variable group state back to json
  $groupJson = $group | ConvertTo-Json -Depth 99 -Compress
  Write-Output "Saving new variable group state."
  Invoke-RestMethod -Method Put -Uri $variableGroupUri -Headers $header -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($groupJson))
}

function Add-VariableGroup([string] $accessToken, [string] $variableGroup, [psobject] $variables, [string] $prefix) {
  $header = @{ Authorization = "Basic $accessToken" }
  $newGroupURI = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$($env:SYSTEM_TEAMPROJECTID)/_apis/distributedtask/variablegroups?api-version=5.0-preview.1"
  $groupObject = @{
    "type"        = "Vsts"
    "name"        = "$variableGroup"
    "description" = "Variable group for account $variableGroup"
  }
  $groupObject.variables = $variables
  $groupJSON = $groupObject | ConvertTo-Json -Depth 99 -Compress
  Write-Output "Creating new variable group"
  Write-Output $groupJSON
  Invoke-RestMethod -Method Post -Uri $newGroupURI -Headers $header -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($groupJSON))
}

function CheckVariableGroup([string] $accessToken, [string] $variableGroupName, [psobject] $variables, [string] $prefix) {
  $variableGroupIdURL = "$($env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI)$($env:SYSTEM_TEAMPROJECTID)/_apis/distributedtask/variablegroups?groupName=$($variableGroupName)"
  $header = @{ Authorization = "Basic $accessToken" }
  $variableGroup = $(Invoke-RestMethod -Uri $variableGroupIdURL -Headers $header).value[0]
  if ($null -eq $variableGroup.id) {
    Write-Host "Variable Group does not exist - creating"
    Add-VariableGroup $accessToken $variableGroupName $variables $prefix
  }
  else {
    Write-Host "Group already exists - Getting Variable Group from Library"
    Update-VariablesInGroup $accessToken $variableGroup.id $variables $prefix
  }

}

$variablesList = $args[2] | ConvertFrom-Json
while ($variablesList.GetType() -eq [string]) {
  $variablesList = $variablesList | ConvertFrom-Json
}
Write-Host $variablesList
$accessPair = "$($args[0]):$($args[0])"
$accessToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($accessPair))
CheckVariableGroup $accessToken $args[1] $variablesList $args[3]
