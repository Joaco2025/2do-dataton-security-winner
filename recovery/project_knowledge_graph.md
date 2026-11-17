# Project knowledge graph

Conversation → code → data → result → dashboard → pitch. Tabular form: [`cross_source_index.csv`](cross_source_index.csv); claim-level evidence: [`evidence_traceability.csv`](evidence_traceability.csv).

```mermaid
flowchart TD
  Q["Official question (briefing p.9)"] --> C0["CL1 msg 0: marginación → crime, minors"]
  C0 --> D06["D06: marginación thesis abandoned"]
  C0 --> ITER["ITER Census 2020"] & SES["SESNSP 2015–2025"] & ITA["ITAMA Q1 2026 (restricted)"] & DET["Detentions Q1 2026"] & MAR["CONAPO 2020"]
  SES --> J["juntar_datos.py"] --> A1
  ITER & MAR & ITA & DET --> A1["CL1-C025/C035: sheet 01 master"]
  A1 --> R1["r marginación–tasa = 0.32"]
  A1 --> R3["r abs no-asiste–detenidos = 0.90 (population proxy)"]
  A1 --> R6["ITAMA 77% narcomenudeo"]
  ADV["Advisor + ChatGPT (missing)"] --> D07["'si pisas una escuela…'"]
  R1 --> D06
  A1 --> A2["CL2 enrichment 13–18"] --> A3["CL2 19–25: trends, OLS 24"]
  A3 --> R7["narcomenudeo 2,772 → 5,233"]
  GT["Google Trends exports"] --> B["CL1-C059 indices"] --> V6
  X["v2–v4 (code missing)"] --> V5A["v5 branch A: poly R² 0.934"] & V5B["v5(1): 5×4 matrix"]
  A3 --> X
  V5B --> V6["v6 canonical"]
  V6 --> PBI["test.pbix / test verdadero.pbix"]
  PBI --> P6["Final pitch P6"]
  V5A -. quoted .-> P6
  R1 & R3 & R6 & R7 --> P6
  P6 --> W["Win reported (CL2 msg 66)"]
```
