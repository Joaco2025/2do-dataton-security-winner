# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=9 message_id=019dbb54-06fe-72be-9653-059f124dc058 sender=assistant created_at=2026-04-23T17:14:31.702256Z kind=bash
# DESCRIPTION/PATH: Calculate all Pearson correlations between social factors and crime indicators
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from scipy import stats

# Reload
df_maestro = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='01_Maestro_Municipal', header=0)
df_coneval  = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='15_CONEVAL_Pobreza_Sonora', header=2)
df_irs      = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='16_IRS_Rezago_Social_Sonora', header=2)
df_rh       = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='17_Rezago_Habitacional', header=2)
df_sesnsp   = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='04_SESNSP_Tipo_Municipio', header=0)

df_maestro['cve_mun'] = df_maestro['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp['cve_mun']  = df_sesnsp['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp_total = df_sesnsp.groupby('cve_mun')['casos'].sum().reset_index().rename(columns={'casos':'total_delitos_sesnsp_v2'})

df = df_maestro.merge(df_coneval[['cve_mun','pct_pobreza_2020','pct_pobreza_extrema_2020',
    'pct_rezago_educativo_2020','pct_sin_salud_2020','pct_sin_seg_social_2020',
    'pct_carencia_vivienda_2020','pct_sin_servicios_basicos_2020',
    'pct_carencia_alimentacion_2020','pct_al_menos_una_carencia_2020','pct_3mas_carencias_2020']], on='cve_mun', how='left')
df = df.merge(df_irs[['cve_mun','indice_rezago_social']], on='cve_mun', how='left')
df = df.merge(df_rh[['cve_mun','pct_rezago_hab_2020']], on='cve_mun', how='left')
df = df.merge(df_sesnsp_total, on='cve_mun', how='left')

# Variables independientes (factores sociales)
social_vars = {
    'pct_pobreza_2020':             'Pobreza (%)',
    'pct_pobreza_extrema_2020':     'Pobreza extrema (%)',
    'pct_rezago_educativo_2020':    'Rezago educativo (%)',
    'pct_sin_salud_2020':           'Sin acceso salud (%)',
    'pct_sin_seg_social_2020':      'Sin seg. social (%)',
    'pct_carencia_vivienda_2020':   'Carencia vivienda (%)',
    'pct_sin_servicios_basicos_2020':'Sin servicios básicos (%)',
    'pct_carencia_alimentacion_2020':'Carencia alimentación (%)',
    'pct_3mas_carencias_2020':      '3+ carencias (%)',
    'indice_rezago_social':         'Índice rezago social',
    'pct_rezago_hab_2020':          'Rezago habitacional (%)',
    'indice_marginacion':           'Índice marginación',
    'pct_NO_asiste_15a17':          'Jóvenes sin escuela 15-17 (%)',
    'pct_analfabeta_15mas':         'Analfabetismo 15+ (%)',
    'pct_ingreso_bajo_2sm':         'Ingreso < 2 SM (%)',
    'pct_piso_tierra':              'Piso de tierra (%)',
    'pct_sin_drenaje':              'Sin drenaje (%)',
    'pct_sin_agua':                 'Sin agua (%)',
}

# Variables dependientes (delitos)
crime_vars = {
    'tasa_delitos_10k':       'Tasa delitos /10k hab.',
    'total_delitos_sesnsp':   'Total delitos SESNSP',
    'Narcomenudeo':           'Narcomenudeo',
    'menores_detenidos':      'Menores detenidos',
}

print("═"*80)
print("MATRIZ DE CORRELACIONES: Factores Sociales vs Indicadores Delictivos")
print("═"*80)

results = []
for sv, sv_label in social_vars.items():
    for cv, cv_label in crime_vars.items():
        if sv not in df.columns or cv not in df.columns:
            continue
        pair = df[[sv, cv]].dropna()
        if len(pair) < 10:
            continue
        r, p = stats.pearsonr(pair[sv], pair[cv])
        sig = '***' if p < 0.001 else ('**' if p < 0.01 else ('*' if p < 0.05 else ''))
        results.append({'factor_social': sv_label, 'indicador_delito': cv_label,
                        'pearson_r': round(r, 3), 'p_valor': round(p, 4),
                        'significancia': sig, 'n': len(pair),
                        'sv_col': sv, 'cv_col': cv})
        print(f"  {sv_label:<35} ↔ {cv_label:<28} r={r:+.3f}  p={p:.4f} {sig}")

df_corr = pd.DataFrame(results)
print(f"\nTotal correlaciones calculadas: {len(df_corr)}")
print(f"Significativas (p<0.05): {(df_corr['p_valor'] < 0.05).sum()}")
print("\nTop 10 correlaciones más fuertes (|r|):")
print(df_corr.nlargest(10, 'pearson_r')[['factor_social','indicador_delito','pearson_r','p_valor','significancia']].to_string())

EOF
