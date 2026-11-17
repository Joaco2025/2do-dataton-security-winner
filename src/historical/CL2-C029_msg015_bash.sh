# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=15 message_id=019dbdfb-08ab-7aec-9476-077eb8f42efe sender=assistant created_at=2026-04-24T05:36:15.202890Z kind=bash
# DESCRIPTION/PATH: Build regression models and create sheets 24-25 with predictions and trend lines
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

GUINDA_OSC = "6B1228"; GUINDA_MED = "9B1D3A"; CREMA = "F5F0E8"
GRIS = "3D3D3D"; BLANCO = "FFFFFF"; ALT_ROW = "F9F5F6"
VERDE = "1A7A4A"; NARANJA = "C4631A"

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
            cell = ws.cell(row=r, column=c, value=(None if isinstance(val, float) and np.isnan(val) else val))
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

# ═══════════════════════════════════════════════════════
# LOAD DATA
# ═══════════════════════════════════════════════════════
df_sesnsp   = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='03_SESNSP_2020_2025', header=0)
df_sesnsp_t = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='04_SESNSP_Tipo_Municipio', header=0)
df_maestro  = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='01_Maestro_Municipal', header=0)
df_coneval  = pd.read_excel('/mnt/user-data/uploads/nuevos_datasets_sonora_1_.xlsx', sheet_name='15_CONEVAL_Pobreza_Sonora', header=2)

df_maestro['cve_mun']  = df_maestro['cve_mun'].astype(str).str.lstrip('0').astype(int)
df_sesnsp_t['cve_mun'] = df_sesnsp_t['cve_mun'].astype(str).str.lstrip('0').astype(int)

# ═══════════════════════════════════════════════════════
# HOJA 24 — PROYECCIÓN NARCOMENUDEO (modelo lineal)
# ═══════════════════════════════════════════════════════
narco_anual = df_sesnsp[df_sesnsp['tipo_delito']=='Narcomenudeo'].groupby('año')['casos'].sum().reset_index()
robo_anual  = df_sesnsp[df_sesnsp['tipo_delito']=='Robo'].groupby('año')['casos'].sum().reset_index()
vf_anual    = df_sesnsp[df_sesnsp['tipo_delito']=='Violencia familiar'].groupby('año')['casos'].sum().reset_index()
total_anual = df_sesnsp.groupby('año')['casos'].sum().reset_index()

# Merge all
df_series = narco_anual.rename(columns={'casos':'Narcomenudeo'})\
    .merge(robo_anual.rename(columns={'casos':'Robo'}), on='año')\
    .merge(vf_anual.rename(columns={'casos':'Violencia_familiar'}), on='año')\
    .merge(total_anual.rename(columns={'casos':'Total_delitos'}), on='año')
df_series['tipo_dato'] = 'Real'
df_series['año_num']   = df_series['año']

# Fit models
años_reales = df_series[['año']].values
model_narco = LinearRegression().fit(años_reales, df_series['Narcomenudeo'])
model_robo  = LinearRegression().fit(años_reales, df_series['Robo'])
model_vf    = LinearRegression().fit(años_reales, df_series['Violencia_familiar'])
model_total = LinearRegression().fit(años_reales, df_series['Total_delitos'])

r2_narco = r2_score(df_series['Narcomenudeo'], model_narco.predict(años_reales))
r2_robo  = r2_score(df_series['Robo'],         model_robo.predict(años_reales))

# Proyecciones 2026-2028
años_proy = np.array([[2026],[2027],[2028]])
rows_pred = []
for yr in [2026, 2027, 2028]:
    X_p = np.array([[yr]])
    rows_pred.append({
        'año': yr,
        'Narcomenudeo': max(0, round(model_narco.predict(X_p)[0])),
        'Robo':         max(0, round(model_robo.predict(X_p)[0])),
        'Violencia_familiar': max(0, round(model_vf.predict(X_p)[0])),
        'Total_delitos': max(0, round(model_total.predict(X_p)[0])),
        'tipo_dato': 'Proyección'
    })

df_pred = pd.DataFrame(rows_pred)
df_24 = pd.concat([df_series.drop('año_num', axis=1), df_pred], ignore_index=True)

# Add fitted values for the real years too (for regression line)
df_24['narco_tendencia'] = model_narco.predict(df_24[['año']].values).round(0)
df_24['robo_tendencia']  = model_robo.predict(df_24[['año']].values).round(0)

# Metadata
df_meta_narco = pd.DataFrame({
    'modelo': ['Narcomenudeo (Regresión Lineal)', 'Robo (Regresión Lineal)'],
    'pendiente_casos_por_año': [round(model_narco.coef_[0], 1), round(model_robo.coef_[0], 1)],
    'R2': [round(r2_narco, 3), round(r2_robo, 3)],
    'interpretacion': [
        f'+{model_narco.coef_[0]:.0f} casos adicionales de narcomenudeo cada año',
        f'{model_robo.coef_[0]:.0f} casos menos de robo cada año'
    ],
    'años_datos': ['2020-2025 (6 puntos)', '2020-2025 (6 puntos)'],
    'proyeccion_2026': [int(model_narco.predict([[2026]])[0]), int(model_robo.predict([[2026]])[0])],
    'proyeccion_2027': [int(model_narco.predict([[2027]])[0]), int(model_robo.predict([[2027]])[0])],
    'proyeccion_2028': [int(model_narco.predict([[2028]])[0]), int(model_robo.predict([[2028]])[0])],
})

# ═══════════════════════════════════════════════════════
# HOJA 25 — REGRESIÓN LINEAL SCATTER (Gráfica 5)
# municipio: indice_marginacion_norm vs tasa_delitos_10k + línea ajustada
# ═══════════════════════════════════════════════════════
from scipy import stats as scipy_stats

df_narco_mun = df_sesnsp_t[df_sesnsp_t['tipo_delito']=='Narcomenudeo']\
    .groupby('cve_mun')['casos'].sum().reset_index(name='narco_casos')

df_scatter = df_maestro.merge(df_narco_mun, on='cve_mun', how='left')
df_scatter = df_scatter.merge(df_coneval[['cve_mun','pct_pobreza_2020','pct_rezago_educativo_2020']], on='cve_mun', how='left')
df_scatter['tasa_narco_10k'] = (df_scatter['narco_casos'] / df_scatter['poblacion_total'] * 10000).round(2)
df_scatter['narco_casos'] = df_scatter['narco_casos'].fillna(0)

def seg(pop):
    if pop >= 100000: return 'Urbano grande (100k+)'
    elif pop >= 20000: return 'Urbano medio (20k-100k)'
    elif pop >= 5000:  return 'Semi-urbano (5k-20k)'
    else:              return 'Rural (<5k)'
df_scatter['segmento_urbano'] = df_scatter['poblacion_total'].apply(seg)

# Correlación marginación vs tasa delitos
pair = df_scatter[['indice_marginacion_norm','tasa_delitos_10k']].dropna()
slope_mg, intercept_mg, r_mg, p_mg, _ = scipy_stats.linregress(pair['indice_marginacion_norm'], pair['tasa_delitos_10k'])

# Agregar línea de regresión como columna calculada
df_scatter['tendencia_tasa_delitos'] = (slope_mg * df_scatter['indice_marginacion_norm'] + intercept_mg).round(1)

# Correlación narco vs jóvenes sin escuela
pair2 = df_scatter[['abs_NO_asiste_15a17','tasa_narco_10k']].dropna()
slope_ns, intercept_ns, r_ns, p_ns, _ = scipy_stats.linregress(pair2['abs_NO_asiste_15a17'], pair2['tasa_narco_10k'])
df_scatter['tendencia_tasa_narco'] = (slope_ns * df_scatter['abs_NO_asiste_15a17'] + intercept_ns).round(1)

cols_25 = ['cve_mun','municipio','poblacion_total','segmento_urbano',
           'grado_marginacion','indice_marginacion_norm',
           'tasa_delitos_10k','tendencia_tasa_delitos',
           'abs_NO_asiste_15a17','tasa_narco_10k','tendencia_tasa_narco',
           'pct_pobreza_2020','pct_rezago_educativo_2020']
df_25 = df_scatter[[c for c in cols_25 if c in df_scatter.columns]].reset_index(drop=True)

# Metadata regresiones
df_meta_scatter = pd.DataFrame({
    'relacion': ['Marginación → Tasa delitos', 'Jóvenes sin escuela → Tasa narco'],
    'pendiente': [round(slope_mg, 2), round(slope_ns, 4)],
    'intercepto': [round(intercept_mg, 2), round(intercept_ns, 2)],
    'R': [round(r_mg, 3), round(r_ns, 3)],
    'R2': [round(r_mg**2, 3), round(r_ns**2, 3)],
    'p_valor': [round(p_mg, 4), round(p_ns, 4)],
    'significancia': ['***' if p_mg<0.001 else '*', '***' if p_ns<0.001 else '*'],
    'formula': [
        f'tasa_delitos = {slope_mg:.1f} × marg_norm + {intercept_mg:.1f}',
        f'tasa_narco = {slope_ns:.4f} × jovenes_sin_escuela + {intercept_ns:.1f}'
    ],
    'interpretacion': [
        f'Por cada unidad de marginación normalizada, la tasa de delitos cambia {slope_mg:.0f} unidades',
        f'Por cada joven adicional fuera de la escuela, la tasa de narco sube {slope_ns:.4f}/10k hab.'
    ]
})

print("=== METADATA MODELOS ===")
print(df_meta_narco.to_string())
print("\n=== METADATA SCATTER ===")
print(df_meta_scatter.to_string())
print(f"\nHoja 24 (proyecciones): {len(df_24)} filas")
print(f"Hoja 25 (scatter): {len(df_25)} filas")
print(df_24.to_string())

# ═══════════════════════════════════════════════════════
# ESCRIBIR AL EXCEL
# ═══════════════════════════════════════════════════════
wb = load_workbook('/home/claude/sonora_seguridad_powerbi.xlsx')

# HOJA 24 - Series temporales + proyecciones
ws24 = wb.create_sheet('24_Proyeccion_Narco_ML')
start = add_title(ws24,
    '🤖 Modelo Predictivo – Proyección Narcomenudeo 2026-2028',
    'Regresión lineal OLS · R²(narco)=0.603 · R²(robo)=0.915 · Fuente: SESNSP 2020-2025')
write_table(ws24, df_24[['año','tipo_dato','Narcomenudeo','narco_tendencia','Robo','robo_tendencia','Violencia_familiar','Total_delitos']], start_row=start)

# Metadata below
start2 = start + len(df_24) + 3
ws24.cell(row=start2, column=1, value='📊 Estadísticas del Modelo').font = Font(bold=True, color=GUINDA_OSC, size=11)
write_table(ws24, df_meta_narco, start_row=start2+1, header_bg=GUINDA_MED)

# HOJA 25 - Scatter con tendencias
ws25 = wb.create_sheet('25_Scatter_Regresion_ML')
start = add_title(ws25,
    '📈 Regresión Lineal – Marginación vs Delitos | Deserción vs Narco',
    'Líneas de tendencia calculadas por regresión OLS · Para usar en Scatter Plot con Analytics → Trend Line en Power BI')
write_table(ws25, df_25, start_row=start)

# Metadata
start2 = start + len(df_25) + 3
ws25.cell(row=start2, column=1, value='📊 Coeficientes de Regresión').font = Font(bold=True, color=GUINDA_OSC, size=11)
write_table(ws25, df_meta_scatter, start_row=start2+1, header_bg=GUINDA_MED)

wb.save('/home/claude/sonora_seguridad_powerbi.xlsx')
import shutil
shutil.copy('/home/claude/sonora_seguridad_powerbi.xlsx', '/mnt/user-data/outputs/sonora_seguridad_powerbi.xlsx')
print("\n✅ Hojas 24 y 25 añadidas al Excel maestro!")
EOF
