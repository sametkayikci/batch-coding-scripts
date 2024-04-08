
$solutionPath = "."

$projects = Get-ChildItem -Path $solutionPath -Include *.csproj -Recurse

foreach ($project in $projects) {
    if ($project.Name -match 'API.csproj$') {
        $projectName = $project.Name -replace 'API.csproj$', ''
        $extensionsFolderPath = Join-Path $project.DirectoryName "Extensions"        
     
        if (-not (Test-Path $extensionsFolderPath)) {
            New-Item -ItemType Directory -Path $extensionsFolderPath | Out-Null
        }        
    
        $classFilePath = Join-Path $extensionsFolderPath "${projectName}Config.cs"        
   
        if (-not (Test-Path $classFilePath)) {
            $classContent = @"


namespace $(($project.Directory.Name).Replace(".API", "")) {
    public record ${projectName}Config
    {
        public required bool UseHttps { get; init; }
        public required string UserName { get; init; }
        public required string Password { get; init; }
        public required string EndpointAddress { get; init; }
        public required PollyPolicyOptions PollyPolicyOptions { get; init; }
    }

    public record PollyPolicyOptions
    {
        public int RetryCount { get; set; }
        public double InitialRetryDelayInSeconds { get; set; }
        public int ExceptionsAllowedBeforeBreaking { get; set; }
        public double DurationOfBreakInMinutes { get; set; }
    }
}
"@
            $classContent | Out-File -FilePath $classFilePath
            Write-Host "Oluşturuldu: $classFilePath"
        } else {
            Write-Host "$classFilePath zaten var."
        }
    }
}
