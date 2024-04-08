$solutionPath = "."

$projects = Get-ChildItem -Path $solutionPath -Include *.csproj -Recurse

foreach ($project in $projects) {
    if ($project.Name -match 'API.csproj$') {
        $projectName = $project.BaseName -replace 'API$', ''
        $extensionsFolderPath = Join-Path $project.DirectoryName "Extensions"
    
        if (-not (Test-Path $extensionsFolderPath)) {
            New-Item -ItemType Directory -Path $extensionsFolderPath | Out-Null
        }
        $newFileName = "${projectName}ExtensionsHelpers.cs"
        $newFilePath = Join-Path $extensionsFolderPath $newFileName
  
        $newFileContent = @"
using System.ServiceModel;
using System.ServiceModel.Channels;
using System.Text;

namespace ${projectName}.Extensions;

public class ${projectName}ExtensionsHelpers
{
    public static Binding GetBinding(bool useHttps)
    {
        return useHttps ? BindingFactory.CreateHttpsBinding() : BindingFactory.CreateHttpBinding();
    }

    public static HttpRequestMessageProperty CreateBasicAuthRequest(string username, string password)
    {
        var encodedAuthentication = Convert.ToBase64String(Encoding.ASCII.GetBytes($"{username}:{password}"));

        var requestMessageProperty = new HttpRequestMessageProperty
        {
            Headers = { ["Authorization"] = $"Basic {encodedAuthentication}" }
        };

        return requestMessageProperty;
    }
}

public static class BindingFactory
{
    public static Binding CreateHttpsBinding()
    {
        var binding = new BasicHttpsBinding(BasicHttpsSecurityMode.Transport)
        {
            MaxBufferSize = int.MaxValue,
            ReaderQuotas = System.Xml.XmlDictionaryReaderQuotas.Max,
            MaxReceivedMessageSize = int.MaxValue,
            SendTimeout = TimeSpan.FromMinutes(5),
            ReceiveTimeout = TimeSpan.FromMinutes(5)
        };
        binding.Security.Transport.ClientCredentialType = HttpClientCredentialType.Basic;

        return binding;
    }

    public static Binding CreateHttpBinding()
    {
        var binding = new BasicHttpBinding
        {
            MaxBufferSize = int.MaxValue,
            ReaderQuotas = System.Xml.XmlDictionaryReaderQuotas.Max,
            MaxReceivedMessageSize = int.MaxValue,
            SendTimeout = TimeSpan.FromMinutes(5),
            ReceiveTimeout = TimeSpan.FromMinutes(5)
        };
        binding.Security.Transport.ClientCredentialType = HttpClientCredentialType.Basic;

        return binding;
    }
}
"@ 

        $newFileContent | Out-File -FilePath $newFilePath
        Write-Host "Oluşturuldu: $newFilePath"
    }
}
