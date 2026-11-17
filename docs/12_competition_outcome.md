# 12 · Competition outcome — and why it may have won

## 1. What happened

| Fact | Status | Evidence |
|---|---|---|
| The dashboard was e-mailed before the deadline (24 Apr 23:59, attachment `test.pbix`) | VERIFIED | e-mail screenshot (prior audit; restricted, contains personal data) |
| The team presented on 25 Apr (5 min, 3 judges) | INFERENCE | official format + pitch written 11:59 that morning + later report |
| **Equipo 7 won the Seguridad category** | **REPORTED** | team member, CL2 msg 66 (25 Apr 16:32 local): *"ganamos nuestra categoría de seguridad, se hizo"*; repeated independently in account A, CL1 msg 84 (26 Apr 23:55): *"ganamos!!!"*; account B memory profile (Oct 2026) |
| A photo of the team with the prize is published on Instagram | REPORTED (team member, 2026-11-16) | not located or reviewed in this recovery; the organisers never stated "this team won" in so many words |
| Prizes: USD 5,000 AWS credits, USD 200 Claude credits, Samsung Galaxy Tab S10 Lite | REPORTED | CL1 msg 84, CL2 msg 70 (consistent) |
| Judges' reaction: "puros elogios"; everyone liked the link between the rise of narcomenudeo and the rise of narco-culture | REPORTED | CL2 msg 68 |
| **The Gobierno del Estado de Sonora publishes Equipo 7's dashboard** on its open-data portal ("Equipo 7 Dataton 2", "2do DATATÓN" branding) | **VERIFIED** (2026-11-16) | https://www.sonora.gob.mx/datos/equipo7dataton2; capture in `recovery/evidence/published_dashboard_2026-11-16.*`. The page shows no placement label; whether all teams or only winners were published is UNKNOWN |
| A judge from state public-security information wanted to hire the presenter but required a degree | REPORTED | CL2 msg 68; the jury list includes that role (briefing p.12) |

**Classification: winner of the Seguridad category, reported. Officially corroborated in part: the organiser publishes the team's dashboard on the state portal, but no official statement of the placement was found.**
The material contains no announcement, certificate, ranking, score sheet, or organiser communication.
The two reports are consistent with each other and with timing: both came from the same participant,
in two different AI accounts, a day apart. The win was later used in a CV and in internship outreach (private).

**To verify fully:** whether the portal publishes only winning dashboards, an organiser announcement (state government / ATDT social media or site), a certificate or
prize-delivery e-mail, or a photo of the award. See `recovery/unresolved_questions.md`.

## 2. Why it may have won

No jury feedback beyond the participant's one-line summary exists, so **the reasons for the win are not documented**.
The table separates what is documented from what is interpretation.

### Documented

- The jury liked the **narcomenudeo ↔ narco-culture link** [REPORTED, CL2 msg 68].
- The official criteria weight **analysis 25, problem understanding 20, dashboard 20, storytelling 20, recommendations 15** [VERIFIED].

### Analytical interpretation (mine, mapped to the official criteria) [INFERENCE]

| Criterion | Characteristics of the project that plausibly scored well |
|---|---|
| Comprensión del problema (20) | Answered the official question directly and challenged the obvious answer (marginación) with the suggested datasets |
| Calidad del análisis (25) | Breadth (11 sources, 72 municipalities, 2015–2025), correlations with p-values, explicit discarding of noisy Google Trends terms, an "ML" component. The weaknesses documented in `10_limitations.md` are not visible in a 5-minute pitch |
| Diseño y usabilidad (20) | Single scroll page in the state government's colour palette; map-driven interaction with three highlighted municipalities |
| Storytelling (20) | Hero's-journey structure ("Vivimos en una narrativa muy cómoda…"), a surprising reversal, a memorable close ("Ahí donde un joven sale de la escuela, el sistema pierde control…") |
| Insights y recomendaciones (15) | Concrete, actionable policy for named municipalities (becas, reinserción escolar) |
| Audience fit | Topical theme (narcocorridos were a public debate in 2025–2026) [INFERENCE]; a judge with a public-security background reportedly engaged personally |

What cannot be said: that the analysis was judged *correct*. The evidence only supports that the
presentation persuaded the panel.

## 3. Post-competition conclusions found in the material

- Asked how the win could be explained to a non-technical relative, the summary given was *"el problema no es la pobreza como todos creen — es que hay muchos jóvenes de 15 y 16 años que dejan la escuela…"* (CL2 msg 73). This keeps the size-confounded reading of the data.
- One month later the participant asked how Pearson correlations had been used (CL1 msg 88). The answer (pandas `.corr()` across 72 municipalities) is consistent with the recovered code.
