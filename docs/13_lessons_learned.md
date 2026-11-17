# 13 · Lessons learned

## Technical

1. **Join on codes, never on names.** One encoding mistake plus name-based joins silently removed 14 % of detentions and half of the ITAMA cases. Use INEGI `cve_mun` everywhere and assert join coverage.
2. **Normalise before correlating.** Absolute counts across municipalities of very different size will always correlate. Use rates per resident or per age group, and check against population (here r = 0.99).
3. **Look at leverage.** With three non-zero municipalities, one city decided the headline coefficient.
4. **Six points are not a model.** Use monthly data (available in SESNSP), hold-out evaluation and prediction intervals, or present trend lines as descriptive.
5. **Keep code with outputs.** The pipeline lived in chat sandboxes. It survived only because the AI-account exports kept the tool calls. Save every script to the repository as it is written.
6. **One branch at a time.** Running two AI accounts in parallel produced two incompatible "v5" workbooks.
7. **Flat tables for BI.** Decorative title rows cost hours in Power BI and in later scripts.

## Process

8. The team caught its own biggest conceptual error ("Hermosillo is simply the most populous city") within hours. That instinct mattered more than any tool.
9. The advisor's interventions (schooling angle, heatmap, gradient, 10-year projection) shaped the final product more than the data did.
10. Requests like "nada de inferencias" and "tu conclusión asume" show sound scientific instincts. Keeping them through the final script needs a claim-by-claim check against the numbers (see `11_final_pitch.md`).

## For a second edition

- Obtain individual-level data (ENASJUP microdata via INEGI's secure lab, CNPJE adolescent tabulations, SEP 911 dropout by municipality).
- Fix the joins and recompute per-capita measures; report both Pearson and Spearman with FDR correction.
- Replace the Google Trends argument with a pre-registered, lag-aware time-series comparison, or drop it.
- Keep the storytelling, which is the part that demonstrably worked.
