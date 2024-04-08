$solutionPath = "."

$projects = Get-ChildItem -Path $solutionPath -Include *.csproj -Recurse

foreach ($project in $projects) {
    if ($project.Name -match 'API.csproj$') {
        $projectName = $project.BaseName -replace 'API$', ''
        $extensionsFolderPath = Join-Path $project.DirectoryName "Extensions"
        $connectedServiceFolder = Get-ChildItem -Path "$($project.DirectoryName)\Connected Services" -Directory | Select-Object -First 1

        if (-not (Test-Path $extensionsFolderPath)) {
            New-Item -ItemType Directory -Path $extensionsFolderPath | Out-Null
        }
   
        $fileName = "${projectName}ServiceClientExtensions.cs"
        $filePath = Join-Path $extensionsFolderPath $fileName
       
        $fileContent = @"
using ${projectName}.Extensions;
using ${connectedServiceFolder.Name};
using Microsoft.Extensions.Options;
using System.ServiceModel;

namespace ${projectName}.Extensions;

public static class ${projectName}ServiceClientExtensions
{
    public static void Add${projectName}ServiceClient(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<${projectName}Config>(configuration.GetSection(nameof(${projectName}Config)));
        services.AddTransient(provider =>
        {
            var config = provider.GetRequiredService<IOptions<${projectName}Config>>().Value;
            var client = new ${connectedServiceFolder.Name}ServiceClient
            {
                Endpoint =
                {
                    Address = new EndpointAddress(config.EndpointAddress),
                    Binding = ${projectName}ExtensionsHelpers.GetBinding(config.UseHttps)
                },
                ClientCredentials =
                {
                    UserName =
                    {
                        UserName = config.UserName,
                        Password = config.Password
                    }
                }
            };

            var requestMessageProperty = ${projectName}ExtensionsHelpers.CreateBasicAuthRequest(config.UserName, config.Password);
            client.Endpoint.EndpointBehaviors.Add(new BasicAuthEndpointBehavior(requestMessageProperty));
            return client;
        });
    }
}
"@

        $fileContent | Out-File -FilePath $filePath
        Write-Host "Oluşturuldu: $filePath"
    }
}
