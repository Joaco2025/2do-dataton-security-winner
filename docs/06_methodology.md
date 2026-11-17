# 06 · Methodology (as executed in April 2026)

This document describes what the recovered code **actually does**, not what the presentation said. Artifact IDs
(e.g. `CL1-C025`) refer to `recovery/recovered_code_catalog.csv` and to the verbatim files in `src/historical/`.

## Processing pipeline (supported by recovered code)

```
Raw data (data/README.md)
 │
 ├─ SESNSP 2015–2025 yearly CSV ──► juntar_datos.py (local, E01) ──► sesnsp_2015_2025.csv (wide, 79,772×18)
 │                                   └─► long format, non-zero months only (code not recovered; rebuilt in src/merge_sesnsp.py) ──► sesnsp_largo (56,312×8)
 │
 ├─ Stage A1 · Claude account A · 21–22 Apr ───────────────────────────────────────────────
 │   CL1-C025  ITER (LOC==0) + CONAPO + DELITOS + SESNSP + detenidos + ITAMA ─► 01_Maestro_Municipal (72×43), 02–08
 │   CL1-C035  + pct/abs_NO_asiste_15a17 (72×45)
 │   CL1-C048  + ENOE informality (09–11)
 │   CL1-C050  + 07 correlations (13 vars) and 12 heatmap long format (169 pairs)
 │
 ├─ Stage A2 · Claude account B · 22 Apr ──────────────────────────────────────────────────
 │   CL2-C010/C015  ACLED (Sonora), CONEVAL pobreza, IRS, rezago habitacional, viviendas precarias ─► nuevos_datasets_sonora.xlsx
 │   CL2-C011..C013 same tables appended to the master as 13–18 (sheet names trimmed to 31 chars)
 │
 ├─ Stage A3 · account B · 23 Apr ──────────────────────────────────────────────────────────
 │   CL2-C019..C021 relational table (72×63) + Pearson r and p for 15 factors × crime indicators
 │   CL2-C025  19 relational, 20/20b/20c ITAMA, 21/21b trends, 22 ACLED, 23 KPIs
 │   CL2-C029/C030 24 OLS projection (long format), 25 scatter regression
 │
 ├─ [GAP] v2 → v3 → v4 (sheets 26–28, accent fixes): generating code NOT recovered
 │
 ├─ Stage B · account A · 24 Apr ── CL1-C059 Google Trends anchor method ─► google_trends_sonora_narco(1).xlsx
 │
 ├─ Branch A · account A · 24 Apr 19:50 ── 10-year polynomial projection ─► sonora_maestro_v5.xlsx (exact code version NOT recovered)
 └─ Stage C · account B · 24 Apr 22:38–23:12
     CL2-C043  29 Matriz 5×4 (r, p) + CSV ─► sonora_maestro_v5(1).xlsx
     CL2-C047  31–33 Google Trends artists/weekly ─► sonora_maestro_v6.xlsx  (canonical, feeds the dashboard)
                  │
                  ▼
           Power BI (test.pbix / test verdadero.pbix): Power Query + DAX measures (CL2 msgs 35, 59) → 1-page dashboard
```

## Key variable definitions (from code)

| Variable | Definition | Code |
|---|---|---|
| `poblacion_total` | ITER `POBTOT`, Census 2020 | CL1-C025 |
| `pct_no_asiste_12a14` | `P12A14NOA / P_12A14 × 100` | CL1-C025 |
| `pct_asiste_15a17` | `P15A17A / P_15A17 × 100` | CL1-C025 |
| `abs_NO_asiste_15a17` | `P_15A17 − P15A17A` (count of 15–17 not attending) | CL1-C035 |
| `pct_NO_asiste_15a17` | `abs_NO_asiste_15a17 / P_15A17 × 100` | CL1-C035 |
| `pct_analfabeta_15mas` | `P15YM_AN / P_15YMAS × 100` | CL1-C025 |
| `pct_posbasica_18mas` | `P18YM_PB / POBTOT × 100` — **denominator is total population, not 18+** | CL1-C025 |
| `indice_marginacion`, `grado_marginacion`, `pct_sin_educ_basica`, `pct_ingreso_bajo_2sm` | CONAPO 2020 columns by position | CL1-C025 |
| `total_delitos_sesnsp` | sum of SESNSP cases **2020–2025** by municipality code | CL1-C025 |
| `tasa_delitos_10k` | `total_delitos_sesnsp / poblacion_total × 10,000` — a **6-year cumulative** rate on 2020 population | CL1-C025 |
| `total_detenidos`, `menores_detenidos` | state detentions Q1 2026, joined **by municipality name** | CL1-C025 |
| `menores_internados` | ITAMA Q1 2026 count, municipality parsed from `LOCALIDAD DEL DELITO`, joined **by name** | CL1-C025 |
| `categoria_delito` (ITAMA) | keyword rules: narco/salud → *Narcomenudeo/Salud*, robo, homicidio/feminicidio, portación/arma, lesión | CL1-C025 |

## Statistical methods

| Method | Where | Notes |
|---|---|---|
| Pearson correlation (`DataFrame.corr()`) | sheets 07, 12, 19; heatmap | no p-values in 07/12 |
| Pearson r with p-values (`scipy.stats.pearsonr`) | CL2-C020/C021, 5×4 matrix (CL2-C043) | n = 72; significance labels at 0.05/0.01 |
| Per-capita ratios | CL1-C036 | minors detained per 1,000 youths 15–17 |
| OLS linear trend | sheet 24 (CL2-C029/C030) | x = year, y = annual cases, **n = 6** (2020–2025); projection to 2028 |
| Polynomial regression deg 2 (`sklearn`) | branch A, v5 sheets 29/29b | n = 6; in-sample R² only; extrapolated to 2035 |
| Google Trends anchor rescaling | CL1-C059 | each 5-term block includes "corridos"; blocks rescaled to the anchor's mean in the reference block; terms with high zero share discarded (14 terms) |
| Composite indices | CL1-C059 | yearly means of rescaled terms by category (corridos tumbados, narco/violencia, musical control) |

No train/test split, cross-validation, confidence intervals, multiple-testing correction, or multivariate
model controlling for population was used anywhere [VERIFIED by code review].

## Power BI layer

Measures recovered as text (DAX) in CL2 msgs 35, 48–59 (e.g. `Edad Promedio Menor = AVERAGE('06_ITAMA_Menores'[edad])`).
Power Query steps and two tables found only inside the `.pbix` (`_catalogo_municipios`,
`casos_delito_minicipio_x_año`) were **not recovered** [VERIFIED absence, prior audit M8].
