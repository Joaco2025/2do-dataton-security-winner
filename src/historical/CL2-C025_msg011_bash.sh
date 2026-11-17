# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=11 message_id=019dbd3d-dacc-716e-8a4b-04778f57c8b0 sender=assistant created_at=2026-04-24T02:10:03.137237Z kind=bash
# DESCRIPTION/PATH: Create sheets 19-23 and update master Excel
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from scipy import stats
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

GUINDA_OSC = "6B1228"; GUINDA_MED = "9B1D3A"
CREMA = "F5F0E8"; GRIS = "3D3D3D"; BLANCO = "FFFFFF"; ALT_ROW = "F9F5F6"

def style_header(ws, row, ncols, bg=GUINDA_OSC):
    for c in range(1, ncols+1):
        cell = ws.cell(row=row, column=c)
        cell.font = Font(name='Arial', bold=True, color=BLANCO, size=10)
        cell.fill = PatternFill('solid', start_color=bg)
        cell.alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
    ws.row_dimensions[row].height = 28

def write_table(ws, df, start_row=2, header_bg=GUINDA_OSC):
    for c, col in enumerate(df.columns, 1):
        ws.cell(row=start_row, column=c, value=col)
    style_header(ws, start_row, len(df.columns), bg=header_bg)
    ws.freeze_panes = f'A{start_row+1}'
    for r, row_data in enumerate(df.itertuples(index=False), start_row+1):
        bg = BLANCO if (r - start_row) % 2 == 0 else ALT_ROW
        for c, val in enumerate(row_data, 1):
            cell = ws.cell(row=r, column=c, value=(None if (isinstance(val, float) and np.isnan(val)) else val))
            cell.font = Font(name='Arial', size=9, color=GRIS)
            cell.fill = PatternFill('solid', start_color=bg)
            cell.alignment = Alignment(horizontal='left', vertical='center')
    for c, col in enumerate(df.columns, 1):
        vals = df.iloc[:,c-1].astype(str)
        w = max(len(str(col)), vals.str.len().max() if len(df)>0 else 0)
        ws.column_dimensions[get_column_letter(c)].width = min(w+3, 35)

def add_title(ws, title, subtitle=''):
    ws.merge_cells('A1:Z1')
    cell = ws['A1']
    cell.value = title
    cell.font = Font(name='Arial', bold=True, color=BLANCO, size=13)
    cell.fill = PatternFill('solid', start_color=GUINDA_OSC)
    cell.alignment = Alignment(horizontal='center', vertical='center')
    ws.row_dimensions[1].height = 28
    if subtitle:
        ws.merge_cells('A2:Z2')
        c2 = ws['A2']
        c2.value = subtitle
        c2.font = Font(name='Arial', italic=True, color=GRIS, size=9)
        c2.fill = PatternFill('solid', start_color=CREMA)
        c2.alignment = Alignment(horizontal='center', vertical='center')
        ws.row_dimensions[2].height = 16
        return 3
    return 2

# ══════════════════════════════════════════════════════════
# LOAD ALL SOURCE DATA
# ══════════════════════════════════════════════════════════
df_maestro  = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='01_Maestro_Municipal', header=0)
df_coneval  = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='15_CONEVAL_Pobreza_Sonora', header=2)
df_irs      = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='16_IRS_Rezago_Social_Sonora', header=2)
df_rh       = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='17_Rezago_Habitacional', header=2)
df_sesnsp   = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='04_SESNSP_Tipo_Municipio', header=0)
df_sesnsp_t = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='03_SESNSP_2020_2025', header=0)
df_itama    = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='06_ITAMA_Menores', header=0)
df_acled_raw= pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='13_ACLED_Sonora_Detalle', header=1)
# Fix ACLED - row 0 is real header
df_acled    = df_acled_raw.iloc[1:].copy()
df_acled.columns = df_acled_raw.iloc[0].tolist()
df_acled = df_acled.reset_index(drop=True)
for col in ['num_eventos','fatalidades','anio','semana']:
    if col in df_acled.columns:
        df_acled[col] = pd.to_numeric(df_acled[col], errors='coerce')

df_maestro['cve_mun'] = df_maestro['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp['cve_mun']  = df_sesnsp['cve_mun'].astype(str).str.lstrip('0').astype(int)

# Merge maestro relacional
df_sesnsp_total = df_sesnsp.groupby('cve_mun')['casos'].sum().reset_index().rename(columns={'casos':'total_delitos_sesnsp_v2'})
df = df_maestro.copy()
df = df.merge(df_coneval[['cve_mun','pct_pobreza_2020','pct_pobreza_extrema_2020',
    'pct_rezago_educativo_2020','pct_sin_salud_2020','pct_sin_seg_social_2020',
    'pct_carencia_vivienda_2020','pct_sin_servicios_basicos_2020',
    'pct_carencia_alimentacion_2020','pct_al_menos_una_carencia_2020','pct_3mas_carencias_2020']], on='cve_mun', how='left')
df = df.merge(df_irs[['cve_mun','indice_rezago_social','grado_rezago_social']], on='cve_mun', how='left')
df = df.merge(df_rh[['cve_mun','pct_rezago_hab_2020']], on='cve_mun', how='left')
df = df.merge(df_sesnsp_total, on='cve_mun', how='left')

# ── Segmento urbano/rural (para gráfica 5) ──
def segmento(row):
    pop = row['poblacion_total']
    if pop >= 100000: return 'Urbano grande (100k+)'
    elif pop >= 20000: return 'Urbano medio (20k-100k)'
    elif pop >= 5000:  return 'Semi-urbano (5k-20k)'
    else:              return 'Rural (<5k)'
df['segmento_urbano'] = df.apply(segmento, axis=1)

# ── Índice de riesgo potencial (para gráfica 8) ──
risk_vars = ['pct_pobreza_extrema_2020','pct_3mas_carencias_2020','pct_sin_servicios_basicos_2020',
             'indice_rezago_social','pct_carencia_vivienda_2020','pct_pobreza_2020','pct_rezago_educativo_2020']
risk_avail = [v for v in risk_vars if v in df.columns]
df_risk = df[risk_avail].copy()
# Normalize IRS (it's negative = more marginado = lower value, invert)
if 'indice_rezago_social' in df_risk.columns:
    df_risk['indice_rezago_social'] = -df_risk['indice_rezago_social']
# Min-max normalize each var
for col in risk_avail:
    mn, mx = df_risk[col].min(), df_risk[col].max()
    if mx > mn:
        df_risk[col] = (df_risk[col] - mn) / (mx - mn)
df['indice_riesgo_potencial'] = df_risk.mean(axis=1).round(4)

print("Maestro relacional final:", df.shape)

# ══════════════════════════════════════════════════════════
# HOJA 19 — RELACIÓN MAESTRA MUNICIPAL
# ══════════════════════════════════════════════════════════
cols_19 = ['cve_mun','municipio','poblacion_total','segmento_urbano',
           'grado_marginacion','indice_marginacion','indice_marginacion_norm',
           'tasa_delitos_10k','total_delitos_sesnsp',
           'abs_NO_asiste_15a17','pct_NO_asiste_15a17',
           'menores_detenidos','menores_internados',
           'pct_pobreza_2020','pct_pobreza_extrema_2020','pct_rezago_educativo_2020',
           'pct_sin_seg_social_2020','pct_carencia_alimentacion_2020',
           'pct_3mas_carencias_2020','indice_rezago_social','grado_rezago_social',
           'pct_rezago_hab_2020','indice_riesgo_potencial',
           'Narcomenudeo','Extorsión','Secuestro']
cols_19_avail = [c for c in cols_19 if c in df.columns]
df_19 = df[cols_19_avail].copy().sort_values('indice_riesgo_potencial', ascending=False).reset_index(drop=True)
print(f"Hoja 19: {df_19.shape}")

# ══════════════════════════════════════════════════════════
# HOJA 20 — ITAMA ANÁLISIS (para gráfica 4)
# ══════════════════════════════════════════════════════════
df_itama_cat = df_itama.groupby('categoria_delito').size().reset_index(name='casos')
df_itama_cat['pct'] = (df_itama_cat['casos'] / df_itama_cat['casos'].sum() * 100).round(1)
df_itama_cat = df_itama_cat.sort_values('casos', ascending=False).reset_index(drop=True)

df_itama_sexo = df_itama.groupby('sexo').size().reset_index(name='total')
df_itama_sexo['pct'] = (df_itama_sexo['total'] / df_itama_sexo['total'].sum() * 100).round(1)

df_itama_edad = pd.DataFrame({
    'metrica': ['Edad promedio','Edad mínima','Edad máxima','Total menores'],
    'valor': [df_itama['edad'].mean().round(1), df_itama['edad'].min(),
              df_itama['edad'].max(), len(df_itama)]
})

df_itama_mun = df_itama.groupby('municipio').size().reset_index(name='casos')\
    .sort_values('casos', ascending=False).reset_index(drop=True)

print(f"ITAMA categorías: {df_itama_cat.to_dict()}")

# ══════════════════════════════════════════════════════════
# HOJA 21 — TENDENCIA DELITOS ANUAL (para gráfica 6)
# ══════════════════════════════════════════════════════════
top3_tipos = df_sesnsp_t.groupby('tipo_delito')['casos'].sum().nlargest(3).index.tolist()
print(f"Top 3 delitos: {top3_tipos}")

df_anual = df_sesnsp_t.groupby('año')['casos'].sum().reset_index(name='total_delitos')
for tipo in top3_tipos:
    tmp = df_sesnsp_t[df_sesnsp_t['tipo_delito']==tipo].groupby('año')['casos'].sum().reset_index(name=tipo)
    df_anual = df_anual.merge(tmp, on='año', how='left')
df_21 = df_anual.fillna(0).astype({'año': int})
# Also monthly for line chart
df_mensual = df_sesnsp_t.groupby(['año','mes'])['casos'].sum().reset_index()
mes_orden = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre']
df_mensual['mes_num'] = df_mensual['mes'].map({m:i+1 for i,m in enumerate(mes_orden)})
df_mensual = df_mensual.sort_values(['año','mes_num']).reset_index(drop=True)
print(f"Hoja 21 anual: {df_21.shape}")
print(df_21.to_string())

# ══════════════════════════════════════════════════════════
# HOJA 22 — ACLED ANÁLISIS (para gráfica 7)
# ══════════════════════════════════════════════════════════
df_acled_fat = df_acled.groupby('tipo_evento').agg(
    total_eventos=('num_eventos','sum'),
    total_fatalidades=('fatalidades','sum')
).reset_index().sort_values('total_fatalidades', ascending=False).reset_index(drop=True)
df_acled_fat['pct_fatalidades'] = (df_acled_fat['total_fatalidades'] / df_acled_fat['total_fatalidades'].sum() * 100).round(1)
df_acled_fat['pct_eventos'] = (df_acled_fat['total_eventos'] / df_acled_fat['total_eventos'].sum() * 100).round(1)

df_acled_anio = df_acled.groupby('anio').agg(
    total_eventos=('num_eventos','sum'),
    total_fatalidades=('fatalidades','sum')
).reset_index()

print(f"\nACLED por tipo:\n{df_acled_fat.to_string()}")

# ══════════════════════════════════════════════════════════
# HOJA 23 — KPI SUMMARY (para gráfica 2)
# ══════════════════════════════════════════════════════════
tasa_prom = df['tasa_delitos_10k'].mean()
munic_alto_riesgo = (df['tasa_delitos_10k'] > df['tasa_delitos_10k'].quantile(0.75)).sum()
total_delitos_sesnsp_serie = df_sesnsp_t['casos'].sum()
total_menores = len(df_itama)
menores_internados_total = df['menores_internados'].sum()

df_kpi = pd.DataFrame({
    'indicador': ['Total delitos 2020-2025 (SESNSP)', 'Tasa promedio estatal (delitos/10k hab.)',
                  'Municipios alto riesgo (Q75+)', 'Menores en ITAMA (casos)',
                  'Total menores internados (Maestro)', 'Municipios con datos'],
    'valor': [int(total_delitos_sesnsp_serie), round(tasa_prom, 1),
              int(munic_alto_riesgo), int(total_menores),
              int(menores_internados_total), int(len(df))],
    'descripcion': [
        'Suma total de delitos registrados por SESNSP en todos los municipios de Sonora 2020-2025',
        'Promedio de tasa delictiva por cada 10,000 habitantes entre los 72 municipios',
        'Municipios cuya tasa delictiva supera el percentil 75 del estado',
        'Casos de menores infractores registrados en base ITAMA',
        'Total de menores internados registrados en el Maestro Municipal',
        'Municipios de Sonora con datos completos en el análisis'
    ]
})
print(f"\nKPIs:\n{df_kpi.to_string()}")

# ══════════════════════════════════════════════════════════
# ESCRIBIR AL EXCEL MAESTRO
# ══════════════════════════════════════════════════════════
wb = load_workbook('/home/claude/sonora_seguridad_powerbi.xlsx')

sheets_to_add = [
    ('19_Relacion_Maestra_Municipal', df_19,
     '🔗 Relación Maestra – Factores Sociales vs Delitos por Municipio',
     'Hoja principal de análisis: une todos los indicadores sociales con incidencia delictiva · Fuente: CONAPO, CONEVAL, SESNSP, ITAMA 2020-2025'),
    ('20_ITAMA_Analisis', df_itama_cat,
     '👦 ITAMA – Perfil del Menor Infractor en Sonora',
     'Distribución de delitos cometidos por menores · Fuente: ITAMA Sonora'),
    ('20b_ITAMA_Municipio', df_itama_mun,
     '📍 ITAMA – Menores Infractores por Municipio',
     'Concentración geográfica de menores infractores'),
    ('21_Tendencia_Delitos_Anual', df_21,
     '📈 Tendencia Delictiva Anual 2020–2025 – Sonora',
     'Total de delitos por año + top 3 tipos · Fuente: SESNSP'),
    ('21b_Delitos_Mensual', df_mensual,
     '📅 Delitos Mensuales 2020–2025',
     'Serie mensual para gráficas de línea · Fuente: SESNSP'),
    ('22_ACLED_Analisis', df_acled_fat,
     '💥 ACLED – Fatalidades y Eventos por Tipo de Violencia',
     'Análisis de violencia letal en Sonora · Fuente: ACLED 2017-2026'),
    ('23_KPI_Resumen', df_kpi,
     '📊 KPIs – Indicadores Clave del Dashboard',
     'Valores de referencia para tarjetas KPI en Power BI'),
]

for sheet_name, df_sheet, title, subtitle in sheets_to_add:
    if sheet_name in wb.sheetnames:
        del wb[sheet_name]
    ws = wb.create_sheet(sheet_name)
    start = add_title(ws, title, subtitle)
    write_table(ws, df_sheet, start_row=start)
    print(f"  ✓ {sheet_name}: {len(df_sheet)} filas")

# Also add sexo/edad stats as extra tabs in 20
ws_sexo = wb.create_sheet('20c_ITAMA_Sexo_Edad')
start = add_title(ws_sexo, '⚧ ITAMA – Distribución por Sexo y Edad', 'Estadísticas demográficas de menores infractores')
write_table(ws_sexo, df_itama_sexo, start_row=start)
r = start + len(df_itama_sexo) + 3
write_table(ws_sexo, df_itama_edad, start_row=r)

wb.save('/home/claude/sonora_seguridad_powerbi.xlsx')
import shutil
shutil.copy('/home/claude/sonora_seguridad_powerbi.xlsx', '/mnt/user-data/outputs/sonora_seguridad_powerbi.xlsx')
print("\n✅ Excel maestro actualizado con hojas 19-23!")
print("Hojas finales:", wb.sheetnames)

EOF
