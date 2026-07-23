import json
from pathlib import Path

REPORT_PATH = Path("/app/report.json")
LOG_PATH = Path("/app/data/access.log")

def parse_log():
    """Parse access log to compute expected values."""
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
        "average_response_size_bytes": avg
    }

def test_criterion_1_report_exists():
    """Criterion 1: Report is valid JSON at /app/report.json"""
    assert REPORT_PATH.exists(), "Report file not found"
    with open(REPORT_PATH) as f:
        data = json.load(f)
    assert isinstance(data, dict)

def test_criterion_2_total_requests():
    """Criterion 2: total_requests matches number of log lines"""
    expected = parse_log()
    with open(REPORT_PATH) as f:
        actual = json.load(f)
    assert actual["total_requests"] == expected["total_requests"]

def test_criterion_3_path_counts_all_paths():
    """Criterion 3: path_counts contains all unique paths"""
    expected = parse_log()
    with open(REPORT_PATH) as f:
        actual = json.load(f)
    assert set(actual["path_counts"].keys()) == set(expected["path_counts"].keys())

def test_criterion_4_path_counts_correct():
    """Criterion 4: Each path has correct count"""
    expected = parse_log()
    with open(REPORT_PATH) as f:
        actual = json.load(f)
    for path, count in expected["path_counts"].items():
        assert actual["path_counts"].get(path) == count

def test_criterion_5_status_breakdown():
    """Criterion 5: status_breakdown correctly categorizes all status codes"""
    expected = parse_log()
    with open(REPORT_PATH) as f:
        actual = json.load(f)
    assert actual["status_breakdown"] == expected["status_breakdown"]

def test_criterion_6_total_response_size():
    """Criterion 6: total_response_size_bytes equals sum of all response sizes"""
    expected = parse_log()
    with open(REPORT_PATH) as f:
        actual = json.load(f)
    assert actual["total_response_size_bytes"] == expected["total_response_size_bytes"]

def test_criterion_7_average_response_size():
    """Criterion 7: average_response_size_bytes = total / count (with decimal precision)"""
    expected = parse_log()
    with open(REPORT_PATH) as f:
        actual = json.load(f)
    assert abs(actual["average_response_size_bytes"] - expected["average_response_size_bytes"]) < 0.01