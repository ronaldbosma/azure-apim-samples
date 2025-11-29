using System.Net;
using System.Net.Http;

namespace GenericErrorHandling.Tests
{
    [TestClass]
    public sealed class FrontEndTests
    {
        private static HttpClient? HttpClient;

        [ClassInitialize]
        public static void ClassInitialize(TestContext context)
        {
            var baseUrl = context.Properties["ApimBaseUrl"]?.ToString() ?? throw new InvalidOperationException("ApimBaseUrl not configured");
            HttpClient = new HttpClient() { BaseAddress = new Uri(baseUrl) };
        }

        [ClassCleanup]
        public static void ClassCleanup()
        {
            HttpClient?.Dispose();
        }

        /// <summary>
        /// Calls the 'default-behaviour' operation on the Frontend API.
        /// Status codes 404,409,413,429 from the backend are returned as is,
        /// all other status codes are converted into a 500.
        /// </summary>
        [TestMethod]
        // Success codes codes
        [DataRow(200, 200)]
        [DataRow(201, 201)]
        [DataRow(204, 204)]
        // 4xx status codes
        [DataRow(400, 500)]
        [DataRow(401, 500)]
        [DataRow(403, 500)]
        [DataRow(404, 404)]
        [DataRow(409, 409)]
        [DataRow(413, 413)]
        [DataRow(429, 429)]
        // 5xx status codes
        [DataRow(500, 500)]
        [DataRow(501, 500)]
        [DataRow(502, 500)]
        [DataRow(503, 500)]
        public async Task DefaultBehaviour(int backendStatusCode, int expectedStatusCode)
        {
            // Act
            var response = await HttpClient!.GetAsync($"frontend/default-behaviour/{backendStatusCode}");

            // Assert
            Assert.IsNotNull(response);
            Assert.AreEqual(expectedStatusCode, (int)response.StatusCode);
        }

        /// <summary>
        /// Calls the 'error-handled' operation on the Frontend API.
        /// There is no custom error handling in the operation.
        /// All status codes are returned as is.
        /// </summary>
        [TestMethod]
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
        public async Task ErrorHandled(int backendStatusCode, int expectedStatusCode)
        {
            // Act
            var response = await HttpClient!.GetAsync($"frontend/error-handled/{backendStatusCode}");

            // Assert
            Assert.IsNotNull(response);
            Assert.AreEqual(expectedStatusCode, (int)response.StatusCode);
        }

        /// <summary>
        /// Calls the 'custom-error-handling' operation on the Frontend API.
        /// - A 201 is turned into a 418. Because we don't set error-handled to true, this should be turned into a 500 by the global error handling.
        /// - A 204 is turned into a 418. Because we set error-handled to true, the global error handling is skipped and it is returned as is.
        /// - For all other responses, the default is applied.
        /// </summary>
        [TestMethod]
        // Success codes codes
        [DataRow(200, 200)]
        [DataRow(201, 500)]
        [DataRow(204, 418)]
        // 4xx status codes
        [DataRow(400, 500)]
        [DataRow(401, 500)]
        [DataRow(403, 500)]
        [DataRow(404, 404)]
        [DataRow(409, 409)]
        [DataRow(413, 413)]
        [DataRow(429, 429)]
        // 5xx status codes
        [DataRow(500, 500)]
        [DataRow(501, 500)]
        [DataRow(502, 500)]
        [DataRow(503, 500)]
        public async Task CustomErrorHandling(int backendStatusCode, int expectedStatusCode)
        {
            // Act
            var response = await HttpClient!.GetAsync($"frontend/custom-error-handling/{backendStatusCode}");

            // Assert
            Assert.IsNotNull(response);
            Assert.AreEqual(expectedStatusCode, (int)response.StatusCode);
        }

        /// <summary>
        /// Calls the 'override-passthrough-error-codes' operation on the Frontend API.
        /// The operation overrides the error status codes to passthrough,
        /// which means status codes 401,403,404,503 from the backend are returned as is,
        /// all other status codes are converted into a 500.
        /// </summary>
        [TestMethod]
        // Success codes codes
        [DataRow(200, 200)]
        [DataRow(201, 201)]
        [DataRow(204, 204)]
        // 4xx status codes
        [DataRow(400, 500)]
        [DataRow(401, 401)]
        [DataRow(403, 403)]
        [DataRow(404, 404)]
        [DataRow(409, 500)]
        [DataRow(413, 500)]
        [DataRow(429, 500)]
        // 5xx status codes
        [DataRow(500, 500)]
        [DataRow(501, 500)]
        [DataRow(502, 500)]
        [DataRow(503, 503)]
        public async Task OverridePassthroughErrorCodes(int backendStatusCode, int expectedStatusCode)
        {
            // Act
            var response = await HttpClient!.GetAsync($"frontend/override-passthrough-error-codes/{backendStatusCode}");

            // Assert
            Assert.IsNotNull(response);
            Assert.AreEqual(expectedStatusCode, (int)response.StatusCode);
        }
    }
}
