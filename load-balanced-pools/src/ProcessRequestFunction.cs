using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Net;
using System.Text.Json;

namespace FunctionApp;

/// <summary>
/// Sample function that receives a request and returns the responding region.
/// </summary>
public class ProcessRequestFunction
{
    [Function(nameof(ProcessRequestFunction))]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequestData req)
    {
        // Deserialize the request body
        var requestBody = await req.ReadAsStringAsync();
        var request = JsonSerializer.Deserialize<ProcessRequest>(requestBody);

        if (request == null)
        {
            var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
            await badResponse.WriteStringAsync("Invalid request body");
            return badResponse;
        }

        // Determine if this is the primary region
        var isPrimary = Environment.GetEnvironmentVariable("IS_PRIMARY_REGION") == "true";
        var response = new ProcessResponse(isPrimary ? "primary" : "secondary");

        // Create response with appropriate status code
        var statusCode = isPrimary ? request.primaryResultCode : request.secondaryResultCode;
        var httpResponse = req.CreateResponse((HttpStatusCode)statusCode);
        httpResponse.Headers.Add("Content-Type", "application/json");

        await httpResponse.WriteStringAsync(JsonSerializer.Serialize(response));

        return httpResponse;
    }
}


public record ProcessRequest(int primaryResultCode, int secondaryResultCode)
{
}

public record ProcessResponse(string respondingRegion)
{
}

