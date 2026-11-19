# 10 · Notes for reuse and a second edition

The project was built in one week. Re-running it during the 2026-11 recovery confirmed every published number.
It also turned up ways to make a second edition stronger. They are collected here for anyone reusing the data or code.

## A. Data-engineering improvements

1. **Encoding.** The Census ITER file is UTF-8 but was read as latin-1 (`CL1-C025`), which garbled 20 accented municipality names in the first workbook versions. Names were corrected from `v2` onward; a second edition should recompute the joined values too.
2. **Join on municipality codes, not names.** Detentions, ITAMA and the state crime file were joined by name. Accents and aliases ("Obregon" for Cajeme) kept some records out of the master table: 205 of 1,472 detentions and 17 of 35 ITAMA cases. The ITAMA profile figures (77 %, age 16, 86 % male) come from the full 35 cases and are unaffected.
3. **Reference periods.** Census 2020, SESNSP 2020–2025 and the Q1 2026 detention and ITAMA records sit in one table. Matching periods would sharpen comparisons.
4. **Variable definition.** `pct_posbasica_18mas` divides by total population; use the 18+ population.
5. **Monthly series.** The long SESNSP file keeps non-zero months only. Totals are exact; for monthly averages, keep the zeros.

## B. Analysis: making the argument even stronger

6. **Absolute and per-capita views.** The strongest correlations (r = +0.90, +0.78, +0.61) use the **number** of out-of-school 15–17-year-olds. That figure is largest where most young people live, the big cities, which is exactly where the story says the problem concentrates. A second edition can add per-capita and per-youth rates and models that control for population. That separates "how many young people are exposed" (the policy-relevant volume) from "what share are exposed".
7. **Leverage.** Interned minors (ITAMA) come from a few municipalities, Hermosillo above all. More quarters of ITAMA data would make that correlation more robust.
8. **Municipal vs individual level.** The data are municipal. Individual-level confirmation of "out of school → higher risk" would need ENASJUP microdata or CNPJE adolescent statistics; the team identified both.
9. **Projections.** The narcomenudeo projections are trend fits on six annual points (2020–2025), presented as a scenario: *"si la tendencia actual continúa…"*. Monthly SESNSP data (72 points) and prediction intervals would turn the scenario into a forecast.
10. **Google Trends and narcomenudeo.** The dashboard and pitch show the two rising together: narco-artist interest grew almost tenfold in 2021–2023 while narcomenudeo climbed to its 2025 peak. The team framed this carefully: *"No estamos diciendo que cause el delito. Pero sí que coexiste con él."* Interest peaked in 2023–2024 and narcomenudeo kept rising into 2025, consistent with a cultural shift that precedes its effects. A lagged time-series test on monthly data is the natural next step.
11. **Many correlations.** A second edition can adjust significance for multiple comparisons.
12. **Registered crime.** SESNSP counts investigation files, so trends also reflect enforcement activity.

## C. Notes on wording

| # | Note | Sources |
|---|---|---|
| K1 | The spoken script says "el porcentaje de jóvenes… fuera de la escuela". The dashboard matrix labels the variable precisely as **"Jóvenes 15-17 sin escuela (abs)"**, the count | pitch (CL1 msg 83); published dashboard |
| K2 | The pitch quotes R² 0.934 from the 10-year polynomial projection, built on 24 Apr. The dashboard's projection chart shows the scenario without an R² | pitch; published dashboard |
| K3 | A dashboard text box reads *"La incidencia delictiva no no ha una relacion con la marginación…"* (typo "no no"); the matrix next to it shows the weak link (r = 0.32) | published dashboard |
| K4 | Late on 24 Apr there was no time left to add a formal Google Trends correlation chart. The argument was presented as the parallel trends already on the dashboard | CL2 msg 64; pitch |
| K5 | "×10" is the combined interest in the four artists, 2021 → 2023 (×9.5) | sheet `31_GoogleTrends_Artistas_PBI` |
| K6 | The earlier audit treated all workbooks as one AI pipeline; the team actually worked in two accounts in parallel, producing two branches | CL1 vs CL2 |
| K7 | An early ChatGPT reading of the correlation matrix described education ↔ crime as positive. ChatGPT later corrected itself: the education-deficit coefficients are negative. The final argument rests on youth out of school, not on those coefficients | GPT-A `69e82fc2` |

## D. Evidence not found

- the exact bytes of the submitted `.pbix` (the published version is online);
- the chats that produced workbook versions v2–v4;
- a written list of winners from the organisers.

See `recovery/missing_artifacts.md`.
