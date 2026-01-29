# Evidence Index – Week 3: Top 3 Risk Validation

**Project:** Restful Booker – QA Doctoral Activity  
**Week:** 3 (Risk-Based Testing)  
**Team:** Grupo 4  
**Date:** 2026-01-28

---

## Overview

This directory contains evidence collected during Week 3 validation of the Top 3 identified risks. Each test scenario (Q5, Q6, Q7) is represented by:

1. **Executable script** – Located in `scripts/` (reproducible)
2. **Evidence log file** – Test execution output and oracle validation
3. **RUNLOG.md** – Master document linking all evidence to risks and scenarios

---

## Evidence Files

### Top 3 Risk Validation

#### R001 – Pérdida de datos (Reliability, Score: 20)
**Status:** ✅ PASS

| File | Purpose | Result |
|------|---------|--------|
| `persistency_test_20260128_143022.log` | Q5 test output: Create booking → Restart → Verify | All fields persisted correctly |
| `scripts/test_persistency.sh` | Reproducible test script | Exit code: 0 (PASS) |
| `RUNLOG.md#test-1-q5--persistency-r001` | Detailed analysis and oracle validation | Oracle PASS: Data integrity confirmed |

**Quick Link:** [See full test report](RUNLOG.md#test-1-q5--persistency-r001)

---

#### R003 – Degradación de performance (Performance, Score: 16)
**Status:** ✅ PASS

| File | Purpose | Result |
|------|---------|--------|
| `concurrent_load_test_20260128_143145.log` | Q6 test output: 10 concurrent POST requests | All 10 succeeded, unique IDs, latency ≤2s |
| `scripts/test_concurrent_load.sh` | Reproducible test script | Exit code: 0 (PASS) |
| `RUNLOG.md#test-2-q6--concurrent-load-r003` | Detailed analysis and oracle validation | Oracle PASS: Performance acceptable |

**Quick Link:** [See full test report](RUNLOG.md#test-2-q6--concurrent-load-r003)

---

#### R002 – Acceso no autorizado (Security, Score: 15)
**Status:** ✅ PASS

| File | Purpose | Result |
|------|---------|--------|
| `authentication_failure_20260128_143245.log` | Q7 test output: PUT without token → HTTP 403 | Request rejected, data unmodified |
| `scripts/test_auth_failure.sh` | Reproducible test script | Exit code: 0 (PASS) |
| `RUNLOG.md#test-3-q7--authentication-failure-r002` | Detailed analysis and oracle validation | Oracle PASS: Authorization enforced |

**Quick Link:** [See full test report](RUNLOG.md#test-3-q7--authentication-failure-r002)

---

## File Descriptions

### RUNLOG.md
**Master evidence document** containing:
- Executive summary of all three tests
- Timestamp and script path for each test
- Detailed step-by-step execution flow
- Oracle conditions and validation results
- Risk mitigation assessment
- Traceability matrix (Risk → Scenario → Evidence)
- Reproducibility checklist

**Use Case:** Reference for peer review, documentation of evidence chain

### persistency_test_20260128_143022.log
**Test Q5 – Reliability (R001)**
- **Input:** Create booking with ID 105
- **Process:** Restart SUT (simulated)
- **Output:** GET booking before/after restart
- **Oracle:** Fields identical before and after
- **Result:** ✅ PASS

### concurrent_load_test_20260128_143145.log
**Test Q6 – Performance (R003)**
- **Input:** 10 concurrent POST requests with distinct data
- **Process:** Measure latency and HTTP codes for each request
- **Output:** Per-request metrics and summary statistics
- **Oracle:** All 200s, unique IDs, latency ≤2000ms
- **Result:** ✅ PASS

### authentication_failure_20260128_143245.log
**Test Q7 – Security (R002)**
- **Input:** PUT request without authentication token
- **Process:** Attempt to update booking without credentials
- **Output:** Response code (403), data before/after attack
- **Oracle:** HTTP 401/403, data unmodified
- **Result:** ✅ PASS

---

## Test Scripts

All scripts are located in `scripts/` and are executable:

### scripts/test_persistency.sh
```bash
bash scripts/test_persistency.sh
```
- Creates a booking
- Logs pre-restart state
- Simulates SUT restart
- Logs post-restart state
- Compares fields for equality
- Output: `evidence/week3/persistency_test_*.log`

### scripts/test_concurrent_load.sh
```bash
bash scripts/test_concurrent_load.sh 10
```
- Launches N concurrent POST requests
- Captures HTTP code, ID, and latency for each
- Validates all IDs are unique
- Checks latency threshold (≤2000ms)
- Output: `evidence/week3/concurrent_load_test_*.log`

### scripts/test_auth_failure.sh
```bash
bash scripts/test_auth_failure.sh
```
- Creates a booking (baseline)
- Attempts PUT without token (attack)
- Verifies response is 401/403
- Confirms data was not modified
- Output: `evidence/week3/authentication_failure_*.log`

---

## Traceability

### Risk Matrix → Evidence Mapping

```
risk/risk_matrix.csv
├─ R001 (Reliability, Score 20)
│  └─ evidence_ref: evidence/week3/persistency_test_20260128_143022.log
│  └─ scenario_ref: quality/scenarios.md#Q5
│  └─ status: TOP3 ✅ PASS
│
├─ R002 (Security, Score 15)
│  └─ evidence_ref: evidence/week3/authentication_failure_20260128_143245.log
│  └─ scenario_ref: quality/scenarios.md#Q7
│  └─ status: TOP3 ✅ PASS
│
└─ R003 (Performance, Score 16)
   └─ evidence_ref: evidence/week3/concurrent_load_test_20260128_143145.log
   └─ scenario_ref: quality/scenarios.md#Q6
   └─ status: TOP3 ✅ PASS
```

### Scenario References

- **Q5:** [quality/scenarios.md#Q5](../quality/scenarios.md#Q5) – Persistency test
- **Q6:** [quality/scenarios.md#Q6](../quality/scenarios.md#Q6) – Concurrent load test
- **Q7:** [quality/scenarios.md#Q7](../quality/scenarios.md#Q7) – Authentication failure test

---

## Oracle Validation Summary

| Test | Oracle Condition | Validation | Result |
|------|------------------|-----------|--------|
| Q5 | PRE data == POST data | All fields compared | ✅ PASS |
| Q6 | All HTTP 200 + unique IDs + latency ≤2s | 10/10 success, 10 unique IDs, max 156ms | ✅ PASS |
| Q7 | HTTP 401/403 + data unmodified | 403 received, all fields unchanged | ✅ PASS |

---

## Reproducibility

All evidence is reproducible:

1. ✅ Scripts are idempotent (can be run multiple times)
2. ✅ SUT state is controlled (local Docker)
3. ✅ Timestamps recorded for all operations
4. ✅ Commands are explicit (URLs, parameters logged)
5. ✅ No external secrets or dependencies
6. ✅ Logs are human-readable and machine-parseable

**To regenerate evidence:**
```bash
bash scripts/test_persistency.sh
bash scripts/test_concurrent_load.sh 10
bash scripts/test_auth_failure.sh
```

---

## Risk Mitigation Status

| Risk | Original Score | Mitigation | Residual Risk | Status |
|------|---|---|---|---|
| R001 (Data Loss) | 20 | Persistency validated | Corruption under repeated restarts | 🟡 Mitigated |
| R003 (Performance) | 16 | Concurrent load ≤2s | Degradation at >100 req/s | 🟡 Mitigated |
| R002 (Unauthorized) | 15 | Auth check enforced | Advanced attacks (IDOR, session) | 🟡 Mitigated |

**Legend:**
- 🟢 Eliminated
- 🟡 Mitigated (residual risk remains)
- 🔴 Not addressed

---

## References

- **Risk Matrix:** [risk/risk_matrix.csv](../risk/risk_matrix.csv)
- **Test Strategy:** [risk/test_strategy.md](../risk/test_strategy.md)
- **Quality Scenarios:** [quality/scenarios.md](../quality/scenarios.md)
- **Top 3 Mapping:** [risk/top3_scenario_mapping.md](../risk/top3_scenario_mapping.md)
- **Week 3 Memo:** [memos/week3_memo.md](../memos/week3_memo.md) *(pending)*

---

**Last Updated:** 2026-01-28 14:35:00  
**Evidence Status:** Complete for all Top 3 risks  
**Next Step:** Peer review and commit to version control
