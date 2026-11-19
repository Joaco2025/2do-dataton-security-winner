# 00 · From idea to win

*Equipo 7 ("Imagine Team") · 2do Datatón Sonora 2026 · category Seguridad · **winner***

## The thesis

> **Put a teenager outside the school system together with a culture of narco-aspiration, and the chances of ending up in crime are high.**

The team tested the comfortable explanation, that crime follows poverty and marginación, against Sonora's data and
found it does not hold. Instead, three things line up in the same places and the same years:

1. **Youth out of school.** The municipalities with the most 15–17-year-olds out of school concentrate detentions (r = +0.90), detained minors (r = +0.61) and interned minors (r = +0.78).
2. **Who the young offenders are.** 77 % of the minors interned at ITAMA are there for drug dealing, average age 16, 86 % male, 91 % from large cities.
3. **The narco-culture boom.** Narcomenudeo cases rose from 2,772 (2020) to 5,233 (2025), the only major crime that grew steadily. Over the same years, search interest in Sonora for narco-culture artists (Peso Pluma, Junior H, Natanael Cano, Gabito Ballesteros) multiplied almost tenfold (2021→2023).

Marginación, by contrast, shows only a weak link to the crime rate (r = 0.32). The recommendation follows: invest in
**keeping 15–17-year-olds in school** (scholarships, school re-entry programmes) in the large urban municipalities.
That is prevention before policing.

## The story

**The idea (19–21 April).** The organisers suggested marginación by AGEB and municipal crime incidence. The first
night the team explored AGEB marginación maps. A teammate brought juvenile-internment (ITAMA) admissions, and the
advisor's first assignment was to correlate marginación with crime. The starting hypothesis was the obvious one:
*more marginación, more crime, with minors as the most exposed group.*

**The pipeline (21 April).** In one afternoon the team merged eleven years of SESNSP crime files (79,772 rows). They
rebuilt education indicators from the 2020 Census microdata instead of a PDF, and built a 72-municipality master table
joining census, marginación, crime, detentions and ITAMA data.

**The turn (21 April, evening).** The first correlations surprised them: marginación barely moved with crime. Once
15–17-year-olds out of school were added, a different signal appeared. The team realised the story was not
"poor places", it was "young people outside school". The advisor pushed the same way: *"si pisas una escuela, es menos
probable que cometas un delito."*

**Widening the lens (22–23 April).** They added labour informality (ENOE), poverty and social lag (CONEVAL), housing
lag, and geolocated violence (ACLED). They then built a relational table with p-values for every social factor
against every crime indicator. The pattern held: education and youth variables mattered; poverty indices did not tell the story.

**The narcomenudeo clue (23 April, night).** Total crime was flat, but narcomenudeo nearly doubled, and the ITAMA
profile pointed the same way. The team proposed that the rise of narco-culture was part of the picture. They measured
it with Google Trends: nine export blocks rescaled with an anchor term, with noisy terms discarded. They added trend
projections of narcomenudeo to show where the curve is heading.

**The dashboard (24 April).** Two dashboards, one analytical and one designed for presentation, were merged into a
single scrolling page in the state government's colours. A reduced 5×4 correlation matrix with p-values showed at a
glance what relates to crime and what does not. A side-by-side chart set narcomenudeo against narco-artist search interest.
Submitted by e-mail at 23:59 on 24 April.

**The pitch (25 April, 00:30–12:00).** Time was up and no more analysis could be added, so the team turned the
dashboard into a story. They wrote a five-minute hero's journey, *"Lo que los datos sí nos dejaron ver"*, with each
line following the order in which the charts appear. They insisted it state only what the data showed, and read it from
cards on a phone.

**The win (25 April).** The team presented in the morning. By the afternoon they knew they had **won the Seguridad
category**. The judges responded most to the link between narcomenudeo and narco-culture. Prizes: a Samsung Galaxy Tab S10
Lite for each member, plus USD 5,000 in AWS credits and USD 200 in Claude credits. The state government
publishes the team's dashboard on its open-data portal: <https://www.sonora.gob.mx/datos/equipo7dataton2>.

## Timeline (Hermosillo time)

| When | Milestone |
|---|---|
| Sat 18 Apr | Datatón opens; category Seguridad: *¿De qué manera los factores sociales influyen en la incidencia delictiva…?* |
| Sun 19 Apr, 22:25 | First datasets downloaded (state crimes 2020–2025, CONAPO marginación, ITAMA) |
| Sun 19 Apr, 23:28 | AGEB marginación heat-map idea; ENASJUP considered to match the ITAMA data |
| Mon 20 Apr, 19:22 | Social factors listed against the official question |
| Tue 21 Apr, 11:20 | Advisor's first task: correlate marginación with crime |
| Tue 21 Apr, 12:40 | Analysis plan launched: marginación and social factors vs crime, focus on minors |
| Tue 21 Apr, 14:14 | Decision to rebuild education indicators from Census 2020 microdata (ITER) |
| Tue 21 Apr, 16:47 | SESNSP 2015–2025 merged (79,772 rows) and converted to monthly long format |
| Tue 21 Apr, 17:06 | Master table v1: 72 municipalities × 43 variables, first correlation matrix |
| Tue 21 Apr, 17:47 | 15–17-year-olds out of school added (the variable that carried the final story) |
| Tue 21 Apr, 17:52 | **Turning point:** the marginación hypothesis does not hold; per-capita check finds the Guaymas anomaly |
| Tue 21 Apr, 22:10 | Advisor meeting: framing "si pisas una escuela…" and why people turn to crime |
| Tue 21 Apr, 23:06 | ENOE labour informality for Sonora (2005–2025) added |
| Wed 22 Apr, 13:25 | Correlation heatmap and crime-trend tasks for Power BI |
| Wed 22 Apr, 19:05–19:23 | New datasets integrated: ACLED, CONEVAL poverty, social lag index, housing lag, precarious housing |
| Thu 23 Apr, 10:14 | Relational table (72 × 63) with Pearson r and p-values for all factors |
| Thu 23 Apr, 19:10 | Dashboard plan (map, KPIs, scatter, ITAMA profile, trends); ITAMA and trend sheets built |
| Thu 23 Apr, 22:14 | **Second turning point:** narcomenudeo + narco-culture hypothesis; trend projections |
| Fri 24 Apr, 12:36–13:20 | Google Trends: 9 blocks downloaded and rescaled; noisy terms discarded |
| Fri 24 Apr, 13:31 | Thesis set: education + cultural context + urban setting |
| Fri 24 Apr, 16:15 | Analytical and design dashboards merged into one scrolling page |
| Fri 24 Apr, 19:50 | 10-year narcomenudeo projection (advisor's request) |
| Fri 24 Apr, 22:38 | Reduced 5×4 correlation matrix with p-values |
| Fri 24 Apr, 23:12 | Google Trends artists vs narcomenudeo charts |
| **Fri 24 Apr, 23:59** | **Dashboard submitted** ("Entrega de análisis – Equipo 7 (Datatón Seguridad)") |
| Sat 25 Apr, 00:33–11:59 | Pitch written: hero's journey, "Lo que los datos sí nos dejaron ver", cards in dashboard order |
| Sat 25 Apr, morning | Five-minute presentation to the Seguridad jury |
| **Sat 25 Apr, afternoon** | **Equipo 7 wins the Seguridad category**; tablets handed to each member at the ceremony |
| After the event | The state government publishes the dashboard on its open-data portal |

Full event-level timeline with sources: [`../recovery/master_timeline.csv`](../recovery/master_timeline.csv).

## Datasets

### Used in the analysis

| Dataset | Publisher | What it contributed |
|---|---|---|
| Incidencia delictiva municipal (fuero común) 2015–2025 | SESNSP, via datos.sonora.gob.mx | crime counts and rates per municipality; narcomenudeo, robo and violencia familiar trends |
| Delitos por municipio 2020–2025 | Gobierno del Estado de Sonora | crime types by municipality and year |
| Censo de Población y Vivienda 2020 – ITER Sonora | INEGI | population, school attendance by age (incl. 15–17), schooling, illiteracy |
| Índice de marginación municipal 2020 | CONAPO, via datos.sonora.gob.mx | marginación index and grade |
| Personas detenidas, Q1 2026 | Gobierno del Estado de Sonora | detentions by municipality, age (minors) |
| Población en internamiento, Q1 2026 | ITAMA Sonora | profile of interned minors (offence, age, sex, locality) |
| Google Trends, Sonora 2021–2026 (9 export blocks) | Google | narco-culture search interest: artists and genre terms |
| Encuesta Nacional de Ocupación y Empleo – indicadores estratégicos e informalidad | INEGI | labour informality in Sonora 2005–2025 |
| Pobreza municipal 2010–2020 | CONEVAL | poverty, extreme poverty, social deprivations |
| Índice de Rezago Social 2020 | CONEVAL | social lag by municipality |
| Rezago habitacional 2015/2020; viviendas precarias | SIODS (federal) | housing conditions |
| Aggregated weekly conflict data, Latin America | ACLED | geolocated violence in Sonora 2017–2026 |
| Marco Geoestadístico (municipal boundaries) | INEGI | map of Sonora |

### Explored or downloaded for context

Índice de marginación urbana por AGEB and por colonia 2020 (datos.sonora.gob.mx) · ENAPE 2021 · ENASJUP 2022 ·
Educacion_11 tabulado · SEP education atlas for Sonora · RNID 2026 · CONEVAL Índice de Rezago Social by locality.

Download links: [`../data/README.md`](../data/README.md).

## Read more

[Methodology](06_methodology.md) · [Findings](09_research_findings.md) · [Final pitch](11_final_pitch.md) ·
[Outcome](12_competition_outcome.md) · [Notes for a second edition](10_limitations.md)
