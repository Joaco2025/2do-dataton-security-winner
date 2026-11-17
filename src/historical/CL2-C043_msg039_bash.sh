# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=39 message_id=019dc323-c318-713e-9f74-a73d93cf65ff sender=assistant created_at=2026-04-25T05:38:36.903989Z kind=bash
# DESCRIPTION/PATH: Build 5x4 correlation matrix in long format for Power BI heatmap
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from scipy import stats
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

# ── Paleta ──
GUINDA_OSC = "6B1228"; GUINDA_MED = "9B1D3A"; GUINDA_CLAR = "C4314B"
AZUL_OSC = "1F4E79"; AZUL_MED = "2C3E8C"; AZUL_CLAR = "7FB3D3"
BLANCO = "FFFFFF"; CREMA = "F5F0E8"; GRIS = "3D3D3D"; DORADO = "D4A017"
ALT_ROW = "F9F5F6"

def style_header(ws, row, ncols, bg=GUINDA_OSC):
    for c in range(1, ncols+1):
        cell = ws.cell(row=row, column=c)
        cell.font = Font(name='Arial', bold=True, color=BLANCO, size=10)
        cell.fill = PatternFill('solid', start_color=bg)
        cell.alignment = Alignment(horizontal='center', vertical='center', wrap_text=True)
    ws.row_dimensions[row].height = 32

def write_table(ws, df, start_row=2, header_bg=GUINDA_OSC):
    for c, col in enumerate(df.columns, 1):
        ws.cell(row=start_row, column=c, value=col)
    style_header(ws, start_row, len(df.columns), bg=header_bg)
    ws.freeze_panes = f'A{start_row+1}'
    for r, row_data in enumerate(df.itertuples(index=False), start_row+1):
        bg = BLANCO if (r - start_row) % 2 == 0 else ALT_ROW
        for c, val in enumerate(row_data, 1):
            cell = ws.cell(row=r, column=c,
                value=(None if isinstance(val, float) and np.isnan(val) else val))
            cell.font = Font(name='Arial', size=9, color=GRIS)
            cell.fill = PatternFill('solid', start_color=bg)
            cell.alignment = Alignment(horizontal='left', vertical='center')
    for c, col in enumerate(df.columns, 1):
        vals = df.iloc[:,c-1].astype(str)
        w = max(len(str(col)), vals.str.len().max() if len(df)>0 else 0)
        ws.column_dimensions[get_column_letter(c)].width = min(w+3, 40)

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

# ══════════════════════════════════════════════════════
# CARGAR DATOS
# ══════════════════════════════════════════════════════
df = pd.read_excel('/mnt/user-data/uploads/sonora_maestro_v4.xlsx',
                   sheet_name='01_Maestro_Municipal', header=0)
df_coneval = pd.read_excel('/mnt/user-data/uploads/sonora_maestro_v4.xlsx',
                           sheet_name='15_CONEVAL_Pobreza', header=2)
df_coneval['cve_mun'] = df_coneval['cve_mun'].astype(str).str.lstrip('0').fillna('0').astype(int) if 'cve_mun' in df_coneval.columns else None

# Merge pct_sin_educ_basica si no está en maestro
if 'pct_sin_educ_basica' not in df.columns and 'cve_mun' in df_coneval.columns:
    df['cve_mun'] = df['cve_mun'].astype(str).str.lstrip('0').astype(int)
    if 'pct_rezago_educativo_2020' in df_coneval.columns:
        df = df.merge(df_coneval[['cve_mun','pct_rezago_educativo_2020']], on='cve_mun', how='left')

# ══════════════════════════════════════════════════════
# VARIABLES DE LA MATRIZ 5×4
# ══════════════════════════════════════════════════════
# Filas = factores educativos/sociales
row_vars = {
    'indice_marginacion':      'Índice de marginación',
    'pct_sin_educ_basica':     '% Sin educación básica',
    'pct_analfabeta_15mas':    '% Analfabetismo 15+',
    'grado_escolaridad_prom':  'Grado escolaridad prom.',
    'abs_NO_asiste_15a17':     'Jóvenes 15-17 sin escuela (abs)',
}

# Columnas = indicadores delictivos
col_vars = {
    'tasa_delitos_10k':   'Tasa delitos /10k',
    'total_detenidos':    'Total detenidos',
    'menores_detenidos':  'Menores detenidos',
    'menores_internados': 'Menores internados',
}

# Filtrar solo los disponibles en el df
row_avail = {k:v for k,v in row_vars.items() if k in df.columns}
col_avail  = {k:v for k,v in col_vars.items()  if k in df.columns}

print("Variables de fila disponibles:", list(row_avail.keys()))
print("Variables de columna disponibles:", list(col_avail.keys()))

# ══════════════════════════════════════════════════════
# CALCULAR MATRIZ DE CORRELACIONES + P-VALORES
# ══════════════════════════════════════════════════════
results_largo = []  # formato largo para Power BI
results_matrix = {} # para verificación visual

for rk, rl in row_avail.items():
    results_matrix[rl] = {}
    for ck, cl in col_avail.items():
        pair = df[[rk, ck]].dropna()
        if len(pair) >= 8:
            r, p = stats.pearsonr(pair[rk], pair[ck])
            sig = '***' if p < 0.001 else ('**' if p < 0.01 else ('*' if p < 0.05 else 'ns'))
            fuerza = 'Fuerte' if abs(r) >= 0.5 else ('Moderada' if abs(r) >= 0.3 else 'Débil')
            direccion = 'Positiva' if r > 0 else 'Negativa'
            results_matrix[rl][cl] = round(r, 3)
        else:
            r, p, sig, fuerza, direccion = np.nan, np.nan, 'nd', 'nd', 'nd'

        results_largo.append({
            'factor_social':     rl,
            'indicador_delito':  cl,
            'pearson_r':         round(r, 3) if not np.isnan(r) else None,
            'p_valor':           round(p, 4) if not np.isnan(p) else None,
            'significancia':     sig,
            'fuerza':            fuerza,
            'direccion':         direccion,
            'n_municipios':      len(pair),
            # Para formato condicional en Power BI — valor absoluto para intensidad
            'abs_r':             round(abs(r), 3) if not np.isnan(r) else None,
            # Para gradiente: +1 a -1 mapeado a 0-100
            'r_normalizado_0_100': round((r + 1) / 2 * 100, 1) if not np.isnan(r) else None,
            # Etiqueta para mostrar en la celda
            'etiqueta':          f"{r:+.3f}{sig.replace('ns','')}" if not np.isnan(r) else 'N/D',
        })

df_largo = pd.DataFrame(results_largo)

# Verificación visual
print("\n=== MATRIZ 5×4 (verificación) ===")
matrix_df = pd.DataFrame(results_matrix).T
print(matrix_df.to_string())

print("\n=== FORMATO LARGO (primeras filas) ===")
print(df_largo.to_string())

# ══════════════════════════════════════════════════════
# TAMBIÉN: Formato "ancho" — una fila por factor social,
# una columna por indicador delictivo
# Útil si quieren hacer una tabla en Power BI tipo matrix visual
# ══════════════════════════════════════════════════════
rows_wide = []
for rk, rl in row_avail.items():
    row = {'factor_social': rl, 'orden': list(row_avail.values()).index(rl) + 1}
    for ck, cl in col_avail.items():
        pair = df[[rk, ck]].dropna()
        if len(pair) >= 8:
            r, p = stats.pearsonr(pair[rk], pair[ck])
            row[f'r_{cl.replace("/","_").replace(" ","_")}'] = round(r, 3)
            row[f'sig_{cl.replace("/","_").replace(" ","_")}'] = '***' if p<0.001 else ('**' if p<0.01 else ('*' if p<0.05 else ''))
        else:
            row[f'r_{cl.replace("/","_").replace(" ","_")}'] = None
    rows_wide.append(row)
df_ancho = pd.DataFrame(rows_wide)

print("\n=== FORMATO ANCHO ===")
print(df_ancho.to_string())

# ══════════════════════════════════════════════════════
# GUARDAR CSVs
# ══════════════════════════════════════════════════════
df_largo.to_csv('/mnt/user-data/outputs/matriz_corr_5x4_largo.csv', index=False, encoding='utf-8-sig')
df_ancho.to_csv('/mnt/user-data/outputs/matriz_corr_5x4_ancho.csv', index=False, encoding='utf-8-sig')
print("\n✅ CSVs guardados!")

# ══════════════════════════════════════════════════════
# AGREGAR AL EXCEL MAESTRO
# ══════════════════════════════════════════════════════
import shutil
shutil.copy('/mnt/user-data/uploads/sonora_maestro_v4.xlsx', '/home/claude/sonora_maestro_v5.xlsx')
wb = load_workbook('/home/claude/sonora_maestro_v5.xlsx')

# Hoja 29 — formato largo (para Matrix visual en Power BI con formato condicional)
sheet_name = '29_Matriz_Corr_5x4_PBI'
if sheet_name in wb.sheetnames: del wb[sheet_name]
ws = wb.create_sheet(sheet_name)
start = add_title(ws,
    '🎯 Matriz de Correlaciones 5×4 — Educación vs Delitos',
    'Formato LARGO para Matrix Visual en Power BI · Filas=Factor Social · Columnas=Indicador Delictivo · Color por r_normalizado_0_100')
write_table(ws, df_largo, start_row=start)

# Hoja 30 — instrucciones de uso en Power BI
sheet_instrucciones = '30_Instrucciones_Matriz_PBI'
if sheet_instrucciones in wb.sheetnames: del wb[sheet_instrucciones]
ws_i = wb.create_sheet(sheet_instrucciones)
add_title(ws_i, '📋 Cómo usar la Matriz en Power BI', 'Paso a paso para crear el heatmap de correlaciones')
instrucciones = [
    ('Paso', 'Acción', 'Detalle'),
    ('1', 'Visual', 'Insertar → Matrix visual'),
    ('2', 'Rows', 'Arrastra factor_social'),
    ('3', 'Columns', 'Arrastra indicador_delito'),
    ('4', 'Values', 'Arrastra pearson_r → Average (no Sum)'),
    ('5', 'Formato condicional', 'Format → Cell elements → Background color → fx → Field value: r_normalizado_0_100'),
    ('6', 'Escala de color', 'Mínimo=0 color #1F4E79 (azul) · Máximo=100 color #6B1228 (guinda) · Centro=50 color blanco'),
    ('7', 'Font color', 'Format → Cell elements → Font color → fx → igual que paso 6 pero invertido (para que se lea)'),
    ('8', 'Etiqueta', 'En Values agrega también etiqueta → Average → así muestra r=+0.784 en la celda'),
    ('9', 'Título', '"Correlación entre factores educativos y delitos por municipio"'),
    ('10', 'Subtítulo text box', '"Valores cercanos a +1 = relación positiva fuerte · Valores cercanos a -1 = relación inversa fuerte"'),
    ('CLAVE', 'El dato contraintuitivo', 'pct_sin_educ_basica vs tasa_delitos_10k = −0.489: agrégalo en un text box grande con explicación'),
]
for r, row_data in enumerate(instrucciones, 3):
    for c, val in enumerate(row_data, 1):
        cell = ws_i.cell(row=r, column=c, value=val)
        if r == 3:
            cell.font = Font(bold=True, color=BLANCO, size=10)
            cell.fill = PatternFill('solid', start_color=GUINDA_MED)
            cell.alignment = Alignment(horizontal='center', vertical='center')
        else:
            bg = BLANCO if r % 2 == 0 else ALT_ROW
            cell.font = Font(size=9, color=GRIS)
            cell.fill = PatternFill('solid', start_color=bg)
            cell.alignment = Alignment(horizontal='left', vertical='center', wrap_text=True)
        ws_i.row_dimensions[r].height = 22
ws_i.column_dimensions['A'].width = 8
ws_i.column_dimensions['B'].width = 25
ws_i.column_dimensions['C'].width = 65

wb.save('/home/claude/sonora_maestro_v5.xlsx')
shutil.copy('/home/claude/sonora_maestro_v5.xlsx', '/mnt/user-data/outputs/sonora_maestro_v5.xlsx')
print("✅ Excel maestro v5 guardado con hojas 29 y 30!")
print(f"\nHojas finales: {wb.sheetnames}")
EOF
