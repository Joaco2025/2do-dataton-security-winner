# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=57 message_id=019dc112-86a6-75d9-a77c-d5c4167ec901 sender=assistant created_at=2026-04-24T20:00:03.599536Z kind=bash
# DESCRIPTION/PATH: Procesar todos los archivos de Google Trends con método ancla y exportar Excel
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from pathlib import Path
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils.dataframe import dataframe_to_rows

UP  = Path("/mnt/user-data/uploads")
OUT = Path("/mnt/user-data/outputs")
OUT.mkdir(exist_ok=True)

C_GUINDA  = "6B1228"
C_GUINDA2 = "9B1D3A"
C_DORADO  = "D4A017"
C_GRIS    = "3D3D3D"
C_BLANCO  = "FFFFFF"
C_CREMA   = "F5F0E8"

def estilo_header(ws, n_cols, color=C_GUINDA):
    for col in range(1, n_cols + 1):
        cell = ws.cell(row=1, column=col)
        cell.font      = Font(bold=True, color=C_BLANCO, name="Arial", size=10)
        cell.fill      = PatternFill("solid", fgColor=color)
        cell.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)
    ws.row_dimensions[1].height = 28

def escribir_hoja(wb, nombre, df, color=C_GUINDA):
    ws = wb.create_sheet(nombre)
    for r in dataframe_to_rows(df, index=False, header=True):
        ws.append(r)
    estilo_header(ws, len(df.columns), color)
    for col in ws.columns:
        max_len = max(len(str(cell.value or "")) for cell in col)
        ws.column_dimensions[col[0].column_letter].width = min(max_len + 3, 40)
    return ws

# ══════════════════════════════════════════════════════════════════════════════
# PASO 1 — Cargar todos los archivos y extraer ancla + términos
# ══════════════════════════════════════════════════════════════════════════════

archivos = {
    "B0_base":    "multiTimeline.csv",
    "B1_artistas":"multiTimeline_1_.csv",
    "B2_expansion":"multiTimeline_2_.csv",
    "B3_cultura": "multiTimeline_3_.csv",
    "B4_canciones":"multiTimeline_4_.csv",
    "B5_belico":  "multiTimeline_5_.csv",
    "B6_musical": "multiTimeline_6_.csv",
    "B7_aspiracional":"multiTimeline_7_.csv",
    "B8_violencia":"multiTimeline_8_.csv",
}

bloques = {}
for nombre, archivo in archivos.items():
    df = pd.read_csv(UP / archivo, header=1, encoding="utf-8")
    df["Semana"] = pd.to_datetime(df["Semana"])
    # Limpiar nombres de columnas
    df.columns = [c.replace(": (Sonora)","").strip() for c in df.columns]
    # Convertir todo a numérico
    for col in df.columns[1:]:
        df[col] = pd.to_numeric(df[col], errors="coerce").fillna(0)
    bloques[nombre] = df
    print(f"✅ {nombre}: {df.shape} | cols: {list(df.columns)}")

# ══════════════════════════════════════════════════════════════════════════════
# PASO 2 — Re-escalado por método ancla "corridos"
# El bloque B0 NO tiene "corridos" como ancla sino "corridos tumbados"
# Los bloques B1-B8 sí tienen "corridos" como ancla
# Usamos B4 como referencia base (tiene los valores más altos y estables)
# ══════════════════════════════════════════════════════════════════════════════

# Base de referencia: promedio de "corridos" en cada bloque
# Normalizamos todos los bloques al promedio de "corridos" del B4 (más completo)
base_ref = bloques["B4_canciones"]["corridos"].replace(0, np.nan).mean()
print(f"\nReferencia base (corridos en B4): {base_ref:.2f}")

def reescalar(df, base_ref):
    """Re-escala el bloque usando la columna 'corridos' como ancla."""
    if "corridos" not in df.columns:
        return df.copy()
    ancla_prom = df["corridos"].replace(0, np.nan).mean()
    if pd.isna(ancla_prom) or ancla_prom == 0:
        return df.copy()
    factor = base_ref / ancla_prom
    df_scaled = df.copy()
    for col in df.columns[1:]:  # no tocar Semana
        df_scaled[col] = (df[col] * factor).round(2)
    df_scaled["factor_escala"] = round(factor, 4)
    print(f"  ancla_prom={ancla_prom:.2f} | factor={factor:.3f} | cols re-escaladas: {list(df.columns[1:])}")
    return df_scaled

print("\nRe-escalando bloques...")
escalados = {}
for nombre, df in bloques.items():
    escalados[nombre] = reescalar(df, base_ref)

# ══════════════════════════════════════════════════════════════════════════════
# PASO 3 — Construir tabla maestra unificada
# Unimos todos por "Semana", eliminando duplicados de "corridos"
# ══════════════════════════════════════════════════════════════════════════════

print("\nConstruyendo tabla maestra...")

# Empezar con el B0 (sin ancla corridos, tiene corridos tumbados etc.)
base_df = escalados["B0_base"][["Semana","corridos tumbados","Corridos Belikos",
                                  "Natanael Cano","peso pluma","fuerza regida"]].copy()

# Términos a agregar de cada bloque (sin repetir "corridos" que es el ancla)
terminos_por_bloque = {
    "B1_artistas":    ["Junior H","Marca Registrada","Óscar Maydon","narcocorridos"],
    "B2_expansion":   ["Gabito Ballesteros","Tito Double P","Grupo Frontera"],
    "B3_cultura":     ["narco","cartel","sicario"],
    "B4_canciones":   ["Ella baila sola","PRC"],
    "B5_belico":      ["belico","Siempre Pendientes"],
    "B6_musical":     ["banda","norteño"],
    "B7_aspiracional":["trocas","armas"],
    "B8_violencia":   ["violencia","balacera","ejecución"],
}

# Agregar ancla "corridos" solo del B1 (más completo) como referencia
ancla_df = escalados["B1_artistas"][["Semana","corridos"]].copy()
maestro = base_df.merge(ancla_df, on="Semana", how="outer")

for nombre, cols in terminos_por_bloque.items():
    cols_disponibles = ["Semana"] + [c for c in cols if c in escalados[nombre].columns]
    maestro = maestro.merge(escalados[nombre][cols_disponibles], on="Semana", how="outer")

maestro = maestro.sort_values("Semana").reset_index(drop=True)
maestro["año"] = maestro["Semana"].dt.year
maestro["mes"] = maestro["Semana"].dt.month
maestro["trimestre"] = maestro["Semana"].dt.quarter

print(f"✅ Tabla maestra: {maestro.shape}")
print(f"   Rango: {maestro['Semana'].min()} → {maestro['Semana'].max()}")

# ══════════════════════════════════════════════════════════════════════════════
# PASO 4 — Calcular índices compuestos
# ══════════════════════════════════════════════════════════════════════════════

# Índice 1 — Cultura corridos tumbados (artistas + género)
cols_idx1 = ["corridos tumbados","Natanael Cano","peso pluma","fuerza regida",
             "Junior H","Gabito Ballesteros","Tito Double P","Grupo Frontera",
             "Óscar Maydon","Marca Registrada"]
cols_idx1_ok = [c for c in cols_idx1 if c in maestro.columns]
maestro["indice_corridos_tumbados"] = maestro[cols_idx1_ok].mean(axis=1).round(2)

# Índice 2 — Cultura narco (términos de crimen organizado)
cols_idx2 = ["narco","cartel","sicario","narcocorridos","belico"]
cols_idx2_ok = [c for c in cols_idx2 if c in maestro.columns]
maestro["indice_cultura_narco"] = maestro[cols_idx2_ok].mean(axis=1).round(2)

# Índice 3 — Viralidad / canciones específicas
cols_idx3 = ["Ella baila sola","PRC","Siempre Pendientes","Corridos Belikos"]
cols_idx3_ok = [c for c in cols_idx3 if c in maestro.columns]
maestro["indice_viralidad"] = maestro[cols_idx3_ok].mean(axis=1).round(2)

# Índice 4 — Violencia y percepción
cols_idx4 = ["violencia","balacera","ejecución","armas"]
cols_idx4_ok = [c for c in cols_idx4 if c in maestro.columns]
maestro["indice_percepcion_violencia"] = maestro[cols_idx4_ok].mean(axis=1).round(2)

# Índice 5 — Contexto cultural general (banda, norteño = control)
cols_idx5 = ["banda","norteño"]
cols_idx5_ok = [c for c in cols_idx5 if c in maestro.columns]
maestro["indice_musical_control"] = maestro[cols_idx5_ok].mean(axis=1).round(2)

print(f"✅ Índices calculados: corridos_tumbados, cultura_narco, viralidad, percepcion_violencia, control")

# ══════════════════════════════════════════════════════════════════════════════
# PASO 5 — Resumen anual para cruzar con delitos SESNSP
# ══════════════════════════════════════════════════════════════════════════════

indices = ["indice_corridos_tumbados","indice_cultura_narco",
           "indice_viralidad","indice_percepcion_violencia","indice_musical_control"]

resumen_anual = maestro.groupby("año")[indices].mean().round(2).reset_index()
print("\nResumen anual de índices:")
print(resumen_anual.to_string(index=False))

# ══════════════════════════════════════════════════════════════════════════════
# PASO 6 — Tabla de términos individuales por semana (para Power BI líneas)
# ══════════════════════════════════════════════════════════════════════════════

# Formato largo — cada semana/término/valor
cols_terminos = [c for c in maestro.columns
                 if c not in ["Semana","año","mes","trimestre"] + indices]

largo = maestro[["Semana","año","trimestre"] + cols_terminos].melt(
    id_vars=["Semana","año","trimestre"],
    var_name="termino",
    value_name="interes_relativo"
)
# Categorizar cada término
def categorizar(t):
    artistas = ["Natanael Cano","peso pluma","fuerza regida","Junior H","Gabito Ballesteros",
                "Tito Double P","Grupo Frontera","Óscar Maydon","Marca Registrada","Corridos Belikos"]
    narco = ["narco","cartel","sicario","narcocorridos","belico"]
    canciones = ["Ella baila sola","PRC","Siempre Pendientes"]
    violencia = ["violencia","balacera","ejecución","armas"]
    control = ["banda","norteño","trocas"]
    genero = ["corridos tumbados","corridos"]
    if t in artistas: return "Artistas"
    if t in narco: return "Cultura Narco"
    if t in canciones: return "Canciones Virales"
    if t in violencia: return "Percepción Violencia"
    if t in control: return "Control Musical"
    if t in genero: return "Género"
    return "Otro"

largo["categoria"] = largo["termino"].apply(categorizar)

# ══════════════════════════════════════════════════════════════════════════════
# PASO 7 — Correlaciones con índices
# ══════════════════════════════════════════════════════════════════════════════

corr_indices = resumen_anual[indices].corr().round(3).reset_index().rename(columns={"index":"variable"})

# ══════════════════════════════════════════════════════════════════════════════
# PASO 8 — Exportar Excel
# ══════════════════════════════════════════════════════════════════════════════

wb = Workbook()
wb.remove(wb.active)

# Hoja 1 — Maestro semanal con índices
escribir_hoja(wb, "01_Maestro_Semanal", maestro, C_GUINDA)

# Hoja 2 — Formato largo por término (para gráficas de líneas Power BI)
escribir_hoja(wb, "02_Terminos_Largo", largo[largo["interes_relativo"] > 0], C_GUINDA2)

# Hoja 3 — Resumen anual de índices
escribir_hoja(wb, "03_Indices_Anual", resumen_anual, C_GUINDA)

# Hoja 4 — Correlaciones entre índices
escribir_hoja(wb, "04_Correlaciones_Indices", corr_indices, C_DORADO)

# Hoja 5 — Diccionario
dicc = pd.DataFrame([
    ["Semana",                     "Fecha de inicio de semana",                          "Google Trends"],
    ["corridos tumbados",          "Interés relativo re-escalado",                       "Bloque 0"],
    ["indice_corridos_tumbados",   "Promedio de artistas y género del movimiento",       "Calculado"],
    ["indice_cultura_narco",       "Promedio narco, cartel, sicario, narcocorridos, belico", "Calculado"],
    ["indice_viralidad",           "Canciones específicas virales",                      "Calculado"],
    ["indice_percepcion_violencia","Búsquedas de violencia, balacera, ejecución, armas", "Calculado"],
    ["indice_musical_control",     "Banda y norteño — grupo de control cultural",        "Calculado"],
    ["Re-escalado",                "Todos los valores ajustados al promedio de 'corridos' en B4", "Método ancla"],
    ["Uso recomendado",            "Cruzar índices anuales con tasa_delitos_10k del maestro municipal", "Análisis"],
], columns=["campo","descripcion","fuente"])
escribir_hoja(wb, "05_Diccionario", dicc, C_GRIS)

ruta = OUT / "google_trends_sonora_narco.xlsx"
wb.save(ruta)
print(f"\n🎉 Excel guardado: {ruta}")
print(f"   Hojas: {[s.title for s in wb.worksheets]}")
print(f"   Maestro semanal: {len(maestro)} semanas")
print(f"   Términos largo: {len(largo[largo['interes_relativo']>0])} registros")
EOF
