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

namespace OrderService.Controllers;

[ApiController]
//[Route("[controller]")]
[Route("")]
public class OrderController : ControllerBase
{
    private static readonly Dictionary<string, Order> _orders = new ();
    private readonly ILogger<OrderController> _logger;

    public OrderController(ILogger<OrderController> logger)
    {
        _logger = logger;
    }

    [HttpPost]
    public ActionResult<Order> Create(Order order)
    {
        _orders[order.Id] = order;
        _logger.LogInformation($"Order created: {order.Id}");
        return Created("", order);
    }

    [HttpGet("{id}")]
    public ActionResult<Order> Get(string id)
    {
        var order = _orders[id];
        _logger.LogInformation($"Order returned: {order.Id}");
        return Ok(order);
    }

    [HttpGet]
    public ActionResult<IEnumerable<Order>> List()
    {
        var orders = _orders.Values.ToArray<Order>();
        _logger.LogInformation($"Orders returned: {orders.Length}");
        return Ok(orders);
    }

    [HttpPut("approve/{id}")]
    public ActionResult<Order> Approve(string id)
    {
        if (!_orders.ContainsKey(id))
        {
            return NotFound($"Order {id} not found");
        }

        var order = _orders[id];
        order.Status = Status.Approved;
        _logger.LogInformation($"Order approved: {order.Id}");
        return Ok(order);
    }

    [HttpPut("reject/{id}")]
    public ActionResult<Order> Reject(string id)
    {
        if (!_orders.ContainsKey(id))
        {
            return NotFound($"Order {id} not found");
        }

        var order = _orders[id];
        order.Status = Status.Rejected;
        _logger.LogInformation($"Order rejected: {order.Id}");
        return Ok(order);
    }

    [HttpDelete("{id}")]
    public ActionResult<Order> Delete(string id)
    {
        if (!_orders.ContainsKey(id))
        {
            return NotFound($"Order {id} not found");
        }

        var order = _orders[id];
        _orders.Remove(id);
        _logger.LogInformation($"Order deleted: {order.Id}");
        return Ok(order);
    }

    [HttpDelete]
    public ActionResult DeleteAl()
    {
        _orders.Clear();
        _logger.LogInformation($"All orders deleted");
        return Ok();
    }
}
