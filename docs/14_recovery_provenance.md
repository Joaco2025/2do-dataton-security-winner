# 14 · Recovery provenance

| Item | Value |
|---|---|
| Recovery session | `DRS-2026-11-16-01` (single agent, Claude Code) |
| Execution date | 2026-11-16 (local) |
| Machine | Windows 10 Pro 10.0.19045, host `DESKTOP-ITIVB56` (not the original project PC) |
| Input directory (read-only) | `<Documents>/2do dataton/` — 204 files, 239 MB |
| Output (this repository) | `<Documents>/Dataton_Reconstructed/` |
| Private evidence archive (not for publication) | `<Documents>/Dataton_Reconstructed_PRIVATE/` |
| Tools | Python 3.11.9 (isolated venv: pandas 2.3.3, openpyxl 3.1.5, scipy 1.17.1, scikit-learn 1.9.1, pypdf, pytest), Git 2.49 |

## Input composition

| Part | What it is | Origin |
|---|---|---|
| `dataton-seguridad-sonora/` | consolidated **copy** of the project files from the original PC (PC-01), made 2026-11-17 by an earlier audit; has its own MANIFEST/NOT_COPIED | PC-01 Downloads + Dataton folder |
| `DatatonRecovery_Audit/` | earlier read-only audit (inventory of 451 files, version analysis, experiment catalog, security audit) | PC-01 |
| `claude-1/`, `claude-2/` | Claude.ai account exports (conversations, artifacts, projects, memories, login metadata) for two accounts | new in this recovery |

The earlier audit had no AI exports and concluded that the pipeline code was missing. This recovery found
that code in the exports (148 fragments), re-ran it, and reproduced the historical workbooks.

## Method

1. Inventory with SHA-256 → `recovery/complete_inventory.csv` (public view: restricted names withheld).
2. Conversation extraction to text with message IDs and UTC timestamps (private archive), relevance classification → `recovery/conversation_catalog.csv`.
3. Tool-call extraction (bash/create_file/str_replace/fenced code) with provenance headers → `recovery/recovered_code_catalog.csv`.
4. Timestamp alignment: UTC message times → Hermosillo (UTC−7) and matched against file mtimes. Examples: CL1 msg 33 at 00:47Z ↔ `sonora_seguridad_powerbi(1).xlsx` 17:49 local; CL2 msg 51 at 06:12Z ↔ `sonora_maestro_v6.xlsx` 23:12–23:21 local.
5. Re-execution of recovered scripts in an isolated copy with sandbox paths re-mapped (inspected first: pandas/openpyxl only, no network), then cell-level comparison with the historical workbooks (`src/verify.py`).
6. Sensitivity checks (`src/audit_checks.py`).

## Preservation

No input file was modified, renamed, moved or deleted. The ITAMA file was copied only into the temporary
scratch area to re-run the pipeline. The pipeline reads sex/age/locality/offence, never names.

## Evidence labels

VERIFIED · REPORTED · INFERENCE · HYPOTHESIS · UNKNOWN — as defined in `01_project_overview.md`.
