# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=67 message_id=019dc287-6cc1-7807-8b92-81c578cf85d9 sender=assistant created_at=2026-04-25T02:50:05.151864Z kind=bash
# DESCRIPTION/PATH: Pipeline ML definitivo
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline
from sklearn.metrics import r2_score
from openpyxl import load_workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils.dataframe import dataframe_to_rows

UP=Path("/mnt/user-data/uploads"); OUT=Path("/mnt/user-data/outputs"); OUT.mkdir(exist_ok=True)
C_GUINDA="6B1228"; C_GUINDA2="9B1D3A"; C_DORADO="D4A017"; C_BLANCO="FFFFFF"

def wh(wb, nombre, df, color=C_GUINDA):
    if nombre in wb.sheetnames: del wb[nombre]
    ws = wb.create_sheet(nombre)
    for r in dataframe_to_rows(df, index=False, header=True):
        ws.append([("" if (v is None or (isinstance(v,float) and np.isnan(v))) else v) for v in r])
    for ci in range(1,len(df.columns)+1):
        c=ws.cell(row=1,column=ci)
        c.font=Font(bold=True,color=C_BLANCO,name="Arial",size=10)
        c.fill=PatternFill("solid",fgColor=color)
        c.alignment=Alignment(horizontal="center",vertical="center",wrap_text=True)
    ws.row_dimensions[1].height=22
    for col in ws.columns:
        ws.column_dimensions[col[0].column_letter].width=min(max(len(str(c.value or "")) for c in col)+3,42)

def leer_triple(xf,h):
    raw=pd.read_excel(xf,sheet_name=h,header=None)
    hdrs=[str(v) for v in raw.iloc[2].tolist()]
    data=raw.iloc[3:].copy(); data.columns=hdrs
    return data[[c for c in hdrs if c!='nan']].reset_index(drop=True)

def num(df):
    for c in df.columns:
        try:
            conv=pd.to_numeric(df[c],errors='coerce')
            if conv.notna().sum()>len(df)*0.3: df[c]=conv
        except: pass
    return df

xf=pd.ExcelFile(UP/"sonora_maestro_v4.xlsx")
maestro   = num(pd.read_excel(xf,sheet_name="01_Maestro_Municipal"))
tendencia = num(leer_triple(xf,"21_Tendencia_Delitos_Anual"))
scatter_r = num(leer_triple(xf,"25_Scatter_Regresion_ML"))
relacion  = num(leer_triple(xf,"19_Relacion_Maestra_Municipal"))

# ── 1. PROYECCIÓN ────────────────────────────────────────────────────────────
años_X=tendencia["año"].values.reshape(-1,1).astype(float)
delitos_cfg=[("Narcomenudeo","Narcomenudeo",2),
             ("Robo","Robo",1),
             ("Violencia_familiar","Violencia familiar",1)]

modelos={}
grados={}
for nombre,col,grado in delitos_cfg:
    y=tendencia[col].values.astype(float)
    m=make_pipeline(PolynomialFeatures(grado),LinearRegression())
    m.fit(años_X,y)
    r2=r2_score(y,m.predict(años_X))
    modelos[nombre]=(m,r2,col)
    grados[nombre]=grado
    print(f"  {nombre}: R²={r2:.3f} grado={grado}")

años_real=set(int(a) for a in tendencia["año"].values)
filas=[]
for año_v in range(2020,2037):
    for nombre,(m,r2,col_orig) in modelos.items():
        pred=max(0,round(m.predict([[float(año_v)]])[0],0))
        es_real=año_v in años_real
        fila={"año":año_v,"delito":nombre,
              "tipo_dato":"Real" if es_real else "Proyección",
              "valor_proyeccion":pred,"R2_modelo":round(r2,3)}
        if es_real:
            rv=tendencia.loc[tendencia["año"]==año_v,col_orig].values
            fila["valor_real"]=float(rv[0]) if len(rv)>0 else None
        else:
            fila["valor_real"]=None
        filas.append(fila)

PROYECCION=pd.DataFrame(filas)
n2025=PROYECCION.loc[(PROYECCION["año"]==2025)&(PROYECCION["delito"]=="Narcomenudeo"),"valor_real"].values[0]
n2036=PROYECCION.loc[(PROYECCION["año"]==2036)&(PROYECCION["delito"]=="Narcomenudeo"),"valor_proyeccion"].values[0]
inc_pct=((n2036/n2025)-1)*100
print(f"  Narco 2025→2036: {n2025:.0f}→{n2036:.0f} (+{inc_pct:.0f}%)")

# ── 2. SCATTER NORMALIZADO ───────────────────────────────────────────────────
scatter=scatter_r.copy()
for c in ["abs_NO_asiste_15a17","poblacion_total","tasa_narco_10k"]:
    if c in scatter.columns:
        scatter[c]=pd.to_numeric(scatter[c],errors="coerce")

if "abs_NO_asiste_15a17" in scatter.columns:
    scatter["tasa_NO_asiste_15a17_10k"]=(
        scatter["abs_NO_asiste_15a17"]/scatter["poblacion_total"]*10000).round(2)

orden_marg={"Muy bajo":1,"Bajo":2,"Medio":3,"Alto":4,"Muy alto":5}
scatter["gradiente_marginacion"]=scatter["grado_marginacion"].map(orden_marg).fillna(0)

ciudades=["Hermosillo","Cajeme","Guaymas","Navojoa","Caborca","Nogales","Agua Prieta","Benito Juárez"]
scatter["etiqueta"]=scatter["municipio"].apply(lambda m: str(m) if str(m) in ciudades else "")

cols_ok=[c for c in ["cve_mun","municipio","poblacion_total","segmento_urbano",
    "grado_marginacion","gradiente_marginacion","abs_NO_asiste_15a17",
    "tasa_NO_asiste_15a17_10k","tasa_narco_10k","etiqueta"] if c in scatter.columns]
SCATTER_NORM=scatter[cols_ok].dropna(
    subset=[c for c in ["tasa_NO_asiste_15a17_10k","tasa_narco_10k"] if c in scatter.columns]
).reset_index(drop=True)

# ── 3. NARRATIVA ─────────────────────────────────────────────────────────────
maestro["cve_num"]=pd.to_numeric(maestro["cve_mun"],errors="coerce")
relacion["cve_num"]=pd.to_numeric(relacion["cve_mun"],errors="coerce")
cols_m=[c for c in ["cve_num","municipio","poblacion_total","pct_NO_asiste_15a17",
    "abs_NO_asiste_15a17","pct_analfabeta_15mas","grado_escolaridad_prom",
    "menores_detenidos","menores_internados","tasa_delitos_10k","grado_marginacion"]
    if c in maestro.columns]
cols_r=[c for c in ["cve_num","segmento_urbano","tasa_narco_10k","indice_riesgo_potencial",
    "pct_pobreza_2020","pct_rezago_educativo_2020"] if c in relacion.columns]
narrativa=maestro[cols_m].merge(relacion[cols_r],on="cve_num",how="left")
narrativa["gradiente_marginacion"]=narrativa["grado_marginacion"].map(orden_marg).fillna(0)
if "abs_NO_asiste_15a17" in narrativa.columns:
    narrativa["tasa_NO_asiste_15a17_10k"]=(
        pd.to_numeric(narrativa["abs_NO_asiste_15a17"],errors="coerce")/
        pd.to_numeric(narrativa["poblacion_total"],errors="coerce")*10000).round(2)

def norm01(s):
    s=pd.to_numeric(s,errors="coerce"); mn,mx=s.min(),s.max()
    return (s-mn)/(mx-mn) if mx!=mn else s*0

cols_s=[c for c in ["pct_NO_asiste_15a17","pct_analfabeta_15mas",
    "tasa_narco_10k","tasa_delitos_10k"] if c in narrativa.columns]
narrativa["score_vulnerabilidad"]=(sum(norm01(narrativa[c]) for c in cols_s)/len(cols_s)*100).round(1)

# ── 4. META ML ───────────────────────────────────────────────────────────────
META_ML=pd.DataFrame([
    ["Narcomenudeo","Polynomial grado 2",
     round(modelos["Narcomenudeo"][1],3),2,
     f"De {n2025:.0f} (2025) a {n2036:.0f} (2036)",
     f"+{inc_pct:.0f}%"],
    ["Robo","Lineal grado 1",
     round(modelos["Robo"][1],3),1,
     "Tendencia decreciente sostenida","Negativo"],
    ["Violencia_familiar","Lineal grado 1",
     round(modelos["Violencia_familiar"][1],3),1,
     "Tendencia variable, R² bajo — no predecible con modelo lineal simple","Variable"],
],columns=["delito","modelo","R2","grado","descripcion_proyeccion","tendencia_10yr"])

# ── EXPORTAR ─────────────────────────────────────────────────────────────────
wb=load_workbook(UP/"sonora_maestro_v4.xlsx")
wh(wb,"01_Maestro_Municipal",   maestro,      C_GUINDA)
wh(wb,"24_Proyeccion_10yr_ML",  PROYECCION,   C_GUINDA2)
wh(wb,"25_Scatter_Normalizado", SCATTER_NORM, C_GUINDA)
wh(wb,"35_Narrativa_Municipal", narrativa,    C_GUINDA)
wh(wb,"36_Meta_ML",             META_ML,      C_DORADO)

ruta=OUT/"sonora_seguridad_powerbi_FINAL.xlsx"
wb.save(ruta)
print(f"\n🎉 Excel FINAL: {ruta} | {len(wb.sheetnames)} hojas")

PROYECCION.to_csv(OUT/"proyeccion_narco_10yr.csv",index=False,encoding="utf-8")
SCATTER_NORM.to_csv(OUT/"scatter_normalizado.csv",index=False,encoding="utf-8")
print("✅ CSVs exportados")
EOF
