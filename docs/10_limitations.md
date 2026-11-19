# 10 · Limitations, analytical errors and contradictions

This section is deliberately frank. None of it diminishes what a team built in one week with public data.
It records what a reader must know before reusing any number.

## A. Data-engineering defects (VERIFIED by re-running the recovered code)

1. **Encoding error.** The Census ITER file is UTF-8, but the pipeline read it as latin-1 (`CL1-C025`, line `pd.read_csv(..., encoding="latin-1")`). 20 of 72 municipality names became mojibake (`BacadÃ©Huachi`). Names were fixed from `v2` onward, but the **joined values were never recomputed**.
2. **Name-based joins.** Detentions, ITAMA and the state crime file were joined on the municipality *name*. Results:
   - 205 of 1,472 detentions lost (e.g. San Luis Río Colorado, Puerto Peñasco, Bácum, Benito Juárez);
   - 17 of 35 ITAMA minors lost ("Obregon" was never mapped to Cajeme; Puerto Peñasco lost);
   - `total_delitos_sonora` and its crime-type columns are **0** for all 20 garbled municipalities, because of `fillna(0)`.
3. **Mixed reference periods.** Census 2020, SESNSP 2020–2025 cumulative, detentions and ITAMA Q1 2026 sit in one row per municipality.
4. **Definition defect.** `pct_posbasica_18mas` divides by total population instead of the 18+ population.
5. **Long-format SESNSP** keeps only non-zero months. Totals are correct, but monthly averages are not.

## B. Statistical limitations

6. **Size confounding.** The headline correlations (r = +0.90, +0.78, +0.61) use the *absolute* number of out-of-school 15–17-year-olds, which correlates **+0.990 with population**. They mostly restate "big municipalities have more of everything". Per capita, the share of out-of-school youth correlates **negatively** with the detention rate (r = −0.29, p = 0.012).
7. **One influential point.** r = +0.784 with interned minors rests on three non-zero municipalities. Without Hermosillo it drops to 0.138.
8. **Ecological fallacy.** Municipal correlations cannot support individual statements like *"si pisas una escuela, es menos probable que cometas un delito"*. Claude flagged this to the team on 21 Apr (CL1 msg 39).
9. **"Machine learning" on six points.** The OLS (R² 0.603) and polynomial (R² 0.934) models are curve fits to 6 annual values, with in-sample R², no validation and no intervals. The polynomial extrapolation (+735 % by 2035) is not a forecast. The team asked for these models partly because *"llama la atención decirle a los jueces 'hicimos un modelo de machine learning'"* (CL2 msg 14). Claude told them the uncertainty was "bastante" (CL1 msg 79).
10. **Google Trends.** Relative indices, low Sonora volume, 6 yearly means. The only computed correlation (r = −0.808) has the *opposite* sign to the narrative and was reinterpreted as "normalisation". The team itself concluded the argument "se rompió".
11. **No multiple-testing control.** Dozens of correlations were screened; significance labels were not adjusted.
12. **Registered crime ≠ crime.** SESNSP counts investigation files. Rising narcomenudeo may reflect enforcement priorities.

## C. Contradictions between artifacts (full list: `recovery/contradictions_report.md`)

| # | Contradiction | Sources |
|---|---|---|
| K1 | The final pitch says **"el porcentaje** de jóvenes de 15 a 17 años fuera de la escuela" has r = 0.61/0.78/0.90. Those coefficients belong to the **absolute count**; the percentage gives −0.10/−0.08 | pitch (CL1 msg 83) vs sheet `29_Matriz_Corr_5x4_PBI` |
| K2 | The pitch cites "Regresión polinomial de grado 2. R² de 0.934". `test.pbix` uses sheet 24 (OLS, R² 0.603); the polynomial exists only in branch A (`v5`), which `v6` does not contain. The **published** dashboard shows a "[Predicción]" chart with an x-axis to 2040 and a y-axis up to 8,000, with no R². Branch A reaches 43,708 cases by 2035, so the published chart is not that model [INFERENCE]; which model it uses is UNKNOWN (possibly a Power BI forecast) | pitch vs pbix layout (prior audit) vs published dashboard |
| K3 | The published dashboard text says *"La incidencia delictiva no no ha una relacion con la marginación…"* (sic), while its own matrix shows r = +0.32 (p = 0.006) | published dashboard (verified 2026-11-16) |
| K4 | "Todo el argumento de Google Trends se rompió" (00:17, 25 Apr) vs a Google Trends section in the final pitch and the reported jury praise for it | CL2 msg 64; CL1 msg 83; CL2 msg 68 |
| K5 | "Entre 2021 y 2023 ese interés se multiplicó por diez" is approximately right for the **sum of the four artists' rescaled indices** (23.2 → 219.6, ×9.5). But artist interest **fell** in 2025 (≈114) while narcomenudeo peaked (5,233), so the series do not move together | pitch vs sheet `31_GoogleTrends_Artistas_PBI` |
| K6 | The prior audit attributes all workbooks to "the AI sandbox" generally. This recovery shows two accounts and two branches | CL1 vs CL2 |
| K7 | The advisor-meeting framing ("donde hay más rezago educativo, también suben indicadores de criminalidad") came from a ChatGPT reading of the matrix that **ChatGPT itself later retracted**: the coefficients are negative | GPT-A `69e82fc2` msgs 3 vs 5–9; CL1 msg 38 |
| K8 | Jury reaction: "1 me felicitó, los otros no dijeron nada" (13:01) vs "puros elogios" (16:33, after the win) | GPT-A `69ec79d1` msg 14 vs CL2 msg 68 |

## D. Missing evidence that limits this reconstruction

- the exact bytes of the submitted `.pbix` (the local `test.pbix` was saved 48 min after the e-mail);
- the chats that produced `v2`–`v4`, and the ChatGPT conversations;
- any official result announcement, jury score sheet or feedback;
- the team roster and each member's contributions.

See `recovery/missing_artifacts.md`.
