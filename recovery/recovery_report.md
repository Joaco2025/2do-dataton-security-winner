# Recovery completion report

Session `DRS-2026-11-16-01` · single agent · 2026-11-16 · provenance in [`../docs/14_recovery_provenance.md`](../docs/14_recovery_provenance.md)

## Counts

| Item | Count |
|---|---|
| Input files inventoried (SHA-256) | 204 (239 MB) + 910 archive members listed |
| Exact duplicate groups in input | 1 (the earlier consolidation had removed the rest); 36 probable modified versions |
| AI conversations in exports | 11 (2 accounts): 3 project-relevant (HIGH 2, MEDIUM 1), 1 LOW, 7 unrelated |
| Missing AI conversations identified | 5 (4 ChatGPT, ≥1 Claude/teammate) |
| Code fragments recovered | 148 (71 account A, 71 account B, 6 parallel chat) |
| Historical scripts re-executed | 17 (+ local merge script) |
| Historical files reproduced exactly | 9 (incl. canonical `sonora_maestro_v6.xlsx`, 36/36 sheets) |
| Historical files partially reproduced | 1 (`(3)`: 25/28 sheets) |
| Not reproducible | v2, v3, v4, branch-A v5, `.pbix` |
| Dataset/sheet profiles | 580 |
| Experiments catalogued | 14 historical + 1 recovery + 1 abandoned + proposed set |
| Decisions documented | 25 |
| Project pivots | 3 major (TP1 marginación abandoned, TP4 narco-culture + "ML", TP6 GT argument breaks) + 3 supporting turning points |
| Pitch versions recovered | 7 (P0–P6), final written script preserved |
| Timeline events | 36 (exact local times for 30) |
| Contradictions | 13 |
| Tests | 5 passed |

## Status by question

| Question | Answer | Evidence grade |
|---|---|---|
| What was built | 72-municipality analytical workbook → 1-page Power BI dashboard | VERIFIED |
| How it was built | Python in Claude sandboxes (2 accounts), Excel hand-offs, Power BI | VERIFIED |
| Original vs final concept | marginación → crime (minors) ⇒ urban out-of-school youth + narcomenudeo + narco-culture | VERIFIED |
| Are the numbers right | values reproduce exactly; improvement notes in docs/10 | VERIFIED |
| Final pitch | text recovered verbatim; delivery unknown | VERIFIED / UNKNOWN |
| Outcome | category winner | REPORTED; dashboard officially published by the organiser (VERIFIED), placement not stated |
| Why it won | not documented; interpretation provided separately | INFERENCE |

## Security

No secrets anywhere. Critical personal data (minors' names) exists in the input and is excluded. All personal and
career material from the AI accounts is kept private. See [`security_audit.md`](security_audit.md).

## Overall readiness

**PARTIALLY RECONSTRUCTED — READY FOR HUMAN REVIEW.**

The technical and historical reconstruction is complete for everything the evidence covers. Three gaps keep it
from being fully reconstructed: (1) the v2–v4 generation steps, (2) the exact submitted dashboard, and (3) an official
statement of the placement (the dashboard itself is officially published). Publication is blocked only by human decisions (team consent, review of the documents marked for
review). The licence is chosen: MIT for code, CC BY 4.0 for docs. There is no technical blocker.
