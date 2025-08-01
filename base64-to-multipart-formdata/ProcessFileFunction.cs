using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace AISQuick.FunctionApp;

/// <summary>
/// Function that retrieves a file as part of a multipart form data request and returns it as a file stream.
/// </summary>
public class ProcessFileFunction
{
    private readonly ILogger<ProcessFileFunction> _logger;

    public ProcessFileFunction(ILogger<ProcessFileFunction> logger)
    {
        _logger = logger;
    }

    [Function(nameof(ProcessFileFunction))]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "process-file")] HttpRequest request)
    {
        try
        {
            var formdata = await request.ReadFormAsync();

            string? fileId = formdata["fileId"];
            _logger.LogInformation("File ID: {FileID}", fileId);

            var file = request.Form.Files["file"];
            if (file == null)
            {
                return new BadRequestObjectResult("File not provided.");
            }

            _logger.LogInformation("File Name: {FileName}, Content Type: {ContentType}, Size: {Size} bytes",
                file.FileName, file.ContentType, file.Length);

            var stream = file.OpenReadStream();
            return new FileStreamResult(stream, file.ContentType)
            {
                FileDownloadName = file.FileName
            };
        }
        catch (Exception ex)
        {
            // If something goes wrong, return the exception details.
            // Don't do this in production code, as it can expose sensitive information.
            return new ContentResult
            {
                StatusCode = StatusCodes.Status500InternalServerError,
                Content = ex.ToString(),
                ContentType = "text/plain"
            };
        }
    }
}
