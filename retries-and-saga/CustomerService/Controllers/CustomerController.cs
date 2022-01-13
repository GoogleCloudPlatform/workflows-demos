// Copyright 2022 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using Microsoft.AspNetCore.Mvc;

namespace CustomerService.Controllers;

[ApiController]
// [Route("[controller]")]
[Route("")]
public class CustomerController : ControllerBase
{
    private readonly ILogger<CustomerController> _logger;

    private static int requestCount = -1;

    public CustomerController(ILogger<CustomerController> logger)
    {
        _logger = logger;
    }

    [HttpPost("always-works")]
    public ActionResult<Credit> ReserveCreditAlwaysWorks(Credit credit)
    {
        _logger.LogInformation($"Reserving credit: {credit.Amount} for customer: {credit.CustomerId}");
        return Ok(credit);
    }

    [HttpPost("sometimes-works")]
    public ActionResult<Credit> ReserveCreditSometimesWorks(Credit credit)
    {
        requestCount = ++requestCount == 3 ? 0 : requestCount;

        if (requestCount % 3 == 0)
        {
            // Credit reserved successfully
            _logger.LogInformation($"Credit reserved: {credit.Amount} for customer: {credit.CustomerId}");
            return Ok(credit);
        }
        if (requestCount % 3 == 1)
        {
            // Unrecoverable error
            _logger.LogInformation($"Failed: Not enough credit: {credit.Amount} for customer: {credit.CustomerId}");
            return StatusCode(StatusCodes.Status500InternalServerError, "Not enough credit");
        }
        // Possibly recoverable error with a retry
        _logger.LogInformation($"Failed: Service unavailable");
        return StatusCode(StatusCodes.Status503ServiceUnavailable, "Service unavailable");
    }
}
