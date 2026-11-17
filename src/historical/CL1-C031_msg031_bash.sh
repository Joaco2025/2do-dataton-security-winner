# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=31 message_id=019db2a3-d07d-7d7e-91a4-c20faeeec841 sender=assistant created_at=2026-04-22T00:44:06.255695Z kind=bash
# DESCRIPTION/PATH: Calcular % de 15-17 que NO asisten y su correlación
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 -c "
import pandas as pd
import numpy as np
from pathlib import Path

UP = Path('/mnt/user-data/uploads')

iter_raw = pd.read_csv(UP / 'conjunto_de_datos_iter_26CSV20.csv', encoding='latin-1')
iter_mun = iter_raw[(iter_raw['LOC'] == 0) & (iter_raw['MUN'] != 0)].copy()

def num_cols(df, cols):
    for c in cols:
        df[c] = pd.to_numeric(df[c], errors='coerce').fillna(0)
    return df

# Verificar columnas disponibles para 15-17
cols_15a17 = [c for c in iter_raw.columns if '15' in c and '17' in c]
print('Columnas 15-17 disponibles:', cols_15a17)
print()

# Ver también las de 18-24 por si acaso
cols_18a24 = [c for c in iter_raw.columns if '18' in c and '24' in c]
print('Columnas 18-24:', cols_18a24)
print()

# Verificar valores de P_15A17 y P15A17A
iter_mun = num_cols(iter_mun, ['P_15A17','P15A17A','P_15A17_F','P_15A17_M',
                                'P15A17A_F','P15A17A_M'])
iter_mun['municipio'] = iter_mun['NOM_MUN'].str.strip().str.title()
iter_mun['pct_asiste_15a17']    = (iter_mun['P15A17A']   / iter_mun['P_15A17'] * 100).round(2)
iter_mun['pct_NO_asiste_15a17'] = 100 - iter_mun['pct_asiste_15a17']
iter_mun['abs_NO_asiste_15a17'] = iter_mun['P_15A17'] - iter_mun['P15A17A']

print('=== TOP 10 municipios con más % de 15-17 que NO asisten ===')
top = iter_mun.nlargest(10, 'pct_NO_asiste_15a17')[
    ['municipio','P_15A17','P15A17A','abs_NO_asiste_15a17','pct_NO_asiste_15a17','pct_asiste_15a17']
]
print(top.to_string(index=False))
print()
print('=== Estadísticas generales 15-17 ===')
print(f'Total jóvenes 15-17 en Sonora: {iter_mun[\"P_15A17\"].sum():,.0f}')
print(f'Total que SÍ asisten: {iter_mun[\"P15A17A\"].sum():,.0f}')
print(f'Total que NO asisten: {iter_mun[\"abs_NO_asiste_15a17\"].sum():,.0f}')
print(f'% estatal que NO asiste: {(iter_mun[\"abs_NO_asiste_15a17\"].sum() / iter_mun[\"P_15A17\"].sum() * 100):.1f}%')
"
