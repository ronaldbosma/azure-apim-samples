using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using System.Text.Json;

namespace FunctionApp;

/// <summary>
/// Sample function that triggers on a Service Bus message and writes the message to a table.
/// </summary>
public class ProcessRequestFunction
{
    [Function(nameof(ProcessRequestFunction))]
    public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "post")] ProcessRequest originalRequest)
    {
        var isPrimary = Environment.GetEnvironmentVariable("IS_PRIMARY_REGION") == "true";
        var response = new ProcessResponse(isPrimary ? "primary" : "secondary");

        return new ContentResult
        {
            StatusCode = isPrimary ? originalRequest.primaryResultCode : originalRequest.secondaryResultCode,
            Content = JsonSerializer.Serialize(response),
            ContentType = "application/json"
        };
    }
}


public record ProcessRequest(int primaryResultCode, int secondaryResultCode)
{
}

public record ProcessResponse(string respondingRegion)
{
}

