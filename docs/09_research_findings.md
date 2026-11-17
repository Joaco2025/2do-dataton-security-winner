# 09 · Research findings (results catalog)

Status legend: **REPRODUCED** = regenerated from raw data in the 2026-11 recovery with identical values ·
**STORED** = value present in historical files, generating code missing or not re-run ·
**RECOVERY** = new computation made during the recovery (not part of the historical project).
Full list: [`../recovery/experiment_catalog.csv`](../recovery/experiment_catalog.csv).

## Results the team used

| ID | Result | Value | n | Status | Interpretation (careful) |
|---|---|---|---|---|---|
| R1 | Pearson r, marginación index vs crime rate per 10k (2020–2025 cumulative) | +0.321, p = 0.006 | 72 | REPRODUCED | weak positive association; more marginalised municipalities do **not** have lower rates. The pitch rounded this to "débil" (fair) |
| R2 | r, % 15+ without basic education vs crime rate | −0.489, p < 0.001 | 72 | REPRODUCED | rural, less-educated municipalities register *fewer* crimes per capita; contradicts a simple "less education → more crime" story at municipal level |
| R3 | r, **absolute** 15–17 not attending vs total detentions | +0.898 | 72 | REPRODUCED | driven by size: the same variable correlates +0.990 with population |
| R4 | r, absolute 15–17 not attending vs detained minors | +0.609 | 72 | REPRODUCED | same caveat |
| R5 | r, absolute 15–17 not attending vs interned minors (ITAMA) | +0.784 | 72 (3 non-zero) | REPRODUCED | only Hermosillo (16), Navojoa (1), Naco (1) are non-zero after joins; **0.138 without Hermosillo** (RECOVERY) |
| R6 | ITAMA profile Q1 2026 | 77.1 % narcomenudeo/salud (27/35); mean age 16.1; 85.7 % male (30/35) | 35 | REPRODUCED | one quarter, one institution; descriptive only |
| R7 | Narcomenudeo SESNSP, Sonora | 2,772 (2020) → 5,233 (2025); share of total 8.9 % → 15.8 % | 6 yrs | REPRODUCED | registered cases; can reflect enforcement intensity as well as prevalence |
| R8 | OLS trend of narcomenudeo | +447 cases/yr, R² 0.603; 2028 ≈ 5,810 | 6 | code recovered | 6 points, no uncertainty; illustrative only |
| R9 | Polynomial (deg 2) narcomenudeo projection | R² 0.934; 2035 ≈ 43,708 | 6 | STORED (code version missing) | curve fit, not a validated forecast; not on the submitted dashboard |
| R10 | Guaymas: detained minors per 1,000 youths 15–17 | 2.81 (vs Hermosillo 0.26) | — | code recovered | the per-capita view contradicts the absolute-count view used in the pitch |
| R11 | Google Trends: index of corridos tumbados | 10.0 (2021) → 45.3 (2023) | weekly → yearly | REPRODUCED | relative search interest; Sonora volume low for many terms |
| R12 | r, "narco/violence" search index vs narcomenudeo (yearly) | −0.808 | 6 | REPRODUCED | spurious-risk: 6 yearly means, opposite sign to the narrative; the team itself said the GT argument "se rompió" |
| R13 | Informality Sonora (ENOE TIL1) | 44.4 % (2015) → 40.9 % (2024) → 43.4 % (2025) | 83 quarters | REPRODUCED | state level; not crossed with municipal data |

## Results added by the recovery (RECOVERY, `src/audit_checks.py`, `outputs/tables/audit_checks_v6.txt`)

| Check | Result |
|---|---|
| r(abs 15–17 not attending, population) | **+0.990** — the "absolute" variable is a population proxy |
| r(% 15–17 not attending, total detentions) | −0.102 (p = 0.40) |
| r(% 15–17 not attending, interned minors) | −0.084 (p = 0.48) |
| r(% 15–17 not attending, detentions per 10k) | **−0.293 (p = 0.012)** — per-capita, the sign reverses |
| r(abs not attending, interned minors) without Hermosillo | 0.138 |
| Spearman ρ(abs not attending, interned minors) | 0.254 |

## What can and cannot be concluded

- **Supported:** crime and detentions concentrate in the largest municipalities. Narcomenudeo registrations grew sharply in 2024–2025. Interned minors in Q1 2026 were mostly 15–17-year-old males held for drug offences. Marginación is at most weakly associated with crime rates.
- **Not supported by these data:** that school dropout *rates* are associated with crime (per-capita they are not, or are negatively associated); any causal or individual-level claim ("si pisas una escuela…"); that narco-culture interest relates to narcomenudeo; any forecast of future crime.
- **Plausible but untested [HYPOTHESIS]:** urban youth outside school are over-represented among juvenile offenders. Testing this needs individual-level data (ENASJUP microdata, CNPJE), which the team identified but did not obtain.
