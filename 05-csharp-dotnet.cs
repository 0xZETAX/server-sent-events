// C# with .NET Core
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

var app = builder.Build();

app.UseCors();

app.MapGet("/events", async (HttpContext context) =>
{
    context.Response.Headers.Add("Content-Type", "text/event-stream");
    context.Response.Headers.Add("Cache-Control", "no-cache");
    context.Response.Headers.Add("Connection", "keep-alive");

    await context.Response.WriteAsync("data: Connected to C# .NET Core SSE\n\n");
    await context.Response.Body.FlushAsync();

    var cancellationToken = context.RequestAborted;
    
    while (!cancellationToken.IsCancellationRequested)
    {
        var timestamp = DateTime.UtcNow.ToString("o");
        var message = $"{{\"message\": \"Hello from C# .NET Core\", \"timestamp\": \"{timestamp}\"}}";
        
        await context.Response.WriteAsync($"data: {message}\n\n");
        await context.Response.Body.FlushAsync();
        
        await Task.Delay(2000, cancellationToken);
    }
});

app.Run("http://localhost:3005");