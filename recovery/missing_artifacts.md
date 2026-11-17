# Missing artifacts

Updated from the prior audit's list (M1–M16) with what the Claude exports recovered.

| # | Artifact | Status now | Impact | Where to look |
|---|---|---|---|---|
| M1 | `pipeline_seguridad_sonora.py` and the sandbox pipeline | **RECOVERED** (CL1-C002 draft; CL1-C025.. executed versions) | resolved | — |
| M2 | Scripts adding sheets 09–25, 29–33 | **RECOVERED** and re-run | resolved | — |
| M3 | Claude conversation after 22 Apr 13:25 | **RECOVERED** (CL1 complete; CL2) | resolved | — |
| M2b | Code that produced `sonora_maestro_v2`, `v3`, `v4` (sheets 26–28, accent fixes) | **MISSING** | high: breaks end-to-end reproducibility (v6 needs v4 as input) | the "otro Claude" chat referenced in CL2 msg 26 (a third chat or a teammate's account); teammates' AI accounts |
| M2c | Exact code version that produced branch A (`v5` sheets 29/29b/30, `proyeccion_10años_ML.csv`) | **MISSING** (export keeps only the final edited message branch [INFERENCE]) | low (not in final dashboard) | — |
| M4–M6 | ChatGPT conversations (matrix reading, Google Trends critique, dashboard rating 7.3, pitch skeleton, "riesgo delictivo" index) | **MISSING** (only pasted excerpts) | medium | ChatGPT data export of whoever used it |
| M7 | **Exact submitted `.pbix`** | MISSING (the organiser-published version is viewable online, see `evidence/`) | high (definitive deliverable) | sent-mail attachment; organisers |
| M8 | Power Query steps; tables `_catalogo_municipios`, `casos_delito_minicipio_x_año` | MISSING | medium | open `.pbix` in Power BI Desktop |
| M9 | Tool used to make `sonora_municipios.geojson` | MISSING | low | — |
| M15 | Team roster, teammates' files, any slides/speaker notes | MISSING | medium | teammates |
| M17 | **Official outcome evidence** (announcement, certificate, ranking, jury scores/feedback) | PARTLY FOUND: the organiser publishes the dashboard at https://www.sonora.gob.mx/datos/equipo7dataton2 (no placement shown); placement statement still MISSING; the team member reports a published Instagram photo with the prize (not located) | high for `12_competition_outcome.md` | organiser channels, e-mail, photos |
| M18 | Recording or notes of the actual 25 Apr presentation | MISSING | medium (P6 delivery unknown) | teammates |
| M19 | Long-format SESNSP conversion code | MISSING (rebuilt; output verified identical) | none | — |
| M20 | Uploaded attachments not in exports (e.g. example heatmap image, dashboard PDFs) | local copies exist for most | low | — |
