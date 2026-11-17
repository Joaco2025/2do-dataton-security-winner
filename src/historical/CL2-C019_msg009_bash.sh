# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=9 message_id=019dbb54-06fe-72be-9653-059f124dc058 sender=assistant created_at=2026-04-23T17:14:31.702256Z kind=bash
# DESCRIPTION/PATH: Build master relational table merging all datasets
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np

# Load all properly
df_maestro = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='01_Maestro_Municipal', header=0)
df_coneval  = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='15_CONEVAL_Pobreza_Sonora', header=2)
df_irs      = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='16_IRS_Rezago_Social_Sonora', header=2)
df_rh       = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='17_Rezago_Habitacional', header=2)
df_vp       = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='18_Viviendas_Precarias', header=2)
df_sesnsp   = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='04_SESNSP_Tipo_Municipio', header=0)
df_itama    = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='06_ITAMA_Menores', header=0)

# Fix cve_mun in maestro (comes as '001', '002')
df_maestro['cve_mun'] = df_maestro['cve_mun'].astype(str).str.lstrip('0').astype(int)

# SESNSP: pivot to wide - total delitos por municipio
df_sesnsp['cve_mun'] = df_sesnsp['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp_total = df_sesnsp.groupby('cve_mun')['casos'].sum().reset_index().rename(columns={'casos':'total_delitos_sesnsp_v2'})
df_sesnsp_wide = df_sesnsp.pivot_table(index='cve_mun', columns='tipo_delito', values='casos', aggfunc='sum').reset_index()
df_sesnsp_wide.columns.name = None

# ITAMA: menores por municipio
df_itama['municipio_clean'] = df_itama['municipio'].str.lower().str.strip()
df_itama_mun = df_itama.groupby('municipio').size().reset_index(name='menores_infractores_itama')

# Normalizar nombres para merge itama
mun_map = {
    'Obregon': 'Cajeme', 'Hermosillo': 'Hermosillo', 'Nogales': 'Nogales',
    'Navojoa': 'Navojoa', 'Guaymas': 'Guaymas', 'Caborca': 'Caborca'
}
df_itama_mun['municipio_std'] = df_itama_mun['municipio'].map(mun_map).fillna(df_itama_mun['municipio'])

# ── BUILD MASTER RELACIONAL ──
df = df_maestro.copy()

# Merge CONEVAL (by cve_mun)
coneval_cols = ['cve_mun', 'pct_pobreza_2020', 'pct_pobreza_extrema_2020', 'pct_pobreza_moderada_2020',
    'pct_vulnerable_carencia_2020', 'pct_rezago_educativo_2020', 'pct_sin_salud_2020',
    'pct_sin_seg_social_2020', 'pct_carencia_vivienda_2020', 'pct_sin_servicios_basicos_2020',
    'pct_carencia_alimentacion_2020', 'pct_al_menos_una_carencia_2020', 'pct_3mas_carencias_2020']
df = df.merge(df_coneval[coneval_cols], on='cve_mun', how='left')

# Merge IRS
irs_cols = ['cve_mun', 'indice_rezago_social', 'grado_rezago_social']
df = df.merge(df_irs[irs_cols], on='cve_mun', how='left')

# Merge Rezago Habitacional
rh_cols = ['cve_mun', 'pct_rezago_hab_2015', 'pct_rezago_hab_2020']
df = df.merge(df_rh[rh_cols], on='cve_mun', how='left')

# Merge Viviendas Precarias
vp_cols = ['cve_mun', 'pct_poblacion_vivienda_precaria_2020']
df = df.merge(df_vp[vp_cols], on='cve_mun', how='left')

# Merge SESNSP total
df = df.merge(df_sesnsp_total, on='cve_mun', how='left')

print(f"Maestro relacional: {df.shape}")
print("Cols:", list(df.columns))
print("\nCoverage check (non-null %):")
key_cols = ['pct_pobreza_2020','indice_rezago_social','pct_rezago_hab_2020',
            'pct_poblacion_vivienda_precaria_2020','tasa_delitos_10k','total_delitos_sesnsp_v2']
for c in key_cols:
    if c in df.columns:
        pct = df[c].notna().mean()*100
        print(f"  {c}: {pct:.0f}%")

EOF
