Parse the Apache combined access log at /app/data/access.log and generate a JSON report at /app/report.json.

The report must contain:
1. Total number of requests processed
2. For each unique request path, count of requests
3. HTTP status code breakdown (2xx, 3xx, 4xx, 5xx categories)
4. Total response size in bytes
5. Average response size in bytes

JSON schema:
{
  "total_requests": integer,
  "path_counts": {"path": integer, ...},
  "status_breakdown": {"2xx": integer, "3xx": integer, "4xx": integer, "5xx": integer},
  "total_response_size_bytes": integer,
  "average_response_size_bytes": float
}

Success criteria:
1. Report is valid JSON at /app/report.json
2. total_requests matches number of log lines
3. path_counts contains all unique paths
4. Each path has correct count
5. status_breakdown correctly categorizes all status codes
6. total_response_size_bytes equals sum of all response sizes
7. average_response_size_bytes = total / count (with decimal precision)