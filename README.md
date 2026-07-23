"# Fix-task-broken" 
k063@DESKTOP-TBTHSJH:/mnt/c/project-dynamo$ harbor run -p log-report -a oracle
  1/1 Mean: 0.000 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 0:00:14 0:00:00

adhoc • oracle
┏━━━━━━━━┳━━━━━━━━━━━━┳━━━━━━━┓
┃ Trials ┃ Exceptions ┃  Mean ┃
┡━━━━━━━━╇━━━━━━━━━━━━╇━━━━━━━┩
│      0 │          1 │ 0.000 │
└────────┴────────────┴───────┘

┏━━━━━━━━━━━━━━┳━━━━━━━┓
┃ Exception    ┃ Count ┃
┡━━━━━━━━━━━━━━╇━━━━━━━┩
│ RuntimeError │     1 │
└──────────────┴───────┘

Job Info
Total runtime: 14s
Results written to jobs/2026-07-23__12-25-26/result.json
Inspect results by running `harbor view jobs`
Share results by running `harbor upload jobs/2026-07-23__12-25-26`

dk063@DESKTOP-TBTHSJH:/mnt/c/project-dynamo$ harbor run -p log-report --agent nop
  1/1 Mean: 0.000 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 0:00:09 0:00:00

adhoc • nop
┏━━━━━━━━┳━━━━━━━━━━━━┳━━━━━━━┓
┃ Trials ┃ Exceptions ┃  Mean ┃
┡━━━━━━━━╇━━━━━━━━━━━━╇━━━━━━━┩
│      0 │          1 │ 0.000 │
└────────┴────────────┴───────┘

┏━━━━━━━━━━━━━━┳━━━━━━━┓
┃ Exception    ┃ Count ┃
┡━━━━━━━━━━━━━━╇━━━━━━━┩
│ RuntimeError │     1 │
└──────────────┴───────┘

Job Info
Total runtime: 9s
Results written to jobs/2026-07-23__12-36-46/result.json
Inspect results by running `harbor view jobs`
Share results by running `harbor upload jobs/2026-07-23__12-36-46`
