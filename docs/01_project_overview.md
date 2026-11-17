# 01 · Project overview

**Project:** *Lo que se descubrió detrás del aumento del delito* (published title; working title during the event: *Del Aula a la Calle — El costo en seguridad de la deserción escolar urbana en Sonora*)
**Team:** Equipo 7, category **Seguridad**, *2do Datatón* of the Gobierno del Estado de Sonora (18–25 April 2026)
**Deliverable required by the organisers:** one Power BI dashboard (`.pbix`) plus a 5-minute presentation.

Evidence labels used in all documents: **[VERIFIED]** directly supported by an artifact ·
**[REPORTED]** stated by a participant, not independently verified · **[INFERENCE]** derived from
several pieces of evidence · **[HYPOTHESIS]** plausible, unconfirmed · **[UNKNOWN]**.

## What the project is

A municipal-level exploratory analysis of the official Seguridad question:
*"¿De qué manera los factores sociales influyen en la incidencia delictiva y distribución de los delitos en Sonora?"*
[VERIFIED, `Presentación.pdf` p.9]. The team combined 11 public sources (SESNSP crime incidence 2015–2025,
INEGI Census 2020, CONAPO marginación, CONEVAL poverty/social lag, ENOE informality, state detention and
juvenile-internment records, ACLED, Google Trends) into one 72-municipality master table, computed
Pearson correlations and simple trend projections, and presented the results in a single-page
Power BI dashboard.

## What it concluded (as presented)

The presented story [VERIFIED, final pitch text, `docs/11_final_pitch.md`]:

1. The "common narrative" (crime is driven by poverty or marginación) was **not** supported: r(marginación, crime rate per 10k) = +0.32.
2. The **number** of 15–17-year-olds out of school tracks detentions (r = +0.90) and interned minors (r = +0.78).
3. 77 % of interned minors (ITAMA, Q1 2026) were held for drug-dealing offences; mean age 16.
4. Narcomenudeo cases rose from 2,772 (2020) to 5,233 (2025) while interest in "narco-culture" artists rose on Google Trends.
5. Recommendation: scholarships and school re-entry programmes for 15–17-year-olds in large cities.

The recovery confirms most of these numbers can be regenerated exactly from raw data, and also shows that
points 2 and 4 are weaker than presented: see [`10_limitations.md`](10_limitations.md).

## How it was built

Almost all data engineering ran as Python code **inside Claude.ai conversations** (two accounts), which
returned Excel workbooks that the team loaded into Power BI. Only one script lived on the team's PC.
The 2026-11 recovery extracted that code from the account exports and showed that it reproduces the
historical workbooks (see [`07_software_architecture.md`](07_software_architecture.md)).

## Outcome

The team member reports that the team **won the Seguridad category** [REPORTED, two independent chat
messages on 25 and 26 Apr 2026]. The Sonora government publishes the team's dashboard on its official open-data portal (https://www.sonora.gob.mx/datos/equipo7dataton2, verified 2026-11-16), but that page states no placement. See
[`12_competition_outcome.md`](12_competition_outcome.md).

## Reading order

[02 competition](02_competition_context.md) → [03 original idea](03_original_idea.md) →
[04 evolution](04_project_evolution.md) → [05 final project](05_final_project.md) →
[06 methodology](06_methodology.md) → [09 findings](09_research_findings.md) →
[10 limitations](10_limitations.md) → [11 pitch](11_final_pitch.md) → [12 outcome](12_competition_outcome.md).
