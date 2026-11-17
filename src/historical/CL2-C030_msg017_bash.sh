# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=17 message_id=019dbe11-c1ae-70bd-b025-e92dcfc7928e sender=assistant created_at=2026-04-24T05:59:52.596044Z kind=bash
# DESCRIPTION/PATH: Rebuild sheet 24 in long format for Power BI line chart with legend
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from sklearn.linear_model import LinearRegression
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

GUINDA_OSC = "6B1228"; GUINDA_MED = "9B1D3A"; CREMA = "F5F0E8"
GRIS = "3D3D3D"; BLANCO = "FFFFFF"; ALT_ROW = "F9F5F6"

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

# ═══════════════════════════════════════════════
# CARGAR Y PREPARAR
# ═══════════════════════════════════════════════
df_sesnsp = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='03_SESNSP_2020_2025', header=0)

narco = df_sesnsp[df_sesnsp['tipo_delito']=='Narcomenudeo'].groupby('año')['casos'].sum()
robo  = df_sesnsp[df_sesnsp['tipo_delito']=='Robo'].groupby('año')['casos'].sum()

# Modelos
años = np.array([2020,2021,2022,2023,2024,2025]).reshape(-1,1)
m_narco = LinearRegression().fit(años, narco.values)
m_robo  = LinearRegression().fit(años, robo.values)

# ═══════════════════════════════════════════════
# FORMATO LARGO — Una fila por (año, serie, tipo)
# Power BI Line chart: X=año, Y=casos, Legend=serie
# ═══════════════════════════════════════════════
rows = []

# Datos reales
for yr in [2020,2021,2022,2023,2024,2025]:
    rows.append({'año': yr, 'casos': int(narco[yr]), 'serie': 'Narcomenudeo (real)',      'tipo': 'Real'})
    rows.append({'año': yr, 'casos': int(robo[yr]),  'serie': 'Robo (real)',               'tipo': 'Real'})

# Línea de tendencia completa (2020-2028) para ambas series
for yr in range(2020, 2029):
    pred_n = max(0, round(m_narco.predict([[yr]])[0]))
    pred_r = max(0, round(m_robo.predict([[yr]])[0]))
    rows.append({'año': yr, 'casos': int(pred_n), 'serie': 'Narcomenudeo (tendencia)', 'tipo': 'Proyección' if yr > 2025 else 'Tendencia'})
    rows.append({'año': yr, 'casos': int(pred_r), 'serie': 'Robo (tendencia)',          'tipo': 'Proyección' if yr > 2025 else 'Tendencia'})

df_largo = pd.DataFrame(rows).sort_values(['serie','año']).reset_index(drop=True)

print("Vista previa formato largo:")
print(df_largo.to_string())
print(f"\nSeries únicas: {df_largo['serie'].unique()}")
print("→ En Power BI: X=año, Y=casos, Legend=serie")
print("→ Verás 4 líneas: 2 reales (sólidas) + 2 tendencia (punteadas)")

# ═══════════════════════════════════════════════
# GUARDAR — reemplazar hoja 24
# ═══════════════════════════════════════════════
wb = load_workbook('/home/claude/sonora_seguridad_powerbi.xlsx')

if '24_Proyeccion_Narco_ML' in wb.sheetnames:
    del wb['24_Proyeccion_Narco_ML']

ws24 = wb.create_sheet('24_Proyeccion_Narco_ML')
start = add_title(ws24,
    '🤖 Modelo Predictivo – Proyección Narcomenudeo vs Robo 2026-2028',
    'Formato largo para Line chart en Power BI · X=año · Y=casos · Legend=serie · Regresión Lineal OLS · R²(narco)=0.60 · R²(robo)=0.92')
write_table(ws24, df_largo, start_row=start)

wb.save('/home/claude/sonora_seguridad_powerbi.xlsx')
import shutil
shutil.copy('/home/claude/sonora_seguridad_powerbi.xlsx', '/mnt/user-data/outputs/sonora_seguridad_powerbi.xlsx')
print("\n✅ Hoja 24 reemplazada con formato largo listo para Line chart!")
EOF
