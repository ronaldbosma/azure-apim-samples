using System.Net;

namespace GenericErrorHandling.Tests
{
    [TestClass]
    public sealed class BackendTests
    {
        public TestContext TestContext { get; set; }

        /// <summary>
        /// Calls the Backend API directly and verifies that the specified status code is returned.
        /// </summary>
        [TestMethod]
        [Retry(1)] // After a deployment, the first test might fail if APIM is not yet ready. So, we retry once if necessary.
        // Success codes codes
        [DataRow(200, 200)]
        [DataRow(201, 201)]
        [DataRow(204, 204)]
        // 4xx status codes
        [DataRow(400, 400)]
        [DataRow(401, 401)]
        [DataRow(403, 403)]
        [DataRow(404, 404)]
        [DataRow(409, 409)]
        [DataRow(413, 413)]
        [DataRow(429, 429)]
        // 5xx status codes
        [DataRow(500, 500)]
        [DataRow(501, 501)]
        [DataRow(502, 502)]
        [DataRow(503, 503)]
        public async Task BackendApiReturnsProvidedStatusCode(int backendStatusCode, int expectedStatusCode)
        {
            // Arrange
            var baseUrl = TestContext.Properties["ApimBaseUrl"]?.ToString() ?? throw new InvalidOperationException("ApimBaseUrl not configured");
            using var httpClient = new HttpClient() { BaseAddress = new Uri(baseUrl) };

            // Act
            var response = await httpClient.GetAsync($"backend/{backendStatusCode}");

            // Assert
            Assert.IsNotNull(response);
            Assert.AreEqual(expectedStatusCode, (int)response.StatusCode);
        }
    }
}
