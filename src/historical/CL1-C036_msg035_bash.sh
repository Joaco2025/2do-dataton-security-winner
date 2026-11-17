# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=35 message_id=019db2ac-9cf0-70de-8cfc-11b120a25d6b sender=assistant created_at=2026-04-22T00:53:41.057481Z kind=bash
# DESCRIPTION/PATH: Análisis normalizado enfocado en menores
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from pathlib import Path

UP = Path("/mnt/user-data/uploads")

# Reconstruir maestro rápido
iter_raw = pd.read_csv(UP / "conjunto_de_datos_iter_26CSV20.csv", encoding="latin-1")
iter_mun = iter_raw[(iter_raw["LOC"] == 0) & (iter_raw["MUN"] != 0)].copy()

def num_cols(df, cols):
    for c in cols:
        df[c] = pd.to_numeric(df[c], errors="coerce").fillna(0)
    return df

iter_mun = num_cols(iter_mun, ["P_15A17","P15A17A","P_12A14","P12A14NOA","POBTOT","GRAPROES","P15YM_AN","P_15YMAS"])
iter_mun["pct_NO_asiste_15a17"] = (100 - iter_mun["P15A17A"] / iter_mun["P_15A17"] * 100).round(2)
iter_mun["abs_NO_asiste_15a17"] = (iter_mun["P_15A17"] - iter_mun["P15A17A"]).astype(int)
iter_mun["tasa_NO_asiste_15a17_1k"] = (iter_mun["abs_NO_asiste_15a17"] / iter_mun["POBTOT"] * 1000).round(2)
iter_mun["pct_no_asiste_12a14"] = (iter_mun["P12A14NOA"] / iter_mun["P_12A14"] * 100).round(2)
iter_mun["pct_analfabeta"]      = (iter_mun["P15YM_AN"]  / iter_mun["P_15YMAS"] * 100).round(2)
iter_mun["cve_mun"]   = iter_mun["MUN"].astype(str).str.zfill(3)
iter_mun["municipio"] = iter_mun["NOM_MUN"].str.strip().str.title()
iter_mun["poblacion_total"] = iter_mun["POBTOT"]
iter_mun["grado_escolaridad"] = iter_mun["GRAPROES"]

marg_raw = pd.read_excel(UP / "indice-de-marginacion-municipios-2020.xlsx")
marg_raw.columns = marg_raw.columns.str.strip()
c = marg_raw.columns.tolist()
MARG = marg_raw.rename(columns={c[0]:"clave_inegi", c[1]:"municipio_marg",
    c[12]:"indice_marginacion", c[13]:"grado_marginacion",
    c[4]:"pct_sin_educ_basica", c[11]:"pct_ingreso_bajo_2sm"})
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

maestro = iter_mun[["cve_mun","municipio","poblacion_total","grado_escolaridad",
    "pct_NO_asiste_15a17","abs_NO_asiste_15a17","tasa_NO_asiste_15a17_1k",
    "pct_no_asiste_12a14","pct_analfabeta"]].copy()
maestro = maestro.merge(MARG[["cve_mun","indice_marginacion","grado_marginacion",
    "pct_sin_educ_basica","pct_ingreso_bajo_2sm"]], on="cve_mun", how="left")
maestro = maestro.merge(SESNSP_MUN, on="cve_mun", how="left")
maestro = maestro.merge(DET_MUN, on="municipio", how="left")
maestro = maestro.merge(ITAMA_MUN, on="municipio", how="left")

for col in ["total_delitos_sesnsp","total_detenidos","menores_detenidos","menores_internados"]:
    maestro[col] = maestro[col].fillna(0)

# TASAS normalizadas por población
maestro["tasa_delitos_10k"]    = (maestro["total_delitos_sesnsp"] / maestro["poblacion_total"] * 10000).round(2)
maestro["tasa_detenidos_10k"]  = (maestro["total_detenidos"]      / maestro["poblacion_total"] * 10000).round(2)
maestro["tasa_menores_det_10k"]= (maestro["menores_detenidos"]    / maestro["poblacion_total"] * 10000).round(3)
# tasa menores por cada 1000 jóvenes 15-17 (más relevante para la narrativa)
iter_p15a17 = iter_mun[["cve_mun","P_15A17"]].copy()
maestro = maestro.merge(iter_p15a17, on="cve_mun", how="left")
maestro["tasa_menores_x1k_jovenes"] = (maestro["menores_detenidos"] / maestro["P_15A17"] * 1000).round(2)

print("=== ANÁLISIS NORMALIZADO: tasa de menores detenidos por cada 1,000 jóvenes 15-17 ===")
top_menores = maestro[maestro["menores_detenidos"] > 0].sort_values(
    "tasa_menores_x1k_jovenes", ascending=False)
print(top_menores[["municipio","poblacion_total","P_15A17","menores_detenidos",
                    "tasa_menores_x1k_jovenes","pct_NO_asiste_15a17",
                    "grado_marginacion","indice_marginacion"]].to_string(index=False))

print()
print("=== CORRELACIONES NORMALIZADAS ===")
cols_c = ["indice_marginacion","pct_sin_educ_basica","pct_NO_asiste_15a17",
          "pct_no_asiste_12a14","grado_escolaridad","pct_ingreso_bajo_2sm",
          "tasa_delitos_10k","tasa_menores_det_10k","tasa_menores_x1k_jovenes"]
corr = maestro[cols_c].corr().round(3)
print("\nvs tasa_menores_x1k_jovenes (menores detenidos por cada 1k jóvenes 15-17):")
print(corr["tasa_menores_x1k_jovenes"].sort_values(ascending=False).to_string())
print()
print("vs tasa_delitos_10k:")
print(corr["tasa_delitos_10k"].sort_values(ascending=False).to_string())

print()
print("=== PERFIL ITAMA: edad, delito, municipio ===")
print(itama[["SEXO","EDAD ACTUAL","municipio","LOCALIDAD DEL DELITO"]].value_counts(
    ["EDAD ACTUAL","municipio"]).head(15))

print()
print("=== DETENIDOS MENORES: perfil por delito ===")
menores_det = det[det["es_menor"] == True]
print(f"Total menores detenidos: {len(menores_det)}")
print(f"Edad promedio: {menores_det['edad'].mean():.1f}")
print(f"Rango de edades: {int(menores_det['edad'].min())} - {int(menores_det['edad'].max())}")
print()
print("Delitos más frecuentes en menores:")
print(menores_det["delito"].value_counts().head(10))
print()
print("Por municipio:")
print(menores_det["municipio"].value_counts().head(10))
print()
print("Por sexo:")
print(menores_det["sexo"].value_counts())
EOF
