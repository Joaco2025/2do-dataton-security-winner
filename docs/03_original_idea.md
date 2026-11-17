# 03 · The original idea

## A. Original concept (21 Apr 2026, 12:40 local) [VERIFIED, CL1 msg 0]

The first message to Claude (account A) laid out a complete plan, apparently drafted beforehand:

- **Objective:** analyse how *marginalidad* and social factors influence crime incidence in Sonora, **with emphasis on the participation of minors**.
- **Data planned:** índice de marginación por colonia (aggregated to municipality); crimes by municipality filtered by type; *(optional)* juvenile-offender data; *(optional)* education, poverty, unemployment.
- **Method planned:** (1) aggregate marginación to municipality, (2) classify low/medium/high, (3) filter relevant crimes, (4) integrate by municipality, (5) correlation analysis, then dashboard.
- **Implicit hypothesis:** more marginación → more crime, with minors as the vulnerable group [INFERENCE from the plan and from CL1 msg 34: *"una parte de nuestra narrativa original no entra, que es que a mayor marginalidad más delitos"*].
- **Intended beneficiary:** state decision-makers (the jury included public-security officials) [INFERENCE].
- **Expected technical solution:** Power BI dashboard fed by cleaned Excel tables; government colour palette (guinda/dorado) chosen in the first answer [VERIFIED, CL1 msg 1].

The team's working angle a few hours later [VERIFIED, CL1 msg 26]:
*"Cómo los factores sociales hacen que los menores de edad salgan de estudiar para dedicarse a actividades delictivas."*

## Why it was attractive

- It answered the official question directly and used exactly the datasets the organisers suggested (marginación por colonia/AGEB, incidencia municipal) [VERIFIED, briefing p.9].
- Minors-and-crime is a strong storytelling angle, and the team had already downloaded the ITAMA juvenile-internment file and the state detention file (19–21 Apr) [VERIFIED, file dates].

## Data available at the start [VERIFIED, CL1 msg 2 upload list]

`poblacion-itama-internamiento-1-trimestre-2026.xlsx`, `indice-de-marginacion-municipios-2020.xlsx`,
`DELITOS_DEL_2020_AL_2025.xlsx`, `Educacion_11.xlsx`, `sonora rezago educativo.pdf`,
`Personas Detenidas en el primer trimestre 2026.xlsx` + dictionary.

## First methodological decision

Asked whether to use the PDF's education indicators or go to primary sources, the team chose primary
sources; Claude pointed to the INEGI Census 2020 ITER file, which became the backbone of the education
variables [VERIFIED, CL1 msgs 4–7].

What happened to this idea is told in [04 · Project evolution](04_project_evolution.md).
