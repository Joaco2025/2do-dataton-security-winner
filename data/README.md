# Data

**No data files are committed to this repository.** Every dataset must be downloaded from its original
publisher (redistribution terms differ per source, and one source contains personal data of minors).
The full profile of every file and sheet that existed during the project is in
[`../recovery/dataset_catalog.csv`](../recovery/dataset_catalog.csv); sources and licences are in
[`../docs/08_data_sources.md`](../docs/08_data_sources.md).

## Expected local layout (used by `src/reproduce.py --raw data/raw`)

```
data/
├── raw/
│   ├── censo_iter_2020/iter_26_cpv2020/conjunto_de_datos/conjunto_de_datos_iter_26CSV20.csv   INEGI Censo 2020 ITER, Sonora
│   ├── contexto_socioeconomico/
│   │   ├── indice-de-marginacion-municipios-2020.xlsx         CONAPO, via datos.sonora.gob.mx
│   │   ├── Concentrado_indicadores_de_pobreza_2020.xlsx       CONEVAL pobreza municipal 2010-2020
│   │   ├── irs_municipal_2020.csv                             CONEVAL Índice de Rezago Social 2020
│   │   ├── 02_rezago_habitacional_mun_2015.csv                rezago habitacional (SIODS)
│   │   ├── 03_rezago_habitacional_mun_2020.csv
│   │   ├── 01_viviendas_precarias_SIODS.csv
│   │   └── enoe_indicadores_estrategicos_2005_2026_mensual.xlsx   INEGI ENOE
│   ├── enoe_informalidad/
│   │   ├── Tasas de informalidad por trimestre/Tasas_Infor_enti-1.xlsx
│   │   └── Tasas de informalidad por área geográfica/{Nacional/Nacional_Tasas_Inf_Resu-1.xlsx, Áreas urbanas/Areas_Tasas_Inf_Resu-1.xlsx}
│   ├── seguridad_incidencia/
│   │   ├── Incidencia delictiva municipal/datos/2015.csv … 2025.csv   SESNSP via datos.sonora.gob.mx
│   │   ├── DELITOS_DEL_2020_AL_2025.xlsx                       Gobierno de Sonora (portal page not recorded)
│   │   ├── Personas Detenidas/datos/Personas Detenidas en el primer trimestre 2026.xlsx
│   │   └── Latin-America-the-Caribbean_aggregated_data_up_to_week_of-2026-04-11.xlsx   ACLED (account + terms required)
│   ├── google_trends/multiTimeline.csv, multiTimeline(1).csv … (8).csv   Google Trends exports, Sonora, weekly
│   └── restricted/poblacion-itama-internamiento-1-trimestre-2026.xlsx   ITAMA — CONTAINS MINORS' NAMES
└── interim/sesnsp_largo_2015_2025.csv      produced by: python src/merge_sesnsp.py <…/datos> data/interim
```

## Download links (as recorded by the team in `LINKS UTILIZADOS.txt`, 24 Apr 2026)

| Dataset | URL |
|---|---|
| SESNSP incidencia delictiva municipal | https://datos.sonora.gob.mx/dataset/Incidencia%20delictiva%20municipal |
| Personas detenidas | https://datos.sonora.gob.mx/dataset/Personas%20Detenidas |
| Marginación urbana por colonia / AGEB | https://datos.sonora.gob.mx/dataset/Indice%20de%20marginaci%C3%B3n%20urbana%20por%20colonia |
| INEGI Censo 2020 (ITER) | https://www.inegi.org.mx/programas/ccpv/2020/#datos_abiertos |
| INEGI ENOE tabulados | https://inegi.org.mx/programas/enoe/15ymas/#tabulados |
| INEGI ENAPE 2021 (downloaded, not used) | https://inegi.org.mx/programas/enape/2021/#tabulados |
| INEGI ENASJUP 2022 (downloaded, not used) | https://www.inegi.org.mx/programas/enasjup/2022/#microdatos |
| INEGI Marco Geoestadístico | https://www.inegi.org.mx/temas/mg/#descargas |
| CONEVAL pobreza municipal 2010–2020 | https://www.coneval.org.mx/Medicion/Paginas/Pobreza-municipio-2010-2020.aspx |
| Rezago social | https://www.datos.gob.mx/dataset/rezago_social |
| ACLED aggregated LatAm | https://acleddata.com/aggregated/aggregated-data-latin-america-caribbean |
| Google Trends | https://trends.google.com/trends/ |
| SEP Atlas Sonora (PDF, consulted) | https://planeacion.sep.gob.mx/Doc/Atlas_estados/sonora.pdf |

Not recorded by the team (UNKNOWN exact page): `DELITOS_DEL_2020_AL_2025.xlsx`, the CONAPO municipal
marginación file, the ITAMA workbook, the SIODS housing files, the Google Trends query terms
(they are recoverable from the CSV headers; see `docs/06_methodology.md`).

## The ITAMA file

`poblacion-itama-internamiento-1-trimestre-2026.xlsx` (as downloaded in April 2026) contains **full names
of minors** in historical sheets. Keep it outside any repository. The pipeline reads only sex, age,
locality and offence. Derived tables with ITAMA rows (sheet `06_ITAMA_Menores`, 35 rows of
sex/age/municipality/offence) are quasi-identifying for minors in small municipalities and are also
excluded from publication.
