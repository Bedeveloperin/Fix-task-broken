#!/usr/bin/env python3
import json
from pathlib import Path

LOG_PATH = Path("/app/data/access.log")
OUTPUT_PATH = Path("/app/report.json")

def parse_log():
    """Parse Apache combined log format."""
    lines = LOG_PATH.read_text().strip().split('\n')
    total = len(lines)
    path_counts = {}
    status_counts = {"2xx": 0, "3xx": 0, "4xx": 0, "5xx": 0}
    total_size = 0
    
    for line in lines:
        if not line.strip():
            continue
        parts = line.split()
        if len(parts) < 10:
            continue
        
        # Apache combined log format:
        # IP - - [timestamp] "METHOD PATH PROTOCOL" STATUS SIZE "REFERER" "USER_AGENT"
        path = parts[6]
        status = int(parts[8])
        size = int(parts[9]) if parts[9] != '-' else 0
        
        path_counts[path] = path_counts.get(path, 0) + 1
        category = f"{status // 100}xx"
        status_counts[category] = status_counts.get(category, 0) + 1
        total_size += size
    
    avg = total_size / total if total > 0 else 0
    
    return {
        "total_requests": total,
        "path_counts": path_counts,
        "status_breakdown": status_counts,
        "total_response_size_bytes": total_size,
        "average_response_size_bytes": round(avg, 2)
    }

if __name__ == "__main__":
    report = parse_log()
    with open(OUTPUT_PATH, "w") as f:
        json.dump(report, f, indent=2)
    print(f"Report written to {OUTPUT_PATH}")