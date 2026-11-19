# 05 · Final project definition

## C. Final concept

| Aspect | Final state | Evidence |
|---|---|---|
| Title | Published: **"Lo que se descubrió detrás del aumento del delito"**; earlier dashboard header (24 Apr 21:59): *"Del Aula a la Calle — El Costo en Seguridad de la Deserción Escolar Urbana en Sonora"* | official page https://www.sonora.gob.mx/datos/equipo7dataton2 [VERIFIED]; dashboard image (prior audit) [VERIFIED] |
| Problem addressed | Which social factors are associated with crime across Sonora's 72 municipalities, and why the common "poverty/marginación" explanation is insufficient | final pitch [VERIFIED] |
| Working research question | Is youth school non-attendance (15–17) in urban municipalities, more than marginación, associated with crime, especially drug-dealing offences and juvenile internment? [INFERENCE: synthesised from CL1 msg 60 and the pitch] | |
| Unit of analysis | municipality (n = 72), plus state-level annual series 2020–2025 | sheets 01, 21 |
| Datasets actually feeding the dashboard | SESNSP municipal incidence; INEGI Census 2020 ITER; CONAPO marginación 2020; ITAMA internment Q1 2026; state detentions Q1 2026; Google Trends (artists, post-deadline version) | `test.pbix` tables 01, 03, 06, 24, 29 (+31 in `test verdadero.pbix`) [VERIFIED, prior audit pbix layout] |
| Methods | Pearson correlations with p-values; descriptive ITAMA profile; OLS trend projection (n = 6 years); Google Trends anchor-rescaled indices | `06_methodology.md` |
| Value proposition | Redirect prevention from policing toward school retention: scholarships and re-entry programmes for 15–17-year-olds in large municipalities | final pitch |
| Format | single long-scroll Power BI page, guinda/dorado palette | CL2 msgs 28–31 |

## Original vs intermediate vs final

| Dimension | Original (21 Apr 12:40) | Intermediate (21 Apr night – 23 Apr) | Final (24–25 Apr) |
|---|---|---|---|
| Core hypothesis | more marginación → more crime | schooling matters: "si pisas una escuela…"; then "why people fall into crime" | education + cultural context + urban setting; marginación "may or may not" matter |
| Protagonist | marginación | 15–17 non-attendance (absolute counts) | out-of-school urban youth + narcomenudeo + narco-culture |
| Population focus | minors | minors → general population (advisor) | 15–17-year-olds in large cities |
| Crime focus | crimes filtered by type | all SESNSP crime, detentions, ITAMA | narcomenudeo (growth 2020→2025), juvenile internment |
| Data | marginación por colonia, crimes, optional juvenile data | + ITER, ENOE, ACLED, CONEVAL, IRS, housing | dashboard uses SESNSP, ITER, CONAPO, ITAMA, detentions, Google Trends |
| Method | aggregation, classification, correlation | 13×13 Pearson, per-capita checks | 5×4 Pearson with p, OLS/poly projection, Google Trends indices |
| Deliverable | dashboard | 4-page prototype dashboard | 1-page scroll dashboard + 5-min hero's-journey pitch |

## Transitions and why they happened

1. **Original → intermediate (21 Apr 17:52–22:15).** *What changed:* marginación demoted. *Why:* weak correlation (r = +0.32 with the rate) and the realisation that absolute indicators follow population (team's own comment, CL1 msg 34). The advisor also pushed toward schooling (CL1 msgs 38–41). *Several factors contributed:* data, the advisor, and a ChatGPT reading of the matrix.
2. **Intermediate → final (23 Apr 22:14 – 24 Apr 13:31).** *What changed:* narcomenudeo and narco-culture entered the story; "ML" projections were added. *Why:* SESNSP showed narcomenudeo almost doubling while total crime was flat (CL2 msg 13). ITAMA showed 77 % drug offences, and the team explicitly wanted a machine-learning element for the jury (CL2 msg 14).
3. **Final dashboard → final pitch (25 Apr).** *What changed:* the narco-culture argument moved from a planned correlation chart to the parallel trends on the dashboard, presented as coexistence ("no estamos diciendo que cause el delito"). The pitch also cited the 10-year projection scenario (R² 0.934).
