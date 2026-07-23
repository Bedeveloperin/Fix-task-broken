#!/bin/bash
set -euo pipefail

echo "=== Generating report ==="

python3 << 'EOF'
import json
from pathlib import Path
from collections import defaultdict

log_path = Path("/app/data/access.log")
report_path = Path("/app/report.json")

# Read log
with open(log_path) as f:
    lines = [l.strip() for l in f if l.strip()]

# Initialize counters
path_counts = defaultdict(int)
status_counts = defaultdict(int)
total_size = 0

# Parse each line
for line in lines:
    parts = line.split()
    if len(parts) < 10:
        continue
    
    path = parts[6]
    status = int(parts[8])
    size = int(parts[9]) if parts[9] != '-' else 0
    
    path_counts[path] += 1
    status_counts[f"{status // 100}xx"] += 1
    total_size += size

# Calculate average
avg = total_size / len(lines) if lines else 0

# Create report
report = {
    "total_requests": len(lines),
    "path_counts": dict(path_counts),
    "status_breakdown": {
        "2xx": status_counts.get("2xx", 0),
        "3xx": status_counts.get("3xx", 0),
        "4xx": status_counts.get("4xx", 0),
        "5xx": status_counts.get("5xx", 0),
    },
    "total_response_size_bytes": total_size,
    "average_response_size_bytes": round(avg, 2)
}

# Write report
with open(report_path, "w") as f:
    json.dump(report, f, indent=2)

print(f"Report written to {report_path}")
print(json.dumps(report, indent=2))
EOF
