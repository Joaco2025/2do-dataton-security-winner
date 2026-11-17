# Unresolved questions and chronology issues

## Chronology

| # | Issue | Evidence | Current reading |
|---|---|---|---|
| U1 | Which bytes were submitted at 23:59 on 24 Apr? | e-mail names `test.pbix`; local `test.pbix` saved 00:47 | UNKNOWN |
| U2 | Which dashboard was shown on 25 Apr? | `test verdadero.pbix` 01:14; last PDF 01:22 attached to pitch request; the officially published version (verified 2026-11-16) contains the post-deadline Google Trends chart | the organiser holds and publishes the later `test verdadero`-type version [INFERENCE]: either a later file was accepted, or the team's submission was updated afterwards |
| U3 | Who produced v2 (23 Apr 15:37), `cons` (22:46), v3, v4? | no generating code in either export | a third chat or a teammate [INFERENCE] |
| U4 | Sheet 24 in `(3)` is the C029 wide version although C030 ran ~23 min later | file saved 01:04 | earlier download link reused [INFERENCE] |
| U5 | CL1 msgs 52/54 and CL2 msgs 4/8 carry the same prompt in both accounts, ~16 h apart | timestamps | parallel use of accounts; CL1 msg 53/55 replies were cut short |
| U6 | Exact time of the presentation and of the result announcement | — | afternoon of 25 Apr [INFERENCE from 16:32 report] |
| U7 | The prior audit's PC timestamps vs this export: are file mtimes local time on PC-01? | consistent ±10 min with UTC−7 message times | assumed yes |

## Decisions requiring human approval

1. **Publication**: approve (or edit) every file marked PUBLICATION_REQUIRES_REVIEW in `publication_classification.csv`.
2. ~~Licence~~ — **decided 2026-11-16:** MIT for code, CC BY 4.0 for documentation. The copyright line reads "Equipo 7 – 2do Datatón Sonora (Seguridad) contributors"; adjust it once team attribution (item 3) is settled.
3. **Team consent and attribution**: the material describes the team, the advisor's role and the pitch. Confirm all members agree and decide how to credit them.
4. **Outcome wording**: currently "reported winner, partly corroborated by official publication of the dashboard". It becomes verified with an organiser statement of the placement (M17).
5. **Final pitch text** (`docs/11_final_pitch.md`): publish verbatim with annotations, or summarise.
6. **ITAMA data owner**: whether to notify the publisher that the public workbook contains minors' names.
7. **Historical vs corrected analysis**: this repo publishes the historical pipeline with its defects documented. Should a corrected analysis (code joins, per-capita rates) be added as a separate, clearly-labelled module?
8. **Reproducibility input**: `sonora_maestro_v4.xlsx` is needed for stage C but cannot be published (it contains ITAMA rows). Accept "reproducible given v4", or try to recover the v2–v4 chats (M2b).

## Questions for the team

- Team members and roles? Who built the aesthetic dashboard?
- Was the pitch P6 delivered as written? By whom?
- Any jury feedback beyond "puros elogios"? Scores?
- Were the prizes delivered (AWS/Claude credits, tablet)?
- `Son_10-15.zip` was opened in this recovery: one workbook (`Concentrado municipal` 90×99, `Concentrado estatal` 45×97) that looks like CONEVAL municipal poverty for Sonora 2010–2015 [INFERENCE]. That fits the team's remark that municipal poverty "solo viene hasta 2015" (CL1 msg 6). It was superseded by the 2010–2020 CONEVAL file. Please confirm.
