# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=51 message_id=019dc342-a35c-7238-bbe3-adbe45c3ee63 sender=assistant created_at=2026-04-25T06:12:13.751451Z kind=bash
# DESCRIPTION/PATH: Process Google Trends data and build narco artist sheets for Power BI
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
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
            cell = ws.cell(row=r, column=c,
                value=(None if isinstance(val, float) and np.isnan(val) else val))
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

# ══════════════════════════════════════════════════════
# CARGAR DATOS
# ══════════════════════════════════════════════════════
df_semanal = pd.read_excel('/mnt/user-data/uploads/google_trends_sonora_narco_1_.xlsx',
                            sheet_name='01_Maestro_Semanal_Limpio', header=0)
df_largo   = pd.read_excel('/mnt/user-data/uploads/google_trends_sonora_narco_1_.xlsx',
                            sheet_name='02_Terminos_Largo', header=0)
df_anual   = pd.read_excel('/mnt/user-data/uploads/google_trends_sonora_narco_1_.xlsx',
                            sheet_name='03_Indices_Anual', header=0)

# Narcomenudeo anual para cruzar
df_sesnsp = pd.read_excel('/mnt/user-data/uploads/sonora_maestro_v4.xlsx',
                           sheet_name='03_SESNSP_2020_2025', header=0)
narco_anual = df_sesnsp[df_sesnsp['tipo_delito']=='Narcomenudeo']\
    .groupby('año')['casos'].sum().reset_index(name='NarcomenudeoSESNSP')

print("Columnas semanal:", list(df_semanal.columns))
print("Años disponibles:", df_semanal['año'].unique())
print("Términos en largo:", df_largo['termino'].unique())

# ══════════════════════════════════════════════════════
# HOJA A — ARTISTAS CON REFERENCIA A NARCO/SUSTANCIAS
# Solo los artistas cuyas canciones tienen referencias explícitas
# ══════════════════════════════════════════════════════

# Artistas con referencias a narco/sustancias en sus canciones más populares:
# - Natanael Cano: "Amor Tumbado" (consumo), "El Drip" (narco)
# - Peso Pluma: "El Belicón" (narco), "Lady Gaga" (sustancias)
# - Junior H: "El Azul" (referencia a El Chapo), "Santo Patrono"
# - Gabito Ballesteros: "La Pared" (narco), colaboraciones explícitas
# - Fuerza Regida: "Ch y la Pizza" (sustancias), "Radicamos en South Central"

artistas_narco = ['Natanael Cano', 'peso pluma', 'Junior H', 'Gabito Ballesteros', 'fuerza regida']
referencias = {
    'Natanael Cano':     'Amor Tumbado, El Drip — referencias a consumo y narcoestilo',
    'peso pluma':        'El Belicón, Lady Gaga — apología al narco y sustancias',
    'Junior H':          'El Azul, Santo Patrono — referencias directas a figuras del narco',
    'Gabito Ballesteros':'La Pared, El Azul — glorificación del narco',
    'fuerza regida':     'Ch y la Pizza, Radicamos — referencias a drogas y estilo de vida narco',
}

# Filtrar solo artistas con referencia narco del largo
df_artistas = df_largo[df_largo['termino'].isin(artistas_narco)].copy()
df_artistas['termino'] = df_artistas['termino'].str.title()
df_artistas['referencia_narco'] = df_artistas['termino'].map(
    {k.title():v for k,v in referencias.items()})
df_artistas['año'] = df_artistas['año'].astype(int)
df_artistas['Semana'] = pd.to_datetime(df_artistas['Semana'])

print(f"\nArtistas narco — filas: {len(df_artistas)}")
print(df_artistas.groupby(['año','termino'])['interes_relativo'].mean().round(1))

# ══════════════════════════════════════════════════════
# HOJA B — ARTISTAS ANUAL con narcomenudeo para line chart
# Formato largo: año, serie, valor
# ══════════════════════════════════════════════════════
rows_pbi = []

# Narcomenudeo real (solo 2021-2025 para coincidir con trends)
for _, row in narco_anual[narco_anual['año'] >= 2021].iterrows():
    rows_pbi.append({
        'año': int(row['año']),
        'serie': 'Narcomenudeo (SESNSP)',
        'valor': int(row['NarcomenudeoSESNSP']),
        'tipo': 'Delito real',
        'eje': 'Izquierdo'
    })

# Índices anuales de Google Trends
for _, row in df_anual[df_anual['año'] >= 2021].iterrows():
    yr = int(row['año'])
    # Artistas con referencia narco
    for col, nombre in [('Natanael Cano','Natanael Cano'), ('peso pluma','Peso Pluma'),
                         ('Junior H','Junior H'), ('Gabito Ballesteros','Gabito Ballesteros')]:
        if col in df_anual.columns:
            rows_pbi.append({
                'año': yr,
                'serie': nombre,
                'valor': round(float(row[col]), 2),
                'tipo': 'Artista narco (Google Trends)',
                'eje': 'Derecho'
            })
    # Índice corridos tumbados
    rows_pbi.append({
        'año': yr,
        'serie': 'Índice Corridos Tumbados',
        'valor': round(float(row['idx_corridos_tumbados']), 2),
        'tipo': 'Índice cultural',
        'eje': 'Derecho'
    })

df_pbi = pd.DataFrame(rows_pbi)
print(f"\nFormato largo PBI: {len(df_pbi)} filas")
print(df_pbi.groupby(['año','tipo'])['valor'].mean().round(1))

# ══════════════════════════════════════════════════════
# HOJA C — SEMANAL ARTISTAS NARCO (para drill-down)
# ══════════════════════════════════════════════════════
cols_keep = ['Semana', 'año', 'mes', 'trimestre',
             'Natanael Cano', 'peso pluma', 'Junior H',
             'Gabito Ballesteros', 'fuerza regida',
             'idx_corridos_tumbados', 'idx_narco_violencia']
df_semanal_clean = df_semanal[[c for c in cols_keep if c in df_semanal.columns]].copy()
df_semanal_clean = df_semanal_clean.rename(columns={
    'peso pluma': 'Peso Pluma',
    'fuerza regida': 'Fuerza Regida'
})
df_semanal_clean['Semana'] = pd.to_datetime(df_semanal_clean['Semana'])

# Agregar narcomenudeo mensual para cruzar
df_narco_mes = df_sesnsp[df_sesnsp['tipo_delito']=='Narcomenudeo']\
    .groupby(['año','mes'])['casos'].sum().reset_index(name='NarcomenudeoSESNSP')
mes_map = {'Enero':1,'Febrero':2,'Marzo':3,'Abril':4,'Mayo':5,'Junio':6,
           'Julio':7,'Agosto':8,'Septiembre':9,'Octubre':10,'Noviembre':11,'Diciembre':12}
df_narco_mes['mes_num'] = df_narco_mes['mes'].map(mes_map)

print(f"\nSemanal limpio: {df_semanal_clean.shape}")

# ══════════════════════════════════════════════════════
# DICCIONARIO DE REFERENCIAS NARCO
# ══════════════════════════════════════════════════════
df_referencias = pd.DataFrame([
    {'artista': 'Natanael Cano', 'canciones_referencia': 'Amor Tumbado, El Drip, Soy El Diablo',
     'tipo_referencia': 'Consumo de sustancias, estilo de vida narco',
     'nota': 'Pionero del corrido tumbado, normaliza consumo en letra y estética'},
    {'artista': 'Peso Pluma', 'canciones_referencia': 'El Belicón, Lady Gaga, Bzrp Session 55',
     'tipo_referencia': 'Apología al narco, sustancias, violencia',
     'nota': 'Boom 2023 — búsquedas en Sonora x3.5 en un año'},
    {'artista': 'Junior H', 'canciones_referencia': 'El Azul, Santo Patrono, El Morón',
     'tipo_referencia': 'Referencias directas a figuras del narco (El Chapo)',
     'nota': 'Artista con mayor constancia en Google Trends Sonora 2021-2025'},
    {'artista': 'Gabito Ballesteros', 'canciones_referencia': 'La Pared, El Azul (ft Junior H)',
     'tipo_referencia': 'Glorificación del narco, violencia organizada',
     'nota': 'Crecimiento sostenido 2023-2024 en Sonora'},
    {'artista': 'Fuerza Regida', 'canciones_referencia': 'Ch y la Pizza, Radicamos en South Central',
     'tipo_referencia': 'Referencias explícitas a drogas',
     'nota': 'Término descartado por volumen bajo en Sonora, pero incluido por relevancia cultural'},
])

# ══════════════════════════════════════════════════════
# GUARDAR EN EXCEL MAESTRO
# ══════════════════════════════════════════════════════
import shutil
shutil.copy('/home/claude/sonora_maestro_v5.xlsx', '/home/claude/sonora_maestro_v6.xlsx')
wb = load_workbook('/home/claude/sonora_maestro_v6.xlsx')

sheets_new = [
    ('31_GoogleTrends_Artistas_PBI', df_pbi,
     '🎵 Google Trends — Artistas Narco vs Narcomenudeo (Formato largo Power BI)',
     'X=año · Y=valor · Legend=serie · Eje izquierdo=Narcomenudeo · Eje derecho=Artistas'),
    ('32_GoogleTrends_Semanal', df_semanal_clean,
     '📅 Google Trends — Búsquedas Semanales por Artista (Sonora 2021-2026)',
     'Para drill-down en Power BI — granularidad semanal'),
    ('33_Referencias_Narco_Canciones', df_referencias,
     '🎶 Canciones con Referencias al Narco — Contexto Cultural',
     'Fundamento cualitativo del argumento cultural · Para text box o tabla en el dashboard'),
]

for sheet_name, df_sheet, title, subtitle in sheets_new:
    if sheet_name in wb.sheetnames: del wb[sheet_name]
    ws = wb.create_sheet(sheet_name)
    start = add_title(ws, title, subtitle)
    write_table(ws, df_sheet, start_row=start)
    print(f"  ✓ {sheet_name}: {len(df_sheet)} filas")

wb.save('/home/claude/sonora_maestro_v6.xlsx')
shutil.copy('/home/claude/sonora_maestro_v6.xlsx', '/mnt/user-data/outputs/sonora_maestro_v6.xlsx')
print("\n✅ Excel maestro v6 listo!")
EOF
