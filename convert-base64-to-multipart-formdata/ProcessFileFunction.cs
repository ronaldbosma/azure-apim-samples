using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace AISQuick.FunctionApp;

/// <summary>
/// Function that receives a file as part of a multipart form data request
/// and returns it as a file stream.
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
            // 1. Read the form data
            var formData = await request.ReadFormAsync();

            // 2. Extract the file ID from the form data and log it
            string? fileId = formData["fileId"];
            _logger.LogInformation("File ID: {FileID}", fileId);

            // 3. Extract the binary file from the form data. Throw an exception if it's not present.
            var file = request.Form.Files["file"];
            if (file == null)
            {
                return new BadRequestObjectResult("File not provided.");
            }

            // 4. Log the file details
            _logger.LogInformation("File Name: {FileName}, Content Type: {ContentType}, Size: {Size} bytes",
                file.FileName, file.ContentType, file.Length);

            // 5. Return the file as a stream.
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
