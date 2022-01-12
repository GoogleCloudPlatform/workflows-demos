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

    private static int requestCount = 0;

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
        if (requestCount++ % 2 == 0)
        {
            _logger.LogInformation($"Reserving credit: {credit.Amount} for customer: {credit.CustomerId}");
            return Ok(credit);
        }
        _logger.LogInformation($"Failed: Reserving credit: {credit.Amount} for customer: {credit.CustomerId}");
        return StatusCode(StatusCodes.Status503ServiceUnavailable);
    }

    [HttpPost("always-fails")]
    public ActionResult<Credit> ReserveCreditAlwaysFails(Credit credit)
    {
        _logger.LogInformation($"Failed: Reserving credit: {credit.Amount} for customer: {credit.CustomerId}");
        return StatusCode(StatusCodes.Status500InternalServerError);
    }
}
