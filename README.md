# Lo que se descubrió detrás del aumento del delito

**🏆 Winner, Seguridad category — 2do Datatón Sonora 2026 · Equipo 7 ("Imagine Team")**

Live dashboard, published by the Gobierno del Estado de Sonora: **<https://www.sonora.gob.mx/datos/equipo7dataton2>**

> **Put a teenager outside the school system together with a culture of narco-aspiration, and the chances of ending up in crime are high.**

## The challenge

The 2nd Datatón of the Sonora state government (18–25 April 2026) gave the **Seguridad** teams one week, a Power BI
dashboard and a five-minute pitch to answer:

> *¿De qué manera los factores sociales influyen en la incidencia delictiva y distribución de los delitos en Sonora?*

## What we found

The common story says crime follows poverty and marginación. We tested it across Sonora's 72 municipalities, and it
does not hold: marginación shows only a weak link to the crime rate (r = 0.32). Three other things line up instead:

| | Evidence |
|---|---|
| **Youth out of school** | Municipalities with the most 15–17-year-olds out of school concentrate detentions (r = +0.90), detained minors (r = +0.61) and interned minors (r = +0.78) |
| **Young offenders** | 77 % of interned minors (ITAMA, Q1 2026) are held for drug dealing; average age 16; 86 % male; 91 % from large cities |
| **Narco-culture** | Narcomenudeo cases rose from 2,772 (2020) to 5,233 (2025), the only major crime that grew steadily. Over the same years, Google Trends interest in Sonora for narco-culture artists (Peso Pluma, Junior H, Natanael Cano, Gabito Ballesteros) multiplied almost tenfold (2021→2023) |

**Recommendation:** prevention before policing. Scholarships and school re-entry programmes for 15–17-year-olds in
Hermosillo, Cajeme, Guaymas and Navojoa.

## From idea to win

The project started as *"more marginación, more crime"*, the advisor's first assignment. Within a day the data
pointed elsewhere, and the team followed it: first to youth outside school, then to the rise of narcomenudeo and
narco-culture. Over the week the team integrated 13 public datasets into a 72-municipality master table and
built a one-page story dashboard. They submitted at 23:59 on Friday, wrote the pitch overnight, presented on Saturday
morning, and **won the category** that afternoon.

**Read the full story, timeline and dataset list → [`docs/00_story.md`](docs/00_story.md)**

## The dashboard

A single scrolling Power BI page in the state government's colours:
- a municipality map with KPI cards;
- marginación vs crime rate;
- crime trends by type;
- the ITAMA profile of interned minors;
- a 5×4 correlation matrix (education and marginación factors × crime indicators, with p-values);
- a narcomenudeo projection;
- Google Trends interest in narco-culture artists.

## Data

SESNSP municipal crime incidence 2015–2025 · state crime records 2020–2025 · INEGI Census 2020 (ITER) · CONAPO
marginación 2020 · state detentions and ITAMA juvenile internment Q1 2026 · Google Trends · ENOE · CONEVAL poverty and
social lag · housing lag (SIODS) · ACLED · INEGI municipal boundaries. No data are redistributed here; download links are in
[`data/README.md`](data/README.md).

## Methods

Pearson correlations with p-values, per-capita ratios, linear and polynomial trend projections, and anchor-rescaled
Google Trends indices. All processing was written in Python (pandas, openpyxl, scikit-learn) with AI assistants
(Claude, ChatGPT) and fed to Power BI. → [`docs/06_methodology.md`](docs/06_methodology.md)

## Reproduce it

The original scripts were recovered from the team's AI conversations and replay on the raw data. They regenerate the
final analysis workbook, sheet for sheet.

```bash
python -m venv .venv && .venv/Scripts/activate      # Windows; use bin/activate elsewhere
pip install -r requirements.txt
pytest -q tests
python src/merge_sesnsp.py "data/raw/seguridad_incidencia/Incidencia delictiva municipal/datos" data/interim
python src/reproduce.py --raw data/raw --work build [--itama <path>] [--v4 <historical sonora_maestro_v4.xlsx>]
python src/verify.py --work build --reference <folder with historical workbooks>     # optional
```

Details: [`recovery/reproducibility_audit.md`](recovery/reproducibility_audit.md).
Ideas for a second edition (stronger per-capita measures, better joins, longer series): [`docs/10_limitations.md`](docs/10_limitations.md).

## Repository map

| Path | Content |
|---|---|
| `docs/00_story.md` | the story, timeline and datasets |
| `docs/01–14` | competition, evolution, methodology, findings, pitch, outcome, provenance |
| `src/historical/` | original analysis scripts, recovered verbatim from the AI conversations |
| `src/legacy/` | the team's local scripts |
| `src/*.py` | reproduction utilities (runner, verifier, SESNSP merge, checks) |
| `tests/` | tests for the utilities |
| `recovery/` | inventories, catalogs, timeline, evidence trail |

Licence: code under **MIT** ([`LICENSE`](LICENSE)); documentation under **CC BY 4.0** ([`LICENSE-docs.md`](LICENSE-docs.md)).
Third-party data are covered by neither.
