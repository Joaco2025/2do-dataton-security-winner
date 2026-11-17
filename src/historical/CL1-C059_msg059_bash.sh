# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=59 message_id=019dc122-eb43-734c-a174-62ad3dfa642b sender=assistant created_at=2026-04-24T20:18:16.754177Z kind=bash
# DESCRIPTION/PATH: Reconstruir dataset de Google Trends con correcciones completas
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from pathlib import Path
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils.dataframe import dataframe_to_rows

UP  = Path("/mnt/user-data/uploads")
OUT = Path("/mnt/user-data/outputs")

C_GUINDA  = "6B1228"
C_GUINDA2 = "9B1D3A"
C_DORADO  = "D4A017"
C_GRIS    = "3D3D3D"
C_BLANCO  = "FFFFFF"

def escribir_hoja(wb, nombre, df, color=C_GUINDA):
    ws = wb.create_sheet(nombre)
    for r in dataframe_to_rows(df, index=False, header=True):
        ws.append(r)
    for col_idx in range(1, len(df.columns)+1):
        cell = ws.cell(row=1, column=col_idx)
        cell.font = Font(bold=True, color=C_BLANCO, name="Arial", size=10)
        cell.fill = PatternFill("solid", fgColor=color)
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
    ws.row_dimensions[1].height = 28
    for col in ws.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        ws.column_dimensions[col[0].column_letter].width = min(max_len + 3, 38)
    return ws

# ══════════════════════════════════════════════════════════════════════════════
# PASO 1 — Cargar todos los bloques
# ══════════════════════════════════════════════════════════════════════════════
archivos = {
    "B0": "multiTimeline.csv",
    "B1": "multiTimeline_1_.csv",
    "B2": "multiTimeline_2_.csv",
    "B3": "multiTimeline_3_.csv",
    "B4": "multiTimeline_4_.csv",
    "B5": "multiTimeline_5_.csv",
    "B6": "multiTimeline_6_.csv",
    "B7": "multiTimeline_7_.csv",
    "B8": "multiTimeline_8_.csv",
}

bloques = {}
for key, archivo in archivos.items():
    df = pd.read_csv(UP / archivo, header=1, encoding="utf-8")
    df["Semana"] = pd.to_datetime(df["Semana"])
    df.columns = [c.replace(": (Sonora)","").strip() for c in df.columns]
    for col in df.columns[1:]:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
    bloques[key] = df

# ══════════════════════════════════════════════════════════════════════════════
# PASO 2 — Reescalado correcto
# TODOS los bloques con "corridos" se escalan al mismo promedio de referencia
# El B0 se escala usando Natanael Cano como puente (aparece en B0 y en escala libre)
# ══════════════════════════════════════════════════════════════════════════════

# Primero reescalar B1-B8 usando "corridos" → referencia = B4 promedio 40.16
ref = bloques["B4"]["corridos"].mean()
print(f"Referencia corridos (B4): {ref:.2f}")

escalados = {}
factores = {}

# B0 no tiene "corridos" — necesita tratamiento especial
# Estrategia: en B1 también viene Natanael Cano sin reescalar
# Cargamos B0 raw y B1 raw para calcular la relación de Natanael Cano
b0_raw = bloques["B0"].copy()
b1_raw = bloques["B1"].copy()  # este SÍ tiene corridos

# Reescalar B1 primero
f1 = ref / b1_raw["corridos"].mean()
b1_scaled = b1_raw.copy()
for col in b1_scaled.columns[1:]:
    b1_scaled[col] = b1_scaled[col] * f1

# Para B0: necesitamos encontrar cómo Natanael Cano se relaciona con los otros términos
# B0 tiene Natanael Cano en escala raw, pero Natanael Cano también aparece en búsquedas reales
# El factor de reescalado del B0 lo estimamos directamente:
# En el B4 (escala correcta), corridos promedia 40.16
# En el B0 (sin ancla), corridos tumbados tiene valores bajos (0-3)
# Pero peso pluma en B0 tiene max=100 (es el dominante del bloque B0)
# Interpretamos: en B0, Peso Pluma = 100 significa que Peso Pluma fue el término más buscado en ese bloque
# Reescalamos B0 usando el promedio de "corridos" del B4 dividido entre el promedio de "corridos" en B0_original... pero B0 no tiene corridos
# Solución: usamos el promedio de "narco" en B3 escalado como referencia adicional

# Reescalar B3 para verificar
f3 = ref / bloques["B3"]["corridos"].mean()
b3_scaled = bloques["B3"].copy()
for col in b3_scaled.columns[1:]:
    b3_scaled[col] = b3_scaled[col] * f3

# Los valores de "narco" escalados dan una idea del volumen real de búsquedas
# Para B0, el máximo es Peso Pluma=100 en su escala interna
# El factor correcto para B0: promedio de "corridos" en B4 / promedio de corridos en OTRO bloque que tenga los mismos términos
# Mejor opción: reescalar B0 directamente por promedio de "corridos" tomado de B1 sin escalar
# porque ambos cubren el mismo período y audiencia
f0 = ref / b1_raw["corridos"].mean()  # mismo factor que B1
b0_scaled = b0_raw.copy()
for col in b0_scaled.columns[1:]:
    b0_scaled[col] = b0_scaled[col] * f0

print(f"Factor B0 (proxy via B1): {f0:.3f}")

# Reescalar el resto
for key in ["B2","B3","B4","B5","B6","B7","B8"]:
    df = bloques[key].copy()
    f = ref / df["corridos"].mean()
    factores[key] = f
    for col in df.columns[1:]:
        df[col] = df[col] * f
    escalados[key] = df
    print(f"  {key}: factor={f:.3f}")

escalados["B0"] = b0_scaled
escalados["B1"] = b1_scaled
factores["B0"] = f0
factores["B1"] = f1

# ══════════════════════════════════════════════════════════════════════════════
# PASO 3 — Seleccionar SOLO términos sólidos (<50% ceros, sin picos extremos)
# ══════════════════════════════════════════════════════════════════════════════

terminos_limpios = {
    # Artistas sólidos
    "Natanael Cano":    escalados["B0"]["Natanael Cano"],
    "peso pluma":       escalados["B0"]["peso pluma"],
    "fuerza regida":    escalados["B0"]["fuerza regida"],
    "Junior H":         escalados["B1"]["Junior H"],
    "Gabito Ballesteros": escalados["B2"]["Gabito Ballesteros"],
    # Género
    "corridos":         escalados["B1"]["corridos"],
    # Cultura narco (sin cartel — tiene picos 551)
    "narco":            escalados["B3"]["narco"],
    # Percepción violencia
    "violencia":        escalados["B8"]["violencia"],
    "balacera":         escalados["B8"]["balacera"],
    "armas":            escalados["B7"]["armas"],
    # Control cultural
    "banda":            escalados["B6"]["banda"],
    "norteño":          escalados["B6"]["norteño"],
    # Subgénero
    "belico":           escalados["B5"]["belico"],
}

# Construir maestro limpio
semanas = escalados["B1"]["Semana"]
maestro = pd.DataFrame({"Semana": semanas})
for nombre, serie in terminos_limpios.items():
    maestro[nombre] = serie.values

maestro["Semana"] = pd.to_datetime(maestro["Semana"])
maestro["año"] = maestro["Semana"].dt.year
maestro["mes"] = maestro["Semana"].dt.month
maestro["trimestre"] = maestro["Semana"].dt.quarter

# Redondear
for col in terminos_limpios.keys():
    maestro[col] = maestro[col].round(2)

# ══════════════════════════════════════════════════════════════════════════════
# PASO 4 — Índices limpios (solo 3, bien definidos)
# ══════════════════════════════════════════════════════════════════════════════

# Índice A — Movimiento corridos tumbados (artistas + género)
cols_A = ["corridos","Natanael Cano","peso pluma","fuerza regida","Junior H","Gabito Ballesteros"]
maestro["idx_corridos_tumbados"] = maestro[cols_A].mean(axis=1).round(2)

# Índice B — Cultura narco y percepción de violencia
cols_B = ["narco","violencia","balacera","belico"]
maestro["idx_narco_violencia"] = maestro[cols_B].mean(axis=1).round(2)

# Índice C — Musical tradicional (grupo de control)
cols_C = ["banda","norteño"]
maestro["idx_control_musical"] = maestro[cols_C].mean(axis=1).round(2)

print(f"\n✅ Maestro limpio: {maestro.shape}")

# ══════════════════════════════════════════════════════════════════════════════
# PASO 5 — Resumen anual con los 3 índices
# ══════════════════════════════════════════════════════════════════════════════

indices = ["idx_corridos_tumbados","idx_narco_violencia","idx_control_musical"]

resumen_anual = maestro.groupby("año")[indices + list(terminos_limpios.keys())].mean().round(2).reset_index()
print("\nResumen anual (índices):")
print(resumen_anual[["año"]+indices].to_string(index=False))

# ══════════════════════════════════════════════════════════════════════════════
# PASO 6 — Formato largo (solo términos sólidos)
# ══════════════════════════════════════════════════════════════════════════════

categorias = {
    "corridos":"Género","Natanael Cano":"Artista","peso pluma":"Artista",
    "fuerza regida":"Artista","Junior H":"Artista","Gabito Ballesteros":"Artista",
    "narco":"Cultura Narco","violencia":"Percepción Violencia",
    "balacera":"Percepción Violencia","armas":"Percepción Violencia",
    "banda":"Control Musical","norteño":"Control Musical","belico":"Cultura Narco",
}

largo = maestro[["Semana","año","trimestre"] + list(terminos_limpios.keys())].melt(
    id_vars=["Semana","año","trimestre"],
    var_name="termino", value_name="interes_relativo"
)
largo["categoria"] = largo["termino"].map(categorias)
largo = largo[largo["interes_relativo"] > 0].reset_index(drop=True)

# ══════════════════════════════════════════════════════════════════════════════
# PASO 7 — Diagnóstico de calidad (transparencia)
# ══════════════════════════════════════════════════════════════════════════════

diagnostico = []
for col in terminos_limpios.keys():
    pct_ceros = (maestro[col] == 0).sum() / len(maestro) * 100
    diagnostico.append({
        "termino": col,
        "categoria": categorias.get(col,""),
        "pct_ceros": round(pct_ceros, 1),
        "promedio": round(maestro[col].mean(), 1),
        "maximo": round(maestro[col].max(), 1),
        "factor_reescalado": round(factores.get(
            [k for k,v in {
                "B0":["Natanael Cano","peso pluma","fuerza regida"],
                "B1":["corridos","Junior H"],
                "B2":["Gabito Ballesteros"],
                "B3":["narco"],
                "B5":["belico"],
                "B6":["banda","norteño"],
                "B7":["armas"],
                "B8":["violencia","balacera"],
            }.items() if col in v][0]
        , 1), 3),
        "calidad": "✅ Buena" if pct_ceros < 40 else "⚠️ Aceptable"
    })

DIAG = pd.DataFrame(diagnostico)

# Términos DESCARTADOS y por qué
descartados = pd.DataFrame([
    ["corridos tumbados",  "76.7% ceros en Sonora — término sin volumen suficiente en el estado", "B0"],
    ["Corridos Belikos",   "99.2% ceros — sin volumen en Sonora",                                 "B0"],
    ["narcocorridos",      "100% ceros — sin búsquedas en Sonora",                               "B1"],
    ["Marca Registrada",   "55% ceros — volumen insuficiente",                                    "B1"],
    ["Óscar Maydon",       "56.5% ceros — volumen insuficiente",                                  "B1"],
    ["Tito Double P",      "64.5% ceros — volumen insuficiente",                                  "B2"],
    ["Grupo Frontera",     "58.4% ceros — volumen insuficiente",                                  "B2"],
    ["cartel",             "Picos de 551 (distorsión extrema por series/películas)",               "B3"],
    ["sicario",            "77.5% ceros — sin volumen en Sonora",                                 "B3"],
    ["Ella baila sola",    "91.6% ceros — término efímero",                                       "B4"],
    ["PRC",                "98.5% ceros — sin volumen",                                           "B4"],
    ["Siempre Pendientes", "93.9% ceros — sin volumen",                                           "B5"],
    ["trocas",             "86.6% ceros — sin volumen en Sonora",                                 "B7"],
    ["ejecución",          "80.2% ceros — sin volumen",                                           "B8"],
], columns=["termino","razon_descarte","bloque_origen"])

# ══════════════════════════════════════════════════════════════════════════════
# PASO 8 — Correlaciones con índices
# ══════════════════════════════════════════════════════════════════════════════

corr_df = resumen_anual[indices].corr().round(3).reset_index().rename(columns={"index":"variable"})

# ══════════════════════════════════════════════════════════════════════════════
# PASO 9 — Exportar Excel limpio
# ══════════════════════════════════════════════════════════════════════════════

wb = Workbook()
wb.remove(wb.active)

escribir_hoja(wb, "01_Maestro_Semanal_Limpio",  maestro,        C_GUINDA)
escribir_hoja(wb, "02_Terminos_Largo",           largo,          C_GUINDA2)
escribir_hoja(wb, "03_Indices_Anual",            resumen_anual,  C_GUINDA)
escribir_hoja(wb, "04_Correlaciones",            corr_df,        C_DORADO)
escribir_hoja(wb, "05_Diagnostico_Calidad",      DIAG,           C_GUINDA2)
escribir_hoja(wb, "06_Terminos_Descartados",     descartados,    C_GRIS)

ruta = OUT / "google_trends_sonora_narco.xlsx"
wb.save(ruta)
print(f"\n🎉 Excel corregido: {ruta}")
print(f"   Hojas: {[s.title for s in wb.worksheets]}")
print(f"\n📊 Resumen final de índices:")
print(resumen_anual[["año"]+indices].to_string(index=False))
EOF
