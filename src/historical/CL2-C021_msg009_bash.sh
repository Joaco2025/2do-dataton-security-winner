# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=9 message_id=019dbb54-06fe-72be-9653-059f124dc058 sender=assistant created_at=2026-04-23T17:14:31.702256Z kind=bash
# DESCRIPTION/PATH: Build correlation matrix for heatmap and identify key significant findings
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from scipy import stats

# Re-load data
df_maestro = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='01_Maestro_Municipal', header=0)
df_coneval  = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='15_CONEVAL_Pobreza_Sonora', header=2)
df_irs      = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='16_IRS_Rezago_Social_Sonora', header=2)
df_rh       = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='17_Rezago_Habitacional', header=2)
df_sesnsp   = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='04_SESNSP_Tipo_Municipio', header=0)

df_maestro['cve_mun'] = df_maestro['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp['cve_mun']  = df_sesnsp['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp_total = df_sesnsp.groupby('cve_mun')['casos'].sum().reset_index().rename(columns={'casos':'total_delitos_sesnsp_v2'})

df = df_maestro.copy()
df = df.merge(df_coneval[['cve_mun','pct_pobreza_2020','pct_pobreza_extrema_2020',
    'pct_rezago_educativo_2020','pct_sin_salud_2020','pct_sin_seg_social_2020',
    'pct_carencia_vivienda_2020','pct_sin_servicios_basicos_2020',
    'pct_carencia_alimentacion_2020','pct_al_menos_una_carencia_2020','pct_3mas_carencias_2020']], on='cve_mun', how='left')
df = df.merge(df_irs[['cve_mun','indice_rezago_social']], on='cve_mun', how='left')
df = df.merge(df_rh[['cve_mun','pct_rezago_hab_2020']], on='cve_mun', how='left')
df = df.merge(df_sesnsp_total, on='cve_mun', how='left')

# ─── Build full correlation matrix for heatmap ───
heatmap_vars = {
    # Factores sociales
    'indice_marginacion':              'Índice marginación',
    'pct_pobreza_2020':                'Pobreza',
    'pct_pobreza_extrema_2020':        'Pobreza extrema',
    'pct_rezago_educativo_2020':       'Rezago educativo',
    'pct_sin_seg_social_2020':         'Sin seg. social',
    'pct_carencia_alimentacion_2020':  'Carencia alimentación',
    'indice_rezago_social':            'Índice rezago social',
    'pct_rezago_hab_2020':             'Rezago habitacional',
    'pct_NO_asiste_15a17':             'Jóvenes sin escuela',
    'pct_analfabeta_15mas':            'Analfabetismo',
    'pct_ingreso_bajo_2sm':            'Ingreso bajo',
    # Delitos
    'tasa_delitos_10k':                'Tasa delitos/10k',
    'total_delitos_sesnsp':            'Total delitos',
    'Narcomenudeo':                    'Narcomenudeo',
    'menores_detenidos':               'Menores detenidos',
}

available = {k:v for k,v in heatmap_vars.items() if k in df.columns}
df_hm = df[list(available.keys())].rename(columns=available)
corr_matrix = df_hm.corr(method='pearson').round(3)
print("Heatmap matrix shape:", corr_matrix.shape)
print(corr_matrix.to_string())

# ── Compute p-values matrix ──
cols = list(available.values())
n = len(df_hm)
pval_matrix = pd.DataFrame(index=cols, columns=cols, dtype=float)
for c1 in cols:
    for c2 in cols:
        pair = df_hm[[c1,c2]].dropna()
        if len(pair) >= 5 and c1 != c2:
            _, p = stats.pearsonr(pair[c1], pair[c2])
            pval_matrix.loc[c1, c2] = round(p, 4)
        else:
            pval_matrix.loc[c1, c2] = np.nan

# Save both for Excel
corr_matrix.to_csv('/home/claude/corr_matrix.csv')
pval_matrix.to_csv('/home/claude/pval_matrix.csv')
df.to_csv('/home/claude/maestro_relacional.csv', index=False)
print("\nSaved!")
print(f"Maestro relacional: {len(df)} municipios, {len(df.columns)} cols")

# Summary of key findings
print("\n=== KEY FINDINGS ===")
sig = []
social_keys = list(available.keys())[:11]
crime_keys = list(available.keys())[11:]
for sv in social_keys:
    sv_label = available[sv]
    for cv in crime_keys:
        cv_label = available[cv]
        pair = df[[sv, cv]].dropna()
        if len(pair) < 10: continue
        r, p = stats.pearsonr(pair[sv], pair[cv])
        if p < 0.05:
            dir_ = "↑" if r > 0 else "↓"
            sig.append({'factor': sv_label, 'delito': cv_label, 'r': round(r,3), 'p': round(p,4), 'dir': dir_})
sig_df = pd.DataFrame(sig).sort_values('r', key=abs, ascending=False)
print(sig_df.to_string())

EOF
