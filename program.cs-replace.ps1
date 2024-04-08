$solutionPath = "."

$projects = Get-ChildItem -Path $solutionPath -Include *.csproj -Recurse

foreach ($project in $projects) {
    if ($project.Name -match 'API.csproj$') {
        $projectFullName = $project.BaseName # Tam proje adı, 'API' ile bitiyor
        $projectName = $project.BaseName -replace 'API$', '' # 'API' ifadesi çıkarılmış proje adı
        $programCsPath = Join-Path $project.DirectoryName "Program.cs"
      
        $newContent = @"
using ${projectFullName}.Extensions; 

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.Add${projectName}ServiceClient(builder.Configuration); 
builder.Services.AddPollyPolicies(builder.Configuration); 

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();
app.Run();
"@

        
        $newContent | Set-Content $programCsPath
        Write-Host "Güncellendi: $programCsPath"
    }
}
