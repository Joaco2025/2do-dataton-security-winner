# Contradictions report

Claim-level contradictions K1–K6 are in [`../docs/10_limitations.md`](../docs/10_limitations.md#c-contradictions-between-artifacts-full-list-recoverycontradictions_reportmd). This file adds cross-source checks.

| # | Type | Contradiction | Resolution |
|---|---|---|---|
| K1 | slide/pitch vs experiment | "porcentaje" vs absolute count (r 0.61/0.78/0.90) | numbers correct (absolute count, as labelled on the dashboard); "número" is the precise word |
| K2 | pitch vs dashboard | polynomial R² 0.934 quoted; dashboard shows OLS (R² 0.603) | branch A model quoted outside the dashboard |
| K3 | dashboard text vs matrix | "no relation with marginación" vs r = +0.321 (p = 0.006) | weak but significant |
| K4 | conversation vs pitch | no time for a formal Google Trends correlation chart vs GT section in pitch | presented as parallel trends; the jury's favourite link |
| K5 | pitch vs data | interest "×10" 2021→2023 | ≈ ×9.5 for 4 artists summed; falls in 2025 |
| K6 | prior audit vs exports | single AI pipeline assumed | two accounts / two branches |
| K7 | methodology description vs code | "tasa de delitos por 10k" read as an annual rate in charts/pitch | code computes a 6-year cumulative rate |
| K8 | variable label vs code | `pct_posbasica_18mas` = 18+ with post-basic ÷ **total** population | label misleading |
| K9 | ITAMA numbers | ITAMA 35 cases in sheet 06 vs 18 in master table | name-join loss ("Obregon", Puerto Peñasco) |
| K10 | detentions | 1,472 records vs 1,267 in master | name-join loss (accents) |
| K11 | dates | local file mtimes vs conversation UTC times | consistent after UTC−7 conversion (no conflict) |
| K12 | ML wording | "modelo de machine learning" vs 6-point regression | trend projections built with scikit-learn, presented as a scenario |
| K13 | outcome | win reported in chats; the official portal publishes the dashboard but states no placement | partly corroborated (M17) |
| K14 | title | "Del Aula a la Calle" (24 Apr dashboard image) vs published "Lo que se descubrió detrás del aumento del delito" | title changed with the final pitch framing |
