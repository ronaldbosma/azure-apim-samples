using System.Net;

namespace GenericErrorHandling.Tests
{
    [TestClass]
    public sealed class BackendTests
    {
        public TestContext TestContext { get; set; }

        [TestMethod]
        // Success codes codes
        [DataRow(HttpStatusCode.OK, HttpStatusCode.OK)]
        [DataRow(HttpStatusCode.Created, HttpStatusCode.Created)]
        [DataRow(HttpStatusCode.NoContent, HttpStatusCode.NoContent)]
        // 4xx status codes
        [DataRow(HttpStatusCode.BadRequest, HttpStatusCode.BadRequest)]
        [DataRow(HttpStatusCode.Unauthorized, HttpStatusCode.Unauthorized)]
        [DataRow(HttpStatusCode.Forbidden, HttpStatusCode.Forbidden)]
        [DataRow(HttpStatusCode.NotFound, HttpStatusCode.NotFound)]
        [DataRow(HttpStatusCode.Conflict, HttpStatusCode.Conflict)]
        [DataRow(HttpStatusCode.RequestEntityTooLarge, HttpStatusCode.RequestEntityTooLarge)]
        [DataRow(HttpStatusCode.TooManyRequests, HttpStatusCode.TooManyRequests)]
        // 5xx status codes
        [DataRow(HttpStatusCode.InternalServerError, HttpStatusCode.InternalServerError)]
        [DataRow(HttpStatusCode.NotImplemented, HttpStatusCode.NotImplemented)]
        [DataRow(HttpStatusCode.BadGateway, HttpStatusCode.BadGateway)]
        [DataRow(HttpStatusCode.ServiceUnavailable, HttpStatusCode.ServiceUnavailable)]
        public async Task BackendApiReturnsProvidedStatusCode(HttpStatusCode backendStatusCode, HttpStatusCode expectedStatusCode)
        {
            // Arrange
            var baseUrl = TestContext.Properties["ApimBaseUrl"]?.ToString() ?? throw new InvalidOperationException("ApimBaseUrl not configured");
            using var httpClient = new HttpClient() { BaseAddress = new Uri(baseUrl) };

            // Act
            var response = await httpClient.GetAsync($"backend/{(int)backendStatusCode}");

            // Assert
            Assert.IsNotNull(response);
            Assert.AreEqual(expectedStatusCode, response.StatusCode);
        }
    }
}
