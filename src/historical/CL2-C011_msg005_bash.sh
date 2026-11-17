# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=5 message_id=019db80d-52e5-78fe-82e2-fb8088c2429a sender=assistant created_at=2026-04-23T02:02:18.499691Z kind=bash
# DESCRIPTION/PATH: Add new sheets to master Excel
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
    for r, row in enumerate(df.itertuples(index=False), start_row+1):
        bg = BLANCO if (r - start_row) % 2 == 0 else ALT_ROW
        for c, val in enumerate(row, 1):
            cell = ws.cell(row=r, column=c, value=(None if (isinstance(val, float) and np.isnan(val)) else val))
            cell.font = Font(name='Arial', size=9, color=GRIS)
            cell.fill = PatternFill('solid', start_color=bg)
            cell.alignment = Alignment(horizontal='left', vertical='center')
    for c, col in enumerate(df.columns, 1):
        vals = df.iloc[:,c-1].astype(str)
        w = max(len(str(col)), vals.str.len().max() if len(df)>0 else 0)
        ws.column_dimensions[get_column_letter(c)].width = min(w + 3, 32)

def add_sheet_title(ws, title, subtitle=''):
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

# ════════ RELOAD DATA ════════
df_acled = pd.read_excel('/mnt/user-data/uploads/Latin-America-the-Caribbean_aggregated_data_up_to_week_of-2026-04-11.xlsx')
df_acled['WEEK'] = pd.to_datetime(df_acled['WEEK'])
df_acled_son = df_acled[(df_acled['COUNTRY']=='Mexico') & (df_acled['ADMIN1']=='Sonora')].copy()
df_acled_son['anio'] = df_acled_son['WEEK'].dt.year
df_acled_son['semana'] = df_acled_son['WEEK'].dt.isocalendar().week.astype(int)
df_acled_clean = df_acled_son.rename(columns={
    'WEEK':'fecha_semana','EVENT_TYPE':'tipo_evento','SUB_EVENT_TYPE':'subtipo_evento',
    'EVENTS':'num_eventos','FATALITIES':'fatalidades','POPULATION_EXPOSURE':'poblacion_expuesta',
    'DISORDER_TYPE':'tipo_desorden','ID':'id_zona','CENTROID_LATITUDE':'latitud','CENTROID_LONGITUDE':'longitud'
})[['fecha_semana','anio','semana','tipo_evento','subtipo_evento','tipo_desorden',
    'num_eventos','fatalidades','poblacion_expuesta','latitud','longitud','id_zona']]\
    .sort_values(['anio','semana']).reset_index(drop=True)

df_acled_resumen = df_acled_son.groupby(['anio','EVENT_TYPE','DISORDER_TYPE']).agg(
    total_eventos=('EVENTS','sum'), total_fatalidades=('FATALITIES','sum'), semanas=('WEEK','count')
).reset_index().rename(columns={'EVENT_TYPE':'tipo_evento','DISORDER_TYPE':'tipo_desorden'})

# CONEVAL
df_raw = pd.read_excel('/mnt/user-data/uploads/Concentrado_indicadores_de_pobreza_2020.xlsx',
                        sheet_name='Concentrado municipal', header=None)
r4=df_raw.iloc[4].tolist(); r5=df_raw.iloc[5].tolist()
combined_cols=[]; last_main=''
for h4,h5 in zip(r4,r5):
    h4s=str(h4).strip() if str(h4)!='nan' else ''; h5s=str(h5).strip() if str(h5)!='nan' else ''
    if h4s: last_main=h4s.replace('\n',' ')
    combined_cols.append(f'{last_main}__{h5s}' if h5s else last_main)
df_pob=df_raw.iloc[8:].copy(); df_pob.columns=combined_cols
df_pob_son=df_pob[df_pob['Clave de entidad']=='26'].copy()
cols_map={'Clave de municipio':'cve_mun_coneval','Municipio':'municipio',
    'Población 2020* (leer nota al final del cuadro)':'poblacion_2020',
    'Pobreza__Porcentaje\n2020':'pct_pobreza_2020','Pobreza__Personas\n2020':'personas_pobreza_2020',
    'Pobreza extrema__Porcentaje\n2020':'pct_pobreza_extrema_2020',
    'Pobreza moderada__Porcentaje\n2020':'pct_pobreza_moderada_2020',
    'Vulnerables por carencia social__Porcentaje\n2020':'pct_vulnerable_carencia_2020',
    'Vulnerables por ingreso__Porcentaje\n2020':'pct_vulnerable_ingreso_2020',
    'No pobre y no vulnerable__Porcentaje\n2020':'pct_no_pobre_2020',
    'Rezago educativo__Porcentaje\n2020':'pct_rezago_educativo_2020',
    'Carencia por acceso a los servicios de salud__Porcentaje\n2020':'pct_sin_salud_2020',
    'Carencia por acceso a la seguridad social__Porcentaje\n2020':'pct_sin_seg_social_2020',
    'Carencia por calidad y espacios de la vivienda__Porcentaje\n2020':'pct_carencia_vivienda_2020',
    'Carencia por acceso a los servicios básicos en la vivienda__Porcentaje\n2020':'pct_sin_servicios_basicos_2020',
    'Carencia por acceso a la alimentación__Porcentaje\n2020':'pct_carencia_alimentacion_2020',
    'Población con al menos una carencia social__Porcentaje\n2020':'pct_al_menos_una_carencia_2020',
    'Población con tres o más carencias sociales__Porcentaje\n2020':'pct_3mas_carencias_2020',}
existing={k:v for k,v in cols_map.items() if k in df_pob_son.columns}
df_coneval=df_pob_son[list(existing.keys())].rename(columns=existing).reset_index(drop=True)
df_coneval['cve_mun']=df_coneval['cve_mun_coneval'].astype(str).str[-3:].astype(int)

# IRS
df_irs=pd.read_csv('/mnt/user-data/uploads/irs_municipal_2020.csv')
df_irs_son=df_irs[df_irs['clave_entidad']==26].copy()
df_irs_son=df_irs_son.rename(columns={'clave_municipio':'cve_mun_irs','municipio':'municipio_irs',
    'poblacion':'poblacion_irs','irs':'indice_rezago_social','grs':'grado_rezago_social'})
df_irs_son['cve_mun']=df_irs_son['cve_mun_irs'].astype(str).str[-3:].astype(int)
irs_cols=['cve_mun','municipio_irs','poblacion_irs','i_analf','i_asistesc','i_edbasinc',
    'i_sdsalud','i_ptierra','i_nosan','i_noagua','i_nodren','i_noelec','i_nolav',
    'i_noref','indice_rezago_social','grado_rezago_social']
df_irs_son=df_irs_son[[c for c in irs_cols if c in df_irs_son.columns]].reset_index(drop=True)
mun_names=df_irs_son[['cve_mun','municipio_irs']].rename(columns={'municipio_irs':'municipio'})

# Rezago habitacional
df_rh15=pd.read_csv('/mnt/user-data/uploads/02_rezago_habitacional_mun_2015.csv')
df_rh20=pd.read_csv('/mnt/user-data/uploads/03_rezago_habitacional_mun_2020.csv')
df_rh15_son=df_rh15[df_rh15['clave_entidad_federativa']==26].copy()
df_rh20_son=df_rh20[df_rh20['clave_entidad_federativa']==26].copy()
for df_ in [df_rh15_son,df_rh20_son]:
    df_['total_viviendas']=df_['con_rezago']+df_['sin_rezago']
    df_['pct_rezago_habitacional']=(df_['con_rezago']/df_['total_viviendas']*100).round(2)
    df_['cve_mun']=df_['clave_municipio'].astype(str).str[-3:].astype(int)
df_rh_merged=df_rh20_son[['cve_mun','con_rezago','sin_rezago','total_viviendas','pct_rezago_habitacional']]\
    .rename(columns={'con_rezago':'con_rezago_2020','sin_rezago':'sin_rezago_2020',
        'total_viviendas':'total_viviendas_2020','pct_rezago_habitacional':'pct_rezago_hab_2020'})\
    .merge(df_rh15_son[['cve_mun','con_rezago','sin_rezago','total_viviendas','pct_rezago_habitacional']]\
        .rename(columns={'con_rezago':'con_rezago_2015','sin_rezago':'sin_rezago_2015',
            'total_viviendas':'total_viviendas_2015','pct_rezago_habitacional':'pct_rezago_hab_2015'}),
        on='cve_mun', how='outer')
df_rh_merged=df_rh_merged.merge(mun_names,on='cve_mun',how='left')
cols_rh=['cve_mun','municipio','pct_rezago_hab_2015','pct_rezago_hab_2020',
    'con_rezago_2015','con_rezago_2020','sin_rezago_2015','sin_rezago_2020']
df_rh_merged=df_rh_merged[[c for c in cols_rh if c in df_rh_merged.columns]]

# Viviendas precarias
df_vp=pd.read_csv('/mnt/user-data/uploads/01_viviendas_precarias_SIODS.csv')
df_vp_son_2020=df_vp[(df_vp['entidad_federativa'].str.lower().str.contains('sonora',na=False)) &
    (df_vp['municipio']!='sin dato') & (df_vp['cve_geo']!=26) & (df_vp['periodo']==2020)].copy()
df_vp_son_2020['cve_mun']=df_vp_son_2020['cve_geo'].astype(str).str[-3:].astype(int)
df_vp_son_2020=df_vp_son_2020[['cve_mun','municipio','proporcion_poblacion']]\
    .rename(columns={'proporcion_poblacion':'pct_poblacion_vivienda_precaria_2020'}).reset_index(drop=True)

# ════════ CARGAR EXCEL MAESTRO Y AGREGAR HOJAS ════════
wb = load_workbook('/home/claude/sonora_seguridad_powerbi.xlsx')
existing_sheets = wb.sheetnames
print("Hojas actuales:", existing_sheets)

new_sheets = [
    ('13_ACLED_Sonora_Detalle', df_acled_clean, '🔴 ACLED – Violencia Geolocalizada Sonora (Detalle Semanal)', 'Fuente: ACLED 2017-2026 | Eventos de violencia política y civil en Sonora por semana'),
    ('14_ACLED_Resumen_Anual', df_acled_resumen, '📊 ACLED – Resumen Anual por Tipo de Evento', 'Fuente: ACLED 2017-2026 | Agregado anual para gráficas de tendencia'),
    ('15_CONEVAL_Pobreza', df_coneval, '💰 CONEVAL – Indicadores de Pobreza Municipal 2020', 'Fuente: CONEVAL 2020 | Medición multidimensional de pobreza en Sonora'),
    ('16_IRS_Rezago_Social', df_irs_son, '🏘️ CONEVAL – Índice de Rezago Social Municipal 2020', 'Fuente: CONEVAL 2020 | Carencias en educación, salud, vivienda y servicios'),
    ('17_Rezago_Habitacional', df_rh_merged, '🏠 CONEVAL – Rezago Habitacional 2015 vs 2020', 'Fuente: CONEVAL | Viviendas con rezago en calidad y espacios por municipio'),
    ('18_Viviendas_Precarias', df_vp_son_2020, '🏚️ SEDATU – Viviendas Precarias 2020', 'Fuente: SEDATU/SIODS 2020 | Proporción de población en vivienda precaria'),
]

for sheet_name, df, title, subtitle in new_sheets:
    ws = wb.create_sheet(sheet_name)
    start = add_sheet_title(ws, title, subtitle)
    write_table(ws, df, start_row=start)
    print(f"  ✓ {sheet_name} añadida al maestro ({len(df)} filas)")

wb.save('/home/claude/sonora_seguridad_powerbi.xlsx')
print(f"\n✅ Excel maestro actualizado: {len(wb.sheetnames)} hojas en total")
print("Hojas:", wb.sheetnames)
EOF
