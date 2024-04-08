
$targetDirectory = "."

$oldValue = "http:xxxx.com.tr"
$newValue = "http://xxxxxxx:xxxx"


$apiProjectDirectories = Get-ChildItem -Path $targetDirectory -Directory | Where-Object { $_.Name -match "API$" }

foreach ($projectDir in $apiProjectDirectories) {
    
    $jsonFilePath = Join-Path -Path $projectDir.FullName -ChildPath "appsettings.Development.json"
    if (Test-Path -Path $jsonFilePath) {
        try {
            $jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json
            $jsonString = $jsonContent | ConvertTo-Json -Compress

            if ($jsonString -and $jsonString.Contains($oldValue)) {
                $updatedJsonString = $jsonString.Replace($oldValue, $newValue)
                $updatedJsonContent = $updatedJsonString | ConvertFrom-Json
                $updatedJsonContent | ConvertTo-Json | Set-Content -Path $jsonFilePath
                Write-Host "Updated: $jsonFilePath"
            }
            else {
                Write-Host "No matching EndpointAddress found in: $jsonFilePath"
            }
        } catch {
            Write-Host "Error processing ${jsonFilePath}: $_"
        }
    }
    else {
        Write-Host "No appsettings.Development.json found in: $projectDir.FullName"
    }
}
