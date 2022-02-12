Write-Host $args

$output = [PSCustomObject]@{}

foreach ($variable in $args) {
  $name, $value = $variable.split('=')
  # Write-Host "Adding $($name) : $($value)"
  $output | Add-Member -MemberType NoteProperty -Name $name -Value $value
}

$json_output = $output | ConvertTo-Json -Depth 99 -Compress

Write-Host "##vso[task.setvariable variable=bundledJson;isOutput=true]'$($json_output)'"