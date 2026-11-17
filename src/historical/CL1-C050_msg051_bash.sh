# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=51 message_id=019db6de-110c-7f45-8576-dafa11e444ca sender=assistant created_at=2026-04-22T20:27:07.279546Z kind=bash
# DESCRIPTION/PATH: Generar correlaciones en formato largo para Power BI heatmap
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
C_BLANCO  = "FFFFFF"

# Reconstruir maestro rápido para tener las correlaciones
iter_raw = pd.read_csv(UP / "conjunto_de_datos_iter_26CSV20.csv", encoding="latin-1")
iter_mun = iter_raw[(iter_raw["LOC"] == 0) & (iter_raw["MUN"] != 0)].copy()

def num_cols(df, cols):
    for c in cols:
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0)
    return df

iter_mun = num_cols(iter_mun, ["P_3A5","P3A5_NOA","P_6A11","P6A11_NOA",
    "P_12A14","P12A14NOA","P_15A17","P15A17A","P_15YMAS",
    "P15YM_AN","GRAPROES","P15YM_SE","P18YM_PB","POBTOT"])

iter_mun["pct_no_asiste_12a14"]  = (iter_mun["P12A14NOA"] / iter_mun["P_12A14"]  * 100).round(2)
iter_mun["pct_asiste_15a17"]     = (iter_mun["P15A17A"]   / iter_mun["P_15A17"]  * 100).round(2)
iter_mun["pct_NO_asiste_15a17"]  = (100 - iter_mun["pct_asiste_15a17"]).round(2)
iter_mun["abs_NO_asiste_15a17"]  = (iter_mun["P_15A17"] - iter_mun["P15A17A"]).astype(int)
iter_mun["pct_analfabeta_15mas"] = (iter_mun["P15YM_AN"]  / iter_mun["P_15YMAS"] * 100).round(2)
iter_mun["grado_escolaridad_prom"] = iter_mun["GRAPROES"]
iter_mun["cve_mun"]   = iter_mun["MUN"].astype(str).str.zfill(3)
iter_mun["municipio"] = iter_mun["NOM_MUN"].str.strip().str.title()
iter_mun["poblacion_total"] = iter_mun["POBTOT"]

marg_raw = pd.read_excel(UP / "indice-de-marginacion-municipios-2020.xlsx")
marg_raw.columns = marg_raw.columns.str.strip()
c = marg_raw.columns.tolist()
MARG = marg_raw.rename(columns={
    c[0]:"clave_inegi", c[1]:"municipio_marg",
    c[4]:"pct_sin_educ_basica", c[11]:"pct_ingreso_bajo_2sm",
    c[12]:"indice_marginacion", c[13]:"grado_marginacion"
})
MARG["cve_mun"] = MARG["clave_inegi"].astype(str).str[-3:].str.zfill(3)

sesnsp = pd.read_csv(UP / "sesnsp_largo_2015_2025.csv", encoding="utf-8")
sesnsp.columns = sesnsp.columns.str.strip()
sesnsp["cve_mun"] = sesnsp["Cve. Municipio"].astype(str).str[-3:].str.zfill(3)
SESNSP_MUN = sesnsp[sesnsp["Año"] >= 2020].groupby("cve_mun")["Casos"].sum().reset_index()
SESNSP_MUN.columns = ["cve_mun","total_delitos_sesnsp"]

det = pd.read_excel(UP / "Personas_Detenidas_en_el_primer_trimestre_2026.xlsx")
det.columns = det.columns.str.strip()
det["municipio"] = det["municipio"].str.strip().str.title()
det["edad"] = pd.to_numeric(det["edad"], errors="coerce")
det["es_menor"] = det["edad"] < 18
DET_MUN = det.groupby("municipio").agg(
    total_detenidos=("municipio","count"),
    menores_detenidos=("es_menor","sum")
).reset_index()

itama = pd.read_excel(UP / "poblacion-itama-internamiento-1-trimestre-2026.xlsx",
                      sheet_name="POBLACION INTERNAMIENTO")
itama.columns = itama.columns.str.strip()
itama["municipio"] = itama["LOCALIDAD DEL DELITO"].str.split(",").str[0].str.strip().str.title()
ITAMA_MUN = itama.groupby("municipio").agg(menores_internados=("municipio","count")).reset_index()

maestro = iter_mun[["cve_mun","municipio","poblacion_total","grado_escolaridad_prom",
    "pct_no_asiste_12a14","pct_NO_asiste_15a17","abs_NO_asiste_15a17",
    "pct_analfabeta_15mas"]].copy()
maestro = maestro.merge(MARG[["cve_mun","indice_marginacion","grado_marginacion",
    "pct_sin_educ_basica","pct_ingreso_bajo_2sm"]], on="cve_mun", how="left")
maestro = maestro.merge(SESNSP_MUN, on="cve_mun", how="left")
maestro = maestro.merge(DET_MUN, on="municipio", how="left")
maestro = maestro.merge(ITAMA_MUN, on="municipio", how="left")

for col in ["total_delitos_sesnsp","total_detenidos","menores_detenidos","menores_internados"]:
    maestro[col] = maestro[col].fillna(0)

maestro["tasa_delitos_10k"]   = (maestro["total_delitos_sesnsp"] / maestro["poblacion_total"] * 10000).round(2)
maestro["tasa_detenidos_10k"] = (maestro["total_detenidos"]      / maestro["poblacion_total"] * 10000).round(2)

# ── CORRELACIONES ─────────────────────────────────────────────────────────────
cols_corr = [c for c in [
    "indice_marginacion","pct_sin_educ_basica","pct_analfabeta_15mas",
    "grado_escolaridad_prom","pct_no_asiste_12a14","pct_NO_asiste_15a17",
    "abs_NO_asiste_15a17","pct_ingreso_bajo_2sm","tasa_delitos_10k",
    "tasa_detenidos_10k","total_detenidos","menores_detenidos","menores_internados"
] if c in maestro.columns]

# Matriz ancha (para referencia)
corr_ancha = maestro[cols_corr].corr().round(3)

# ── FORMATO LARGO para Power BI heatmap ───────────────────────────────────────
# Estructura: variable_x | variable_y | correlacion | categoria | color_hex
registros = []
for i, var_x in enumerate(cols_corr):
    for j, var_y in enumerate(cols_corr):
        valor = corr_ancha.loc[var_x, var_y]
        # Categoría para usar como leyenda
        if abs(valor) >= 0.7:
            categoria = "Fuerte"
        elif abs(valor) >= 0.4:
            categoria = "Moderada"
        elif abs(valor) >= 0.2:
            categoria = "Débil"
        else:
            categoria = "Sin relación"
        registros.append({
            "variable_x": var_x,
            "variable_y": var_y,
            "correlacion": valor,
            "correlacion_abs": round(abs(valor), 3),
            "categoria": categoria,
            "es_diagonal": var_x == var_y,
            # Etiqueta limpia para mostrar en el eje
            "etiqueta_x": var_x.replace("_"," ").replace("pct","% ").strip(),
            "etiqueta_y": var_y.replace("_"," ").replace("pct","% ").strip(),
        })

CORR_LARGO = pd.DataFrame(registros)

print(f"✅ Correlaciones formato largo: {len(CORR_LARGO)} combinaciones")
print(f"   Variables incluidas: {len(cols_corr)}")
print()

# Resumen para verificar
print("Top 10 correlaciones más fuertes (sin diagonal):")
top = CORR_LARGO[~CORR_LARGO["es_diagonal"]].nlargest(10, "correlacion_abs")[
    ["variable_x","variable_y","correlacion","categoria"]
]
print(top.to_string(index=False))

# ── Agregar al Excel ───────────────────────────────────────────────────────────
ruta_excel = OUT / "sonora_seguridad_powerbi.xlsx"
wb = load_workbook(ruta_excel)

for nombre in ["07_Correlaciones","12_Correlaciones_Heatmap_PowerBI"]:
    if nombre in wb.sheetnames:
        del wb[nombre]

# Hoja 07 — matriz ancha (referencia / Python)
corr_export = corr_ancha.reset_index().rename(columns={"index":"variable"})
ws07 = wb.create_sheet("07_Correlaciones")
for r in dataframe_to_rows(corr_export, index=False, header=True):
    ws07.append(r)
for col_idx in range(1, len(corr_export.columns)+1):
    cell = ws07.cell(row=1, column=col_idx)
    cell.font = Font(bold=True, color=C_BLANCO, name="Arial", size=10)
    cell.fill = PatternFill("solid", fgColor=C_GUINDA)
    cell.alignment = Alignment(horizontal="center", vertical="center")
ws07.row_dimensions[1].height = 20
for col in ws07.columns:
    max_len = max(len(str(cell.value or "")) for cell in col)
    ws07.column_dimensions[col[0].column_letter].width = min(max_len + 3, 35)

# Hoja 12 — formato largo para Power BI heatmap
ws12 = wb.create_sheet("12_Correlaciones_Heatmap_PowerBI")
for r in dataframe_to_rows(CORR_LARGO, index=False, header=True):
    ws12.append(r)
for col_idx in range(1, len(CORR_LARGO.columns)+1):
    cell = ws12.cell(row=1, column=col_idx)
    cell.font = Font(bold=True, color=C_BLANCO, name="Arial", size=10)
    cell.fill = PatternFill("solid", fgColor="D4A017")  # dorado
    cell.alignment = Alignment(horizontal="center", vertical="center")
ws12.row_dimensions[1].height = 20
for col in ws12.columns:
    max_len = max(len(str(cell.value or "")) for cell in col)
    ws12.column_dimensions[col[0].column_letter].width = min(max_len + 3, 35)

wb.save(ruta_excel)
print(f"\n🎉 Excel actualizado — hojas 07 y 12 regeneradas")
print(f"   Total hojas: {len(wb.sheetnames)}")
EOF
