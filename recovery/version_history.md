# Version history of the master workbook and dashboards

Times are local (UTC−7). "Producer" = recovered artifact that generated the version (see `recovered_code_catalog.csv`).
Sheet-level lineage computed by the prior audit (`DatatonRecovery_Audit/evidence/workbook_sheet_lineage.csv`) and
confirmed by re-generation in this recovery.

| Version (file) | Saved | Sheets | Producer | Account | Notes |
|---|---|---|---|---|---|
| `sonora_seguridad_powerbi(1).xlsx` | 21 Apr 17:49 | 8 | CL1-C025 + C035 | A | master 72×45; mojibake names |
| `matriz de correlaciones.xlsx` | 21 Apr 19:16 | 8 | = (1) re-saved | — | duplicate content |
| `sonora_seguridad_powerbi.xlsx` | 22 Apr 13:43 | 12 | + CL1-C048, C050 | A | ENOE 09–11, heatmap 12 |
| `nuevos_datasets_sonora.xlsx` | 22 Apr 19:05 | 7 | CL2-C010 | B | ACLED without state columns |
| `sonora_seguridad_powerbi__2026-04-22_1905.xlsx` | 22 Apr 19:05 | 18 | CL2-C011..C013 | B | + 13–18 |
| `nuevos_datasets_sonora(1).xlsx` | 22 Apr 19:23 | 7 | CL2-C015 | B | ACLED with region/país/estado |
| `sonora_maestro_v2.xlsx` | 23 Apr 15:37 | 22 | **unrecovered** | ? | accents fixed in 01; 19–22 |
| `cons.xlsx` | 23 Apr 22:46 | 18 | unrecovered | ? | restart from 18-sheet base [INFERENCE] |
| `sonora_seguridad_powerbi(3).xlsx` | 24 Apr 01:04 | 28 | CL2-C025, C029 (+ accent-fixed 01) | B | 19–25 |
| `sonora_maestro_v3.xlsx` | 24 Apr 11:51 | 30 | **unrecovered** | ? | 24 rebuilt (long), 26–27 |
| `sonora_maestro_v4.xlsx` | 24 Apr 13:57 | 31 | **unrecovered** (CL1-C062/C064 attempts failed) | ? | + 28 Google Trends vs narco |
| `sonora_maestro_v5.xlsx` — **branch A** | 24 Apr 19:53 | 34 | CL1 msg 67 (code version not in export) | A | + 29 ML 10 años, 29b, 30 scatter 10k |
| `sonora_maestro_v5(1).xlsx` — **branch B** | 24 Apr 22:44 | 33 | CL2-C043 | B | + 29 Matriz 5×4, 30 instructions |
| **`sonora_maestro_v6.xlsx`** | 24 Apr 23:21 | 36 | CL2-C047 | B | + 31–33 Google Trends artists; **canonical** (all tables used by `test.pbix`) |

## Dashboards (from prior audit, `.pbix` layout analysis)

| File | Saved | Layout | Status |
|---|---|---|---|
| `Dashboard_Dataton.pbix` (in `.rar`) | 24 Apr 01:04 | 4 pages, 13 visuals | early prototype, abandoned |
| `test.pbix` | 25 Apr 00:47 | 1 page, 62 visuals, tables 01/03/06/24/29 | **same name as submitted attachment**; saved 48 min after the e-mail |
| `test verdadero.pbix` | 25 Apr 01:14 | 1 page, 66 visuals, + table 31 | post-deadline; probably what was shown on 25 Apr [HYPOTHESIS] |
| `test(1).pbix` | 26 Apr 02:30 | same as `test verdadero` | unknown relationship |
| **Published version** on https://www.sonora.gob.mx/datos/equipo7dataton2 | captured 2026-11-16 | 1 page; includes Google Trends artists chart (table 31) and a projection to 2040; header "Lo que se descubrió detrás del aumento del delito" | layout matches `test verdadero.pbix` / `test(1).pbix` (table 31 present), **not** `test.pbix` [INFERENCE from visuals]; byte identity unknowable |

PDF exports: `test.pdf` (24 Apr 16:00) → `test 9.14.pdf` → `test final.pdf` → `test final final.pdf` →
`test super final final ya.pdf` (01:13) → `test final fina finalisimo ya es la ultima.pdf` (25 Apr 01:22). All have different hashes.
The pitch request at 25 Apr 10:23 attaches the last one, which is therefore the best candidate for the version presented [INFERENCE].

## Local script versions

`juntar_datos.py`: Claude's version (CL1 msg 19, 16:45 local, UTF-8-sig). The team then took it to ChatGPT (GPT-B `69e80c4c`,
16:46–16:47), and **ChatGPT's answer is the local file verbatim** (latin-1 fallback, stdout reconfigure, `A�o` fix, utf-8-sig output).
ChatGPT also wrote the long-format conversion (msg 7, 16:49), which reproduces `sesnsp_largo_2015_2025.csv` exactly.
Files: `src/legacy/` and `src/historical/GPT-B-69e80c4c_msg007_sesnsp_largo.py`.
