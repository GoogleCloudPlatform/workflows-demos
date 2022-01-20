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

using System.Numerics;
using Microsoft.AspNetCore.Mvc;

namespace PrimeGenController.Controllers;

[ApiController]
//[Route("[controller]")]
[Route("")]
public class PrimeGenController : ControllerBase
{
    private static BigInteger LargestPrime;

    private static bool started;

    private readonly ILogger<PrimeGenController> _logger;

    public PrimeGenController(ILogger<PrimeGenController> logger)
    {
        _logger = logger;
    }

    [HttpGet("start")]
    public ActionResult Start()
    {
        if (started)
        {
            return BadRequest("Already calculating a prime");
        }

        _logger.LogInformation($"Prime generation starting");
        Task.Run(() =>
        {
            // TODO: Need to check whether this approach works
            // What happens when the controller is deleted?
            StartPrimeGeneration();
        });
        return Ok("Started");
    }

    [HttpGet("stop")]
    public ActionResult Stop()
    {
        _logger.LogInformation($"Prime generation stopping");
        StopPrimeGeneration();
        return Ok("Stopped");
    }

    [HttpGet]
    public ActionResult<string> Get()
    {
        _logger.LogInformation($"Returning largest calculated prime");
        return Ok(LargestPrime.ToString());
    }

    private void StartPrimeGeneration()
    {
        started = true;
        BigInteger n = LargestPrime;
        while (started)
        {
            if (isPrime(++n))
            {
                LargestPrime = n;
            }
        }
    }

    private void StopPrimeGeneration()
    {
        started = false;
    }

    private static bool isPrime(BigInteger n)
    {
        if (n == 1)
        {
            return false;
        }
        for (int i = 2; i < n; i++)
        {
            if (n % i == 0)
            {
                return false;
            }
        }
        return true;
    }
}
