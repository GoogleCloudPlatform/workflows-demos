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
// limitations under the License

using System.Numerics;
using System.Text;
using Google.Cloud.Storage.V1;

// Numbers to process per batch
const int NUMBERS_PER_BATCH = 10000;

// Read BATCH_TASK_INDEX
var batchTaskIndex = ReadBatchTaskIndex();

// Calculate min and max ranges for the batch
var (min, max) = CalculateMinMaxRange(batchTaskIndex);

// Go through the range and build a string with prime numbers
var primesForRange = CalculatePrimesForRange(min, max);

// Output to console or to a storage bucket
await OutputPrimesForRangeAsync(primesForRange, min, max);

static int ReadBatchTaskIndex()
{
    var batchTaskIndexVar = Environment.GetEnvironmentVariable("BATCH_TASK_INDEX");
    var batchTaskIndex = batchTaskIndexVar == null ? 0 : int.Parse(batchTaskIndexVar);
    return batchTaskIndex;
}

static (BigInteger, BigInteger) CalculateMinMaxRange(int batchTaskIndex)
{
    BigInteger min = batchTaskIndex * NUMBERS_PER_BATCH + 1;
    BigInteger max = batchTaskIndex * NUMBERS_PER_BATCH + NUMBERS_PER_BATCH;
    Console.WriteLine($"BatchTaskIndex: {batchTaskIndex}, Min: {min}, Max: {max}");
    return (min, max);
}

static string CalculatePrimesForRange(BigInteger min, BigInteger max)
{
    var stringBuilder = new StringBuilder();
    for (BigInteger i = min; i <= max; i++)
    {
        if (isPrime(i))
        {
            stringBuilder.AppendLine(i.ToString());
        }
    }
    return stringBuilder.ToString();
}

static async Task OutputPrimesForRangeAsync(string primesForRange, BigInteger min, BigInteger max)
{
    var bucket = Environment.GetEnvironmentVariable("BUCKET");
    Console.WriteLine($"Output to: {(string.IsNullOrEmpty(bucket) ? "console" : bucket)}");

    if (string.IsNullOrEmpty(bucket))
    {
        Console.Write(primesForRange);
    }
    else
    {
        var objectName = $"primes-{min}-{max}.txt";
        await OutputToCloudStorageAsync(primesForRange, bucket, objectName);
    }
}

static async Task OutputToCloudStorageAsync(string primesForRange, string bucket, string objectName)
{
    using (var outputStream = new MemoryStream(Encoding.UTF8.GetBytes(primesForRange)))
    {
        var client = await StorageClient.CreateAsync();
        await client.UploadObjectAsync(bucket, objectName, "text/plain", outputStream);
        Console.WriteLine($"Uploaded '{objectName}' to bucket '{bucket}'");
    }
}

static bool isPrime(BigInteger n)
{
    if (n == 1)
    {
        return false;
    }

    for (BigInteger i = 2; i <= (BigInteger)Math.Sqrt((double)n); i++)
    {
        if (n % i == 0)
        {
            return false;
        }
    }
    return true;
}