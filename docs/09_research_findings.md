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
| R3 | r, **absolute** 15–17 not attending vs total detentions | +0.898 | 72 | REPRODUCED | the strongest link in the matrix; youth out of school and detentions concentrate in the same large cities |
| R4 | r, absolute 15–17 not attending vs detained minors | +0.609 | 72 | REPRODUCED | strong, significant (p < 0.001) |
| R5 | r, absolute 15–17 not attending vs interned minors (ITAMA) | +0.784 | 72 (3 non-zero) | REPRODUCED | Hermosillo leads both series; more ITAMA quarters would broaden the base (see `10_limitations.md` §B) |
| R6 | ITAMA profile Q1 2026 | 77.1 % narcomenudeo/salud (27/35); mean age 16.1; 85.7 % male (30/35) | 35 | REPRODUCED | one quarter, one institution; descriptive only |
| R7 | Narcomenudeo SESNSP, Sonora | 2,772 (2020) → 5,233 (2025); share of total 8.9 % → 15.8 % | 6 yrs | REPRODUCED | registered cases; can reflect enforcement intensity as well as prevalence |
| R8 | OLS trend of narcomenudeo | +447 cases/yr, R² 0.603; 2028 ≈ 5,810 | 6 | code recovered | 6 points, no uncertainty; illustrative only |
| R9 | Polynomial (deg 2) narcomenudeo projection | R² 0.934; 2035 ≈ 43,708 | 6 | STORED (code version missing) | trend scenario ("si la tendencia actual continúa") |
| R10 | Guaymas: detained minors per 1,000 youths 15–17 | 2.81 (vs Hermosillo 0.26) | — | code recovered | complements the volume view: a port city with a high rate per youth |
| R11 | Google Trends: index of corridos tumbados | 10.0 (2021) → 45.3 (2023) | weekly → yearly | REPRODUCED | relative search interest; Sonora volume low for many terms |
| R12 | r, "narco/violence" search index vs narcomenudeo (yearly) | −0.808 | 6 | REPRODUCED | early index (sheet 28, "narco/violencia" terms); superseded by the artist series shown on the dashboard |
| R13 | Informality Sonora (ENOE TIL1) | 44.4 % (2015) → 40.9 % (2024) → 43.4 % (2025) | 83 quarters | REPRODUCED | state level; not crossed with municipal data |

## Results added by the recovery (RECOVERY, `src/audit_checks.py`, `outputs/tables/audit_checks_v6.txt`)

| Check | Result |
|---|---|
| r(abs 15–17 not attending, population) | **+0.990**: the count is largest where most young people live |
| r(% 15–17 not attending, total detentions) | −0.102 (p = 0.40) |
| r(% 15–17 not attending, interned minors) | −0.084 (p = 0.48) |
| r(% 15–17 not attending, detentions per 10k) | −0.293 (p = 0.012): the share view behaves differently from the volume view (see `10_limitations.md` §B) |
| r(abs not attending, interned minors) without Hermosillo | 0.138 |
| Spearman ρ(abs not attending, interned minors) | 0.254 |

## What the data show

- Crime and detentions concentrate in the large municipalities, where the largest numbers of 15–17-year-olds out of school live (r = +0.90 with detentions).
- Marginación shows only a weak link to the crime rate (r = 0.32). The poverty-first narrative does not explain Sonora's crime map.
- Narcomenudeo grew sharply (2,772 → 5,233, 2020–2025) while other major crimes did not, and the young people interned for crime are mostly 15–17-year-old males held for drug offences.
- Interest in narco-culture artists rose almost tenfold (2021–2023) over the same period: the coexistence the team presented.

## Next questions

- At the individual level, are youths outside school over-represented among juvenile offenders? ENASJUP microdata and CNPJE adolescent statistics, which the team identified, can answer this.
- Per-capita and lagged time-series tests of the education and narco-culture links (see `10_limitations.md`).
