# Lo que se descubrió detrás del aumento del delito — Datatón Seguridad Sonora 2026 (Equipo 7)

*Working title during the event: "Del Aula a la Calle". Published dashboard: <https://www.sonora.gob.mx/datos/equipo7dataton2>*

> Evidence-based reconstruction of a one-week datathon project: what was built, how, why it changed,
> what was presented and what happened. **Status: partially reconstructed, ready for human review — not yet published.**

## 1. What this is

The 2nd Datatón of the Sonora state government (18–25 April 2026) asked teams in the **Seguridad** category to
answer, with a Power BI dashboard and a 5-minute pitch:

> *¿De qué manera los factores sociales influyen en la incidencia delictiva y distribución de los delitos en Sonora?*

Equipo 7 built a 72-municipality master table from 11 public sources and argued that crime in Sonora is better
associated with **young people outside school in large cities** than with poverty or marginación.

## 2. Why it matters

Prevention policy often targets the poorest areas. The team asked whether the data support that, using the
datasets the organisers proposed plus census, poverty, labour, juvenile-justice and search-trend data.

## 3. The original idea and how it evolved

It began as *"marginación → delincuencia, with a focus on minors"*. Within hours the team saw that absolute figures
merely tracked population and that marginación correlated only weakly (r = 0.32) with crime rates, so they
abandoned that thesis. An advisor steered them toward schooling. Narcomenudeo's near-doubling (2020→2025) and
the profile of interned minors (77 % drug offences, mean age 16) then brought in a "narco-culture" angle measured
with Google Trends, plus trend projections added partly to impress the jury. At midnight before presenting, the
team wrote that the Google Trends argument "se rompió". The final pitch kept it as coexistence, not cause.
→ [`docs/03`](docs/03_original_idea.md), [`docs/04`](docs/04_project_evolution.md), [`docs/05`](docs/05_final_project.md)

## 4. What the final solution does

A single scrolling Power BI page fed by `sonora_maestro_v6.xlsx` (36 sheets): municipal map, KPI cards, a 5×4
correlation matrix with p-values, ITAMA profile, narcomenudeo trend with an OLS projection, and Google Trends
artist charts. The state government publishes the dashboard on its open-data site (https://www.sonora.gob.mx/datos/equipo7dataton2). The `.pbix` binaries are not in this repository (they embed personal data).

## 5. Data sources

SESNSP municipal incidence 2015–2025 · INEGI Census 2020 (ITER) · CONAPO marginación 2020 · state detentions and
ITAMA juvenile internment Q1 2026 · ENOE · CONEVAL poverty and social lag · housing lag (SIODS) · ACLED · Google Trends.
No data are redistributed here. See [`data/README.md`](data/README.md) and [`docs/08`](docs/08_data_sources.md).

## 6. Methods

Pearson correlations (with p-values in later stages), per-capita ratios, OLS and degree-2 polynomial trends on six
annual points, and anchor-rescaled Google Trends indices. All computation ran as Python inside two Claude.ai
accounts. → [`docs/06`](docs/06_methodology.md), [`docs/07`](docs/07_software_architecture.md)

## 7. Findings

The values reproduce exactly. Robust: crime and detentions concentrate in large municipalities; narcomenudeo
registrations rose from 2,772 to 5,233. Not robust: the headline r = 0.90/0.78 use *absolute* counts of out-of-school
youth (r = 0.99 with population). Per capita the association turns negative (r = −0.29). The 0.78 depends on
Hermosillo alone. → [`docs/09`](docs/09_research_findings.md)

## 8. Limitations

Name-based joins with an encoding error dropped 14 % of detentions and half the ITAMA cases. The tables mix
reference periods. The "ML" is fitted on six data points. The pitch made claims that went beyond the matrix.
→ [`docs/10`](docs/10_limitations.md)

## 9. What was presented

A hero's-journey script, *"Lo que los datos sí nos dejaron ver"*, finalised at 11:59 on 25 April (verbatim, with
a claim check, in [`docs/11`](docs/11_final_pitch.md)). How exactly it was delivered is not recorded.

## 10. What happened

A team member reported on the same afternoon that **Equipo 7 won the Seguridad category** (prizes reported: AWS and
Claude credits, a tablet). The state government later published the team's dashboard on its official open-data site under "Equipo 7 Dataton 2". That page does not state a placement, so the win itself remains reported, not officially confirmed. The team member also reports that a photo of the team with the prize is on Instagram. → [`docs/12`](docs/12_competition_outcome.md)

## 11. Reproduce

```bash
python -m venv .venv && .venv/Scripts/activate      # Windows; use bin/activate elsewhere
pip install -r requirements.txt
pytest -q tests
python src/merge_sesnsp.py "data/raw/seguridad_incidencia/Incidencia delictiva municipal/datos" data/interim
python src/reproduce.py --raw data/raw --work build [--itama <path>] [--v4 <historical sonora_maestro_v4.xlsx>]
python src/verify.py --work build --reference <folder with historical workbooks>     # optional
python src/audit_checks.py build/C/out/sonora_maestro_v6.xlsx                       # sensitivity checks
```

`reproduce.py` replays the **original** recovered scripts (`src/historical/`) with re-mapped paths. It does not
re-implement them. The final stage needs the historical intermediate `sonora_maestro_v4.xlsx`, whose generating code was
not recovered. Results: [`recovery/reproducibility_audit.md`](recovery/reproducibility_audit.md).

## Repository map

| Path | Content |
|---|---|
| `docs/01–14` | project story, methods, findings, pitch, outcome, provenance |
| `src/historical/` | verbatim scripts recovered from the AI conversations (with provenance headers) |
| `src/legacy/` | the team's local script (paths redacted) and Claude's version of it |
| `src/*.py` | **reconstructed** utilities (2026-11): runner, verifier, SESNSP merge, audit checks |
| `tests/` | tests for the reconstructed utilities |
| `outputs/tables/` | verification log and audit-check output |
| `recovery/` | inventories, catalogs, timeline, traceability, security audit (index in `recovery/README.md`) |

Licence: code in `src/` and `tests/` under **MIT** ([`LICENSE`](LICENSE)); documentation under **CC BY 4.0** ([`LICENSE-docs.md`](LICENSE-docs.md)). Third-party data are covered by neither. Do not publish before reading [`recovery/security_audit.md`](recovery/security_audit.md).
