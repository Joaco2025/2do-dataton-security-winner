# Decision history

Local time (UTC−7). Source = conversation and message index (CL1 = account A main chat, CL2 = account B main chat).
"Impl." = implemented in recovered artifacts.

| ID | When | Decision | Previous → new approach | Reason given | Evidence | Consequence | Impl. |
|---|---|---|---|---|---|---|---|
| D00 | 19–21 Apr | Explore AGEB marginación heat map; advisor assigns marginación–crime correlation | — | suggested datasets; advisor | GPT-B `69e5c778`, `69e6df0e` |
| D01 | 21 Apr 12:40 | Study marginación + social factors → crime, emphasis on minors | — | official question; advisor's task; team plan drafted in ChatGPT 12:36 | CL1 0; GPT-B `69e6df0e` msg 4 | defined first datasets | yes, later revised |
| D02 | 21 Apr 13:56 | Build indicators from Census ITER rather than SEP PDF | PDF tables → microdata | rigour, granularity (Claude's recommendation, team agreed) | CL1 4–7 | ITER becomes backbone | yes |
| D03 | 21 Apr 16:39 | Merge SESNSP yearly files locally with Python | 11 uploads → 1 file | upload size | CL1 8–19 | `juntar_datos.py` | yes |
| D04 | 21 Apr 17:02 | Let Claude build the full pipeline and export a styled Excel for Power BI | — | "a darle" (speed) | CL1 22–23 | all later work in sandboxes | yes |
| D05 | 21 Apr 17:42 | Add % and absolute 15–17 not attending | only 12–14 + % attending | most detained minors are 15–17 (team insight) | CL1 30–33 | variable that drives the final story | yes |
| D06 | 21 Apr 17:52 | Abandon "más marginación → más delitos" | marginación thesis → search for another angle | absolute numbers mirror population; weak r | CL1 34–35 | Guaymas per-capita anomaly noticed | yes |
| D07 | 21 Apr 22:10 | Frame: "si pisas una escuela, es menos probable que cometas un delito" | — | advisor + ChatGPT reading of matrix (later corrected by ChatGPT, GPT-A `69e82fc2`) | CL1 38–39 | Claude warns about ecological fallacy | yes (pitch spirit) |
| D08 | 21 Apr 22:14 | Broaden to "por qué la gente en Sonora cae en actividades delictivas" | minors-only → general | advisor | CL1 40–41 | ENOE, CONEVAL, ACLED sought | partially |
| D09 | 21 Apr 23:01 | Use ENOE tabulated indicators, not microdata | 40–50 MB microdata → tabulados | size | CL1 42–47 | state-level only | yes |
| D10 | 22 Apr 13:25 | Heatmap of correlations + crime trends by type | — | advisor's first two tasks | CL1 50–51 | sheet 12 long format | yes |
| D11 | 22 Apr 18:49 | Add ACLED, CONEVAL, IRS, rezago habitacional, viviendas precarias; skip migration (not found) and drug-use survey (too old) | — | coverage of "social factors" | CL1 52; CL2 4 | sheets 13–18 | yes |
| D12 | 22 Apr 18:56 | Continue in a second Claude account | account A → B (+ text copy of chat) | first chat stopped [INFERENCE: usage limit] | CL1 53; CL2 0–4 | two parallel branches later | yes |
| D13 | 23 Apr 10:12 | Relational master table + r and p for all factors | r only → r + p | answer the official question | CL2 8–9 | heatmap 15×15 | yes |
| D14 | 23 Apr 19:07 | 8-chart dashboard plan (map, KPIs, scatter, ITAMA donut, trends, ACLED…) | — | event requirements | CL2 10–11 | sheets 19–23 | yes |
| D15 | 23 Apr 22:14 | Hypothesis: narco-culture popularity ↔ narcomenudeo | — | team intuition, explicitly "aún no lo hemos probado" | CL2 12 | Google Trends work | yes |
| D16 | 23 Apr 22:33 | Add regression projections "para decirle a los jueces 'hicimos un modelo de ML'" | — | jury appeal | CL2 14–15 | OLS sheet 24 | yes |
| D17 | 24 Apr 13:00–13:18 | Google Trends anchor ("corridos") rescaling; drop 14 noisy terms after ChatGPT critique | raw blocks → rescaled | comparability | CL1 56–59 | `google_trends_sonora_narco(1).xlsx` | yes |
| D18 | 24 Apr 13:31 | Thesis: education + cultural context + (maybe) marginación in urban context | — | synthesis | CL1 60 | final narrative | yes |
| D19 | 24 Apr 16:15–16:32 | One long-scroll page; keep useful charts inside the teammate's aesthetic design | 4-page prototype → 1 page | storytelling as a "recorrido" | CL2 26–31 | `test.pbix` layout | yes |
| D20 | 24 Apr 19:44 | 10-year projection, gradient by marginación, scholarships as solution | 3-yr OLS → 10-yr polynomial | advisor | CL1 66; CL2 36 | branch A (v5) | branch A only |
| D21 | 24 Apr 22:36 | Reduced 5×4 matrix with p-values; white background, coloured numbers | 13×13 → 5×4 | readability | CL2 38–55 | final dashboard matrix | yes |
| D22 | 24 Apr 23:09 | Use artists instead of songs for Google Trends | songs → artists | no time; artists recognisable | CL2 52–53 | sheet 31 | yes |
| D23 | 24 Apr 23:34 | Two side-by-side line charts | dual axis → two charts | Power BI secondary-axis limit | CL2 60–61 | dashboard | yes |
| D24 | 25 Apr 00:17 | Pitch only what is in the dashboard | — | time out; build the story from the dashboard | CL2 64 | pitch P1 | yes |
| D25 | 25 Apr 10:23–11:44 | Hero's journey + Steve Jobs tone; "nada de inferencias"; team skeleton "Lo que los datos sí nos dejaron ver" | sales pitch → discovery narrative | team preference | CL1 68–81 | final pitch P6 | yes |
