#!/bin/bash
set -euo pipefail

python3 << 'EOF'
import json
import sys
from pathlib import Path

def parse_log():
    """Parse the log file to get expected values."""
    log_path = Path("/app/data/access.log")
    report_path = Path("/app/report.json")
    
    # Check if report exists
    if not report_path.exists():
        print(f"ERROR: Report file not found at {report_path}")
        return False, {}
    
    # Read the report
    try:
        with open(report_path) as f:
            actual = json.load(f)
    except json.JSONDecodeError as e:
        print(f"ERROR: Invalid JSON in report: {e}")
        return False, {}
    except Exception as e:
        print(f"ERROR: Could not read report: {e}")
        return False, {}
    
    # Parse the log
    try:
        lines = log_path.read_text().strip().split('\n')
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
            path = parts[6]
            status = int(parts[8])
            size = int(parts[9]) if parts[9] != '-' else 0
            
            path_counts[path] = path_counts.get(path, 0) + 1
            category = f"{status // 100}xx"
            status_counts[category] = status_counts.get(category, 0) + 1
            total_size += size
        
        avg = total_size / total if total > 0 else 0
        
        expected = {
            "total_requests": total,
            "path_counts": path_counts,
            "status_breakdown": status_counts,
            "total_response_size_bytes": total_size,
            "average_response_size_bytes": round(avg, 2)
        }
        
        return True, (actual, expected)
    except Exception as e:
        print(f"ERROR: Failed to parse log: {e}")
        return False, {}

def run_tests():
    """Run all test criteria."""
    success, result = parse_log()
    if not success:
        return False
    
    actual, expected = result
    tests_passed = True
    
    # Test 1: total_requests
    if actual.get("total_requests") != expected["total_requests"]:
        print(f" FAIL: total_requests = {actual.get('total_requests')}, expected {expected['total_requests']}")
        tests_passed = False
    else:
        print(f" PASS: total_requests = {actual.get('total_requests')}")
    
    # Test 2: path_counts contains all paths
    actual_paths = set(actual.get("path_counts", {}).keys())
    expected_paths = set(expected["path_counts"].keys())
    if actual_paths != expected_paths:
        print(f" FAIL: path_counts keys mismatch")
        print(f"  Actual: {actual_paths}")
        print(f"  Expected: {expected_paths}")
        tests_passed = False
    else:
        print(f" PASS: path_counts has all expected paths: {actual_paths}")
    
    # Test 3: path_counts values
    for path, count in expected["path_counts"].items():
        if actual.get("path_counts", {}).get(path) != count:
            print(f" FAIL: path_counts['{path}'] = {actual.get('path_counts', {}).get(path)}, expected {count}")
            tests_passed = False
        else:
            print(f" PASS: path_counts['{path}'] = {count}")
    
    # Test 4: status_breakdown
    if actual.get("status_breakdown") != expected["status_breakdown"]:
        print(f" FAIL: status_breakdown mismatch")
        print(f"  Actual: {actual.get('status_breakdown')}")
        print(f"  Expected: {expected['status_breakdown']}")
        tests_passed = False
    else:
        print(f" PASS: status_breakdown = {actual.get('status_breakdown')}")
    
    # Test 5: total_response_size
    if actual.get("total_response_size_bytes") != expected["total_response_size_bytes"]:
        print(f" FAIL: total_response_size_bytes = {actual.get('total_response_size_bytes')}, expected {expected['total_response_size_bytes']}")
        tests_passed = False
    else:
        print(f" PASS: total_response_size_bytes = {actual.get('total_response_size_bytes')}")
    
    # Test 6: average_response_size
    if abs(actual.get("average_response_size_bytes", 0) - expected["average_response_size_bytes"]) >= 0.01:
        print(f" FAIL: average_response_size_bytes = {actual.get('average_response_size_bytes')}, expected {expected['average_response_size_bytes']}")
        tests_passed = False
    else:
        print(f" PASS: average_response_size_bytes = {actual.get('average_response_size_bytes')}")
    
    return tests_passed

if __name__ == "__main__":
    if run_tests():
        print("\n All tests passed!")
        sys.exit(0)
    else:
        print("\n Tests failed!")
        sys.exit(1)
EOF

# Write reward based on test outcome

if [ $? -eq 0 ]; then
    echo "1" > /logs/verifier/reward.txt
    echo "SUCCESS: All tests passed"
else
    echo "0" > /logs/verifier/reward.txt
    echo "FAILURE: Tests failed"
fi