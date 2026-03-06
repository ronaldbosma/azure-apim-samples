using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Net;
using System.Text.Json;

namespace FunctionApp;

/// <summary>
/// Function that returns the name of the function app and region it is running in, 
/// and allows to specify the result code to return in the request body. 
/// This is used to simulate a backend service that can return different status codes, 
/// and to identify which function app is responding to the request in the failover scenario.
/// </summary>
public class ProcessRequestFunction
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    private static readonly string? CurrentFunctionAppName = Environment.GetEnvironmentVariable("WEBSITE_SITE_NAME");
    private static readonly string? CurrentRegion = Environment.GetEnvironmentVariable("REGION_NAME");

    private record ProcessRequestItem(string FunctionApp, int RespondsWithResultCode)
    {
    }

    private record ProcessResponse(string? FunctionAppName, string? Region)
    {
    }

    [Function(nameof(ProcessRequestFunction))]
    public async Task<HttpResponseData> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequestData req)
    {
        var requestBody = await req.ReadAsStringAsync();
        if (requestBody == null || !TryParseRequest(requestBody, out var request))
        {
            return await CreateBadRequestResponse(req, "Invalid request body");
        }

        var matchedRequestItem = request.FirstOrDefault(item => item.FunctionApp == CurrentFunctionAppName);
        if (matchedRequestItem == null)
        {
            return await CreateBadRequestResponse(req, "No matching function app found in request");
        }

        // Create response with the specified result code
        var httpResponse = req.CreateResponse((HttpStatusCode)matchedRequestItem.RespondsWithResultCode);
        httpResponse.Headers.Add("Content-Type", "application/json");

        // Create response body with the name of the function app and region, to identify which function app is responding in the failover scenario
        var response = new ProcessResponse(CurrentFunctionAppName, CurrentRegion);
        await httpResponse.WriteStringAsync(JsonSerializer.Serialize(response, JsonOptions));

        return httpResponse;
    }

    private static bool TryParseRequest(string requestBody, out List<ProcessRequestItem> request)
    {
        request = [];

        try
        {
            var parsed = JsonSerializer.Deserialize<List<ProcessRequestItem>>(requestBody, JsonOptions);
            if (parsed == null || parsed.Count == 0)
            {
                return false;
            }

            request = parsed;
            return true;
        }
        catch (JsonException)
        {
            return false;
        }
    }

    private static async Task<HttpResponseData> CreateBadRequestResponse(HttpRequestData req, string message)
    {
        var badResponse = req.CreateResponse(HttpStatusCode.BadRequest);
        await badResponse.WriteStringAsync(message);
        return badResponse;
    }
}