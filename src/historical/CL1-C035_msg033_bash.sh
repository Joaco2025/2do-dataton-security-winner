# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=33 message_id=019db2a6-58e0-7207-bfd1-be0045cea2c3 sender=assistant created_at=2026-04-22T00:47:00.144567Z kind=bash
# DESCRIPTION/PATH: Actualizar Excel con columnas nuevas de 15-17 no asisten
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from pathlib import Path
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils.dataframe import dataframe_to_rows

UP  = Path("/mnt/user-data/uploads")
OUT = Path("/mnt/user-data/outputs")

C_GUINDA  = "6B1228"
C_GUINDA2 = "9B1D3A"
C_DORADO  = "D4A017"
C_GRIS    = "3D3D3D"
C_BLANCO  = "FFFFFF"

def num_cols(df, cols):
    for c in cols:
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0)
    return df

def estilo_header(ws, n_cols, color=C_GUINDA):
    for col in range(1, n_cols + 1):
        cell = ws.cell(row=1, column=col)
        cell.font      = Font(bold=True, color=C_BLANCO, name="Arial", size=10)
        cell.fill      = PatternFill("solid", fgColor=color)
        cell.alignment = Alignment(horizontal="center", vertical="center")
    ws.row_dimensions[1].height = 20

def escribir_hoja(wb, nombre, df, color=C_GUINDA):
    ws = wb.create_sheet(nombre)
    for r in dataframe_to_rows(df, index=False, header=True):
        ws.append(r)
    estilo_header(ws, len(df.columns), color)
    for col in ws.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        ws.column_dimensions[col[0].column_letter].width = min(max_len + 3, 40)
    return ws

# ── Reconstruir maestro completo con columnas nuevas ────────────────────────
iter_raw = pd.read_csv(UP / "conjunto_de_datos_iter_26CSV20.csv", encoding="latin-1")
iter_mun = iter_raw[(iter_raw["LOC"] == 0) & (iter_raw["MUN"] != 0)].copy()
iter_mun = num_cols(iter_mun, ["P_3A5","P3A5_NOA","P_6A11","P6A11_NOA",
    "P_12A14","P12A14NOA","P_15A17","P15A17A","P_15YMAS",
    "P15YM_AN","GRAPROES","P15YM_SE","P18YM_PB","POBTOT"])

iter_mun["pct_no_asiste_3a5"]    = (iter_mun["P3A5_NOA"]  / iter_mun["P_3A5"]    * 100).round(2)
iter_mun["pct_no_asiste_6a11"]   = (iter_mun["P6A11_NOA"] / iter_mun["P_6A11"]   * 100).round(2)
iter_mun["pct_no_asiste_12a14"]  = (iter_mun["P12A14NOA"] / iter_mun["P_12A14"]  * 100).round(2)
iter_mun["pct_asiste_15a17"]     = (iter_mun["P15A17A"]   / iter_mun["P_15A17"]  * 100).round(2)
# ── NUEVAS ──────────────────────────────────────────────────────────────────
iter_mun["pct_NO_asiste_15a17"]  = (100 - iter_mun["pct_asiste_15a17"]).round(2)
iter_mun["abs_NO_asiste_15a17"]  = (iter_mun["P_15A17"] - iter_mun["P15A17A"]).astype(int)
# ────────────────────────────────────────────────────────────────────────────
iter_mun["pct_analfabeta_15mas"] = (iter_mun["P15YM_AN"]  / iter_mun["P_15YMAS"] * 100).round(2)
iter_mun["pct_sin_escolaridad"]  = (iter_mun["P15YM_SE"]  / iter_mun["P_15YMAS"] * 100).round(2)
iter_mun["pct_posbasica_18mas"]  = (iter_mun["P18YM_PB"]  / iter_mun["POBTOT"]   * 100).round(2)
iter_mun["cve_mun"]              = iter_mun["MUN"].astype(str).str.zfill(3)
iter_mun["municipio"]            = iter_mun["NOM_MUN"].str.strip().str.title()
iter_mun["poblacion_total"]      = iter_mun["POBTOT"]
iter_mun["grado_escolaridad_prom"] = iter_mun["GRAPROES"]

ITER = iter_mun[["cve_mun","municipio","poblacion_total","grado_escolaridad_prom",
                  "pct_no_asiste_3a5","pct_no_asiste_6a11","pct_no_asiste_12a14",
                  "pct_asiste_15a17","pct_NO_asiste_15a17","abs_NO_asiste_15a17",
                  "pct_analfabeta_15mas","pct_sin_escolaridad","pct_posbasica_18mas"]].copy()

marg_raw = pd.read_excel(UP / "indice-de-marginacion-municipios-2020.xlsx")
marg_raw.columns = marg_raw.columns.str.strip()
c = marg_raw.columns.tolist()
MARG = marg_raw.rename(columns={
    c[0]:"clave_inegi", c[1]:"municipio_marg",
    c[4]:"pct_sin_educ_basica", c[5]:"pct_sin_drenaje",
    c[6]:"pct_sin_electricidad", c[7]:"pct_sin_agua",
    c[8]:"pct_piso_tierra", c[9]:"pct_hacinamiento",
    c[10]:"pct_localidad_pequeña", c[11]:"pct_ingreso_bajo_2sm",
    c[12]:"indice_marginacion", c[13]:"grado_marginacion",
    c[14]:"indice_marginacion_norm",
})
MARG["cve_mun"] = MARG["clave_inegi"].astype(str).str[-3:].str.zfill(3)
MARG["municipio_marg"] = MARG["municipio_marg"].str.strip().str.title()
MARG = MARG[["cve_mun","municipio_marg","pct_sin_educ_basica","pct_sin_drenaje",
              "pct_sin_electricidad","pct_sin_agua","pct_piso_tierra","pct_hacinamiento",
              "pct_localidad_pequeña","pct_ingreso_bajo_2sm","indice_marginacion",
              "grado_marginacion","indice_marginacion_norm"]]

del_son = pd.read_excel(UP / "DELITOS_DEL_2020_AL_2025.xlsx")
del_son.columns = del_son.columns.str.strip()
del_son["municipio"] = del_son["Municipio"].str.strip().str.title()
tipos = [c for c in del_son.columns if c not in ["Municipio","Año","municipio"]]
DELITOS_TIEMPO = del_son.melt(id_vars=["municipio","Año"], value_vars=tipos,
    var_name="tipo_delito", value_name="num_delitos").rename(columns={"Año":"año"})
DELITOS_MUN = del_son.groupby("municipio")[tipos].sum().reset_index()
DELITOS_MUN["total_delitos_sonora"] = DELITOS_MUN[tipos].sum(axis=1)

sesnsp = pd.read_csv(UP / "sesnsp_largo_2015_2025.csv", encoding="utf-8")
sesnsp.columns = sesnsp.columns.str.strip()
sesnsp["cve_mun"] = sesnsp["Cve. Municipio"].astype(str).str[-3:].str.zfill(3)
SESNSP_LARGO = sesnsp[["Año","cve_mun","Bien jurídico afectado",
                         "Tipo de delito","Subtipo de delito","Mes","Casos"]].copy()
SESNSP_LARGO.columns = ["año","cve_mun","bien_juridico","tipo_delito","subtipo_delito","mes","casos"]
sesnsp_20 = sesnsp[sesnsp["Año"] >= 2020].copy()
SESNSP_MUN  = sesnsp_20.groupby("cve_mun")["Casos"].sum().reset_index()
SESNSP_MUN.columns = ["cve_mun","total_delitos_sesnsp"]
SESNSP_TIPO = sesnsp_20.groupby(["cve_mun","Tipo de delito"])["Casos"].sum().reset_index()
SESNSP_TIPO.columns = ["cve_mun","tipo_delito","casos"]

det = pd.read_excel(UP / "Personas_Detenidas_en_el_primer_trimestre_2026.xlsx")
det.columns = det.columns.str.strip()
det["fecha"]     = pd.to_datetime(det["fecha_parte"], errors="coerce").dt.date
det["municipio"] = det["municipio"].str.strip().str.title()
det["edad"]      = pd.to_numeric(det["edad"], errors="coerce")
det["es_menor"]  = det["edad"] < 18
DET_MUN = det.groupby("municipio").agg(
    total_detenidos=("municipio","count"),
    menores_detenidos=("es_menor","sum"),
    edad_promedio_det=("edad","mean")
).reset_index()
DET_MUN["edad_promedio_det"] = DET_MUN["edad_promedio_det"].round(1)
DET_MUN["pct_menores_det"]   = (DET_MUN["menores_detenidos"] / DET_MUN["total_detenidos"] * 100).round(2)
DET_LIMPIO = det[["fecha","municipio","sexo","delito","edad","es_menor","motivo del origen"]].copy()
DET_LIMPIO.columns = ["fecha","municipio","sexo","delito","edad","es_menor","motivo_origen"]

itama = pd.read_excel(UP / "poblacion-itama-internamiento-1-trimestre-2026.xlsx",
                      sheet_name="POBLACION INTERNAMIENTO")
itama.columns = itama.columns.str.strip()
def cat_delito(d):
    d = str(d).lower()
    if "narco" in d or "salud" in d:           return "Narcomenudeo/Salud"
    if "robo" in d:                             return "Robo"
    if "homicidio" in d or "feminicidio" in d: return "Homicidio"
    if "portación" in d or "arma" in d:        return "Armas"
    if "lesion" in d:                           return "Lesiones"
    return "Otro"
itama["categoria_delito"] = itama["DELITO"].apply(cat_delito)
itama["municipio"] = itama["LOCALIDAD DEL DELITO"].str.split(",").str[0].str.strip().str.title()
ITAMA = itama[["SEXO","EDAD ACTUAL","municipio","DELITO","categoria_delito"]].copy()
ITAMA.columns = ["sexo","edad","municipio","delito_completo","categoria_delito"]
ITAMA_MUN = ITAMA.groupby("municipio").agg(menores_internados=("municipio","count")).reset_index()

# ── Merge maestro ────────────────────────────────────────────────────────────
maestro = ITER.merge(MARG, on="cve_mun", how="left")
maestro = maestro.merge(DELITOS_MUN[["municipio","total_delitos_sonora"] + tipos], on="municipio", how="left")
maestro = maestro.merge(SESNSP_MUN, on="cve_mun", how="left")
maestro = maestro.merge(DET_MUN, on="municipio", how="left")
maestro = maestro.merge(ITAMA_MUN, on="municipio", how="left")

for col in ["total_delitos_sonora","total_delitos_sesnsp","total_detenidos",
            "menores_detenidos","menores_internados","pct_menores_det"]:
    if col in maestro.columns:
        maestro[col] = maestro[col].fillna(0)

maestro["tasa_delitos_10k"]   = (maestro["total_delitos_sesnsp"] / maestro["poblacion_total"] * 10000).round(2)
maestro["tasa_detenidos_10k"] = (maestro["total_detenidos"]      / maestro["poblacion_total"] * 10000).round(2)
maestro["nivel_marginacion"]  = maestro["grado_marginacion"].fillna("Sin datos")

# ── Correlaciones actualizadas ────────────────────────────────────────────────
cols_corr = [c for c in [
    "indice_marginacion","pct_sin_educ_basica","pct_analfabeta_15mas",
    "grado_escolaridad_prom","pct_no_asiste_12a14",
    "pct_NO_asiste_15a17","abs_NO_asiste_15a17",   # ← nuevas
    "pct_ingreso_bajo_2sm","tasa_delitos_10k",
    "tasa_detenidos_10k","total_detenidos",
    "menores_detenidos","menores_internados"
] if c in maestro.columns]
corr_df = maestro[cols_corr].corr().round(3).reset_index().rename(columns={"index":"variable"})

# ── Diccionario actualizado ───────────────────────────────────────────────────
dicc = pd.DataFrame([
    ["cve_mun",               "Clave de 3 dígitos del municipio (INEGI)",          "INEGI Censo 2020"],
    ["municipio",             "Nombre oficial del municipio",                       "INEGI/CONAPO"],
    ["poblacion_total",       "Población total Censo 2020",                         "ITER Censo 2020"],
    ["grado_escolaridad_prom","Años promedio de escolaridad (15+)",                 "ITER Censo 2020"],
    ["pct_no_asiste_3a5",     "% niños 3-5 años que NO asisten a escuela",          "ITER Censo 2020"],
    ["pct_no_asiste_6a11",    "% niños 6-11 años que NO asisten",                   "ITER Censo 2020"],
    ["pct_no_asiste_12a14",   "% jóvenes 12-14 años que NO asisten (secundaria)",   "ITER Censo 2020"],
    ["pct_asiste_15a17",      "% jóvenes 15-17 años que SÍ asisten (media sup.)",   "ITER Censo 2020"],
    ["pct_NO_asiste_15a17",   "% jóvenes 15-17 años que NO asisten — 100 menos pct_asiste_15a17", "ITER Censo 2020"],
    ["abs_NO_asiste_15a17",   "Número ABSOLUTO de jóvenes 15-17 que NO asisten",    "ITER Censo 2020"],
    ["pct_analfabeta_15mas",  "% población 15+ analfabeta",                         "ITER Censo 2020"],
    ["pct_sin_escolaridad",   "% población 15+ sin ningún grado escolar",           "ITER Censo 2020"],
    ["indice_marginacion",    "Índice de marginación numérico CONAPO",               "CONAPO 2020"],
    ["grado_marginacion",     "Grado: Muy bajo / Bajo / Medio / Alto / Muy alto",   "CONAPO 2020"],
    ["indice_marginacion_norm","Índice normalizado 0-1 para comparación",            "CONAPO 2020"],
    ["pct_sin_educ_basica",   "% de 15+ sin educación básica completa",             "CONAPO 2020"],
    ["pct_ingreso_bajo_2sm",  "% ocupados con menos de 2 salarios mínimos",         "CONAPO 2020"],
    ["total_delitos_sonora",  "Total delitos 2020-2025 (tipos específicos)",         "Gobierno Sonora"],
    ["total_delitos_sesnsp",  "Total delitos 2020-2025 (todos los tipos)",           "SESNSP"],
    ["tasa_delitos_10k",      "Delitos SESNSP por cada 10,000 habitantes",           "Calculado"],
    ["total_detenidos",       "Personas detenidas 1er trimestre 2026",               "Gobierno Sonora"],
    ["menores_detenidos",     "Detenidos menores de 18 años (1T2026)",               "Gobierno Sonora"],
    ["pct_menores_det",       "% del total de detenidos que son menores de edad",    "Calculado"],
    ["tasa_detenidos_10k",    "Detenidos por cada 10,000 habitantes",                "Calculado"],
    ["menores_internados",    "Menores internados en ITAMA 1er trimestre 2026",      "ITAMA Sonora"],
], columns=["columna","descripcion","fuente"])

# ── Exportar Excel ────────────────────────────────────────────────────────────
from openpyxl import Workbook
wb = Workbook()
wb.remove(wb.active)

escribir_hoja(wb, "01_Maestro_Municipal",     maestro,          C_GUINDA)
escribir_hoja(wb, "02_Delitos_Tiempo",        DELITOS_TIEMPO,   C_GUINDA2)
escribir_hoja(wb, "03_SESNSP_2020_2025",      SESNSP_LARGO[SESNSP_LARGO["año"]>=2020], C_GUINDA2)
escribir_hoja(wb, "04_SESNSP_Tipo_Municipio", SESNSP_TIPO,      C_GUINDA2)
escribir_hoja(wb, "05_Personas_Detenidas",    DET_LIMPIO,       C_GUINDA)
escribir_hoja(wb, "06_ITAMA_Menores",         ITAMA,            C_GUINDA)
escribir_hoja(wb, "07_Correlaciones",         corr_df,          C_DORADO)
escribir_hoja(wb, "08_Diccionario",           dicc,             C_GRIS)

ruta = OUT / "sonora_seguridad_powerbi.xlsx"
wb.save(ruta)

print(f"✅ Excel actualizado: {ruta}")
print(f"   Columnas nuevas en maestro: pct_NO_asiste_15a17, abs_NO_asiste_15a17")
print(f"   Maestro: {len(maestro)} municipios x {len(maestro.columns)} columnas")
print()
print("📊 Top 10 municipios por jóvenes 15-17 sin escuela (absoluto):")
top = maestro[["municipio","abs_NO_asiste_15a17","pct_NO_asiste_15a17",
               "menores_detenidos","menores_internados"]].nlargest(10,"abs_NO_asiste_15a17")
print(top.to_string(index=False))
EOF
