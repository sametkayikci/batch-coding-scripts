$solutionPath = "."

$projects = Get-ChildItem -Path $solutionPath -Include *.csproj -Recurse

foreach ($project in $projects) {
    if ($project.Name -match 'API.csproj$') {
        $projectName = $project.Name -replace 'API.csproj$', ''
        $configSectionName = "${projectName}Config"

        $connectedServicePaths = Get-ChildItem -Path $project.DirectoryName -Filter ConnectedService.json -Recurse
        
        $endpointAddress = $null
        foreach ($connectedServicePath in $connectedServicePaths) {          
            $connectedServiceJson = Get-Content $connectedServicePath.FullName -Raw | ConvertFrom-Json
            if ($connectedServiceJson.ExtendedData.inputs -and $connectedServiceJson.ExtendedData.inputs.Count -gt 0) {
                $endpointAddress = $connectedServiceJson.ExtendedData.inputs[0] -replace '\?wsdl$', ''
                break 
            }
        }

        $appSettingsPaths = @("appsettings.json", "appsettings.Development.json") | ForEach-Object {
            Join-Path $project.DirectoryName $_
        }

        foreach ($appSettingsPath in $appSettingsPaths) {
            if (Test-Path $appSettingsPath) {
                $jsonContent = Get-Content $appSettingsPath -Raw | ConvertFrom-Json
                
                if ($null -eq $jsonContent) {
                    $jsonContent = New-Object PSObject
                }

                $configData = @{
                    UseHttps = $false
                    UserName = "XXXX"
                    Password = "XXXX"
                    EndpointAddress = $endpointAddress
                    PollyPolicies = @{
                        RetryCount = 3
                        InitialRetryDelayInSeconds = 2
                        ExceptionsAllowedBeforeBreaking = 2
                        DurationOfBreakInMinutes = 1
                    }
                }
                
                if ($jsonContent.PSObject.Properties.Name -contains $configSectionName) {
                    $jsonContent.$configSectionName = $configData
                } else {
                    Add-Member -InputObject $jsonContent -MemberType NoteProperty -Name $configSectionName -Value $configData
                }

                $jsonContent | ConvertTo-Json | Set-Content $appSettingsPath
                Write-Host "Güncellendi: $appSettingsPath"
            }
        }
    }
}
