# Snippets

- [input-validation.xml](input-validation.xml): A snippet that performs input validation on parameters and on bodies (if the HTTP method allows a body). Can be used on the inbound section of e.g. the API or global scope.
- [log-error-response.xml](log-error-response.xml): A snippet that logs error responses. Can be used in the outbound section of e.g. the global scope.
- [log-jwt-token-details.xml](log-jwt-token-details.xml): A snippet that logs details from a JWT token present in the Authorization header. Can be used in the inbound section of e.g. the global scope before token validation takes place. It can handle scenarios where the token is missing or invalid.