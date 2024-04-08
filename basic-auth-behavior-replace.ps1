$solutionPath = "."

$projects = Get-ChildItem -Path $solutionPath -Include *.csproj -Recurse

foreach ($project in $projects) {
    if ($project.Name -match 'API.csproj$') {
       
        $projectName = $project.BaseName
        $extensionsFolderPath = Join-Path $project.DirectoryName "Extensions"

        
        if (-not (Test-Path $extensionsFolderPath)) {
            New-Item -ItemType Directory -Path $extensionsFolderPath | Out-Null
        }

        
        $namespace = "$($projectName).Extensions"

        
        $classContents = @(
@"
using System.ServiceModel.Channels;
using System.ServiceModel.Description;
using System.ServiceModel.Dispatcher;

namespace $namespace;

internal class BasicAuthEndpointBehavior(HttpRequestMessageProperty requestMessageProperty) : IEndpointBehavior
{
    public void AddBindingParameters(ServiceEndpoint endpoint, BindingParameterCollection bindingParameters)
    {
    }

    public void ApplyClientBehavior(ServiceEndpoint endpoint, ClientRuntime clientRuntime)
    {
        clientRuntime.ClientMessageInspectors.Add(new BasicAuthMessageInspector(requestMessageProperty));
    }

    public void ApplyDispatchBehavior(ServiceEndpoint endpoint, EndpointDispatcher endpointDispatcher)
    {
    }

    public void Validate(ServiceEndpoint endpoint)
    {
    }
}
"@,
@"
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.ServiceModel.Dispatcher;

namespace $namespace;

internal class BasicAuthMessageInspector(HttpRequestMessageProperty requestMessageProperty) : IClientMessageInspector
{
    public void AfterReceiveReply(ref Message reply, object correlationState)
    {
    }

    public object? BeforeSendRequest(ref Message request, IClientChannel channel)
    {
        request.Properties[HttpRequestMessageProperty.Name] = requestMessageProperty;
        return null;
    }
}
"@
        )

       
        $classNames = @("BasicAuthEndpointBehavior.cs", "BasicAuthMessageInspector.cs")
        for ($i = 0; $i -lt $classContents.Length; $i++) {
            $classFilePath = Join-Path $extensionsFolderPath $classNames[$i]           
            $finalClassContent = $classContents[$i] -replace '\$namespace', $namespace
            $finalClassContent | Out-File -FilePath $classFilePath
            Write-Host "Oluşturuldu: $classFilePath"
        }
    }
}
