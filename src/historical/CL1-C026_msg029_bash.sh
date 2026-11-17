# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=29 message_id=019db296-ca9f-7abe-9aaa-70c419f8a820 sender=assistant created_at=2026-04-22T00:29:39.384340Z kind=bash
# DESCRIPTION/PATH: Calcular y analizar correlaciones detalladas
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 -c "
import pandas as pd
import numpy as np
from pathlib import Path

UP = Path('/mnt/user-data/uploads')

# Reconstruir el maestro rápido
iter_raw = pd.read_csv(UP / 'conjunto_de_datos_iter_26CSV20.csv', encoding='latin-1')
iter_mun = iter_raw[(iter_raw['LOC'] == 0) & (iter_raw['MUN'] != 0)].copy()

def num_cols(df, cols):
    for c in cols:
        df[c] = pd.to_numeric(df[c], errors='coerce').fillna(0)
    return df

iter_mun = num_cols(iter_mun, ['P_3A5','P3A5_NOA','P_6A11','P6A11_NOA',
    'P_12A14','P12A14NOA','P_15A17','P15A17A','P_15YMAS',
    'P15YM_AN','GRAPROES','P15YM_SE','P18YM_PB','POBTOT'])

iter_mun['pct_no_asiste_3a5']    = (iter_mun['P3A5_NOA']  / iter_mun['P_3A5']    * 100).round(2)
iter_mun['pct_no_asiste_6a11']   = (iter_mun['P6A11_NOA'] / iter_mun['P_6A11']   * 100).round(2)
iter_mun['pct_no_asiste_12a14']  = (iter_mun['P12A14NOA'] / iter_mun['P_12A14']  * 100).round(2)
iter_mun['pct_asiste_15a17']     = (iter_mun['P15A17A']   / iter_mun['P_15A17']  * 100).round(2)
iter_mun['pct_analfabeta_15mas'] = (iter_mun['P15YM_AN']  / iter_mun['P_15YMAS'] * 100).round(2)
iter_mun['pct_sin_escolaridad']  = (iter_mun['P15YM_SE']  / iter_mun['P_15YMAS'] * 100).round(2)
iter_mun['pct_posbasica_18mas']  = (iter_mun['P18YM_PB']  / iter_mun['POBTOT']   * 100).round(2)
iter_mun['cve_mun']   = iter_mun['MUN'].astype(str).str.zfill(3)
iter_mun['municipio'] = iter_mun['NOM_MUN'].str.strip().str.title()
iter_mun['poblacion_total'] = iter_mun['POBTOT']
iter_mun['grado_escolaridad_prom'] = iter_mun['GRAPROES']

marg_raw = pd.read_excel(UP / 'indice-de-marginacion-municipios-2020.xlsx')
marg_raw.columns = marg_raw.columns.str.strip()
c = marg_raw.columns.tolist()
MARG = marg_raw.rename(columns={
    c[0]:'clave_inegi', c[1]:'municipio_marg',
    c[11]:'pct_ingreso_bajo_2sm', c[12]:'indice_marginacion',
    c[13]:'grado_marginacion', c[4]:'pct_sin_educ_basica'
})
MARG['cve_mun'] = MARG['clave_inegi'].astype(str).str[-3:].str.zfill(3)

sesnsp = pd.read_csv(UP / 'sesnsp_largo_2015_2025.csv', encoding='utf-8')
sesnsp.columns = sesnsp.columns.str.strip()
sesnsp['cve_mun'] = sesnsp['Cve. Municipio'].astype(str).str[-3:].str.zfill(3)
sesnsp_20 = sesnsp[sesnsp['Año'] >= 2020]
SESNSP_MUN = sesnsp_20.groupby('cve_mun')['Casos'].sum().reset_index()
SESNSP_MUN.columns = ['cve_mun','total_delitos_sesnsp']

det = pd.read_excel(UP / 'Personas_Detenidas_en_el_primer_trimestre_2026.xlsx')
det.columns = det.columns.str.strip()
det['municipio'] = det['municipio'].str.strip().str.title()
det['edad'] = pd.to_numeric(det['edad'], errors='coerce')
det['es_menor'] = det['edad'] < 18
DET_MUN = det.groupby('municipio').agg(
    total_detenidos=('municipio','count'),
    menores_detenidos=('es_menor','sum')
).reset_index()

itama = pd.read_excel(UP / 'poblacion-itama-internamiento-1-trimestre-2026.xlsx',
                      sheet_name='POBLACION INTERNAMIENTO')
itama.columns = itama.columns.str.strip()
itama['municipio'] = itama['LOCALIDAD DEL DELITO'].str.split(',').str[0].str.strip().str.title()
ITAMA_MUN = itama.groupby('municipio').agg(menores_internados=('municipio','count')).reset_index()

# Merge maestro
maestro = iter_mun[['cve_mun','municipio','poblacion_total','grado_escolaridad_prom',
    'pct_no_asiste_3a5','pct_no_asiste_6a11','pct_no_asiste_12a14',
    'pct_asiste_15a17','pct_analfabeta_15mas','pct_sin_escolaridad',
    'pct_posbasica_18mas']].copy()
maestro = maestro.merge(MARG[['cve_mun','indice_marginacion','grado_marginacion',
    'pct_sin_educ_basica','pct_ingreso_bajo_2sm']], on='cve_mun', how='left')
maestro = maestro.merge(SESNSP_MUN, on='cve_mun', how='left')
maestro = maestro.merge(DET_MUN, on='municipio', how='left')
maestro = maestro.merge(ITAMA_MUN, on='municipio', how='left')

for c in ['total_delitos_sesnsp','total_detenidos','menores_detenidos','menores_internados']:
    maestro[c] = maestro[c].fillna(0)

maestro['tasa_delitos_10k']   = (maestro['total_delitos_sesnsp'] / maestro['poblacion_total'] * 10000).round(2)
maestro['tasa_detenidos_10k'] = (maestro['total_detenidos']      / maestro['poblacion_total'] * 10000).round(2)

# Matriz de correlación completa con valores
cols_corr = ['indice_marginacion','pct_sin_educ_basica','pct_analfabeta_15mas',
             'grado_escolaridad_prom','pct_no_asiste_12a14','pct_asiste_15a17',
             'pct_ingreso_bajo_2sm','tasa_delitos_10k','tasa_detenidos_10k',
             'total_detenidos','menores_detenidos','menores_internados']

corr = maestro[cols_corr].corr().round(3)
print('=== MATRIZ COMPLETA ===')
print(corr.to_string())
print()
print('=== CORRELACIONES CON tasa_delitos_10k (ordenadas) ===')
print(corr['tasa_delitos_10k'].sort_values(ascending=False).to_string())
print()
print('=== CORRELACIONES CON menores_detenidos (ordenadas) ===')
print(corr['menores_detenidos'].sort_values(ascending=False).to_string())
print()
print('=== CORRELACIONES CON indice_marginacion (ordenadas) ===')
print(corr['indice_marginacion'].sort_values(ascending=False).to_string())
"
