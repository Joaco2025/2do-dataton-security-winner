# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=1 message_id=019db18f-3dd8-7574-b1f1-5ded499664e4 sender=assistant created_at=2026-04-21T19:42:18.674497Z kind=create_file
# DESCRIPTION/PATH: /mnt/user-data/outputs/pipeline_seguridad_sonora.py
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
"""
=============================================================
  DATATÓN SEGURIDAD SONORA — Pipeline de Datos
  Gobierno del Estado de Sonora
=============================================================
  Autores: Equipo Seguridad
  Descripción: Limpieza, integración y exportación de datasets
               para análisis de marginación vs. incidencia delictiva.
               Output: Excel limpio listo para Power BI
=============================================================
"""

import pandas as pd
import numpy as np
from pathlib import Path
import warnings
warnings.filterwarnings("ignore")

# ─────────────────────────────────────────────────
#  CONFIGURACIÓN DE RUTAS
# ─────────────────────────────────────────────────
BASE_DIR = Path("data")          # Carpeta donde están tus CSVs
OUT_DIR  = Path("output")        # Carpeta de salida para Power BI
OUT_DIR.mkdir(exist_ok=True)

# Paleta Morena / Gobierno MX (para matplotlib si se usan gráficas de validación)
PALETA = {
    "guinda_oscuro": "#6B1228",
    "guinda_medio":  "#9B1D3A",
    "guinda_claro":  "#C4314B",
    "dorado":        "#D4A017",
    "crema":         "#F5F0E8",
    "gris":          "#3D3D3D",
}

# ─────────────────────────────────────────────────
#  1. CARGA DE DATASETS
#     Ajusta los nombres de archivo según los tuyos
# ─────────────────────────────────────────────────

def cargar_marginacion(ruta: str) -> pd.DataFrame:
    """
    Carga el índice de marginación por colonia y lo agrega a nivel municipal.
    Se espera un CSV con al menos: municipio, colonia, indice_marginacion (numérico)
    """
    print("📂 Cargando marginación por colonia...")
    df = pd.read_csv(ruta, encoding="latin-1")

    # Normalizar nombres de columnas
    df.columns = df.columns.str.strip().str.lower() \
                   .str.replace(" ", "_").str.replace("á","a") \
                   .str.replace("é","e").str.replace("í","i") \
                   .str.replace("ó","o").str.replace("ú","u")

    # ── Ajusta estos nombres a los de TU archivo ──
    col_municipio = "municipio"      # columna con nombre del municipio
    col_indice    = "indice_marginacion"  # columna numérica del índice

    # Agregar a nivel municipal (promedio ponderado simple)
    marg_mun = (
        df.groupby(col_municipio)[col_indice]
          .agg(["mean", "median", "count"])
          .reset_index()
          .rename(columns={
              "mean":   "marginacion_promedio",
              "median": "marginacion_mediana",
              "count":  "num_colonias"
          })
    )

    # Clasificar en niveles
    marg_mun["nivel_marginacion"] = pd.cut(
        marg_mun["marginacion_promedio"],
        bins=[-np.inf, -1.0, 0.5, np.inf],
        labels=["Baja", "Media", "Alta"]
    )

    print(f"   ✅ {len(marg_mun)} municipios con datos de marginación")
    return marg_mun


def cargar_delitos(ruta: str) -> pd.DataFrame:
    """
    Carga el dataset de delitos por municipio ya filtrados por tipo.
    Se espera: municipio, tipo_delito, año, mes, num_delitos (o una fila por evento)
    """
    print("📂 Cargando delitos por municipio...")
    df = pd.read_csv(ruta, encoding="latin-1")

    df.columns = df.columns.str.strip().str.lower() \
                   .str.replace(" ", "_").str.replace("á","a") \
                   .str.replace("é","e").str.replace("í","i") \
                   .str.replace("ó","o").str.replace("ú","u")

    # ── Ajusta estos nombres a los de TU archivo ──
    col_municipio  = "municipio"
    col_tipo       = "tipo_delito"
    col_año        = "ano"       # o "year"
    col_mes        = "mes"       # o "month"

    # Si el dataset tiene una fila por evento, contar
    if "num_delitos" not in df.columns:
        df["num_delitos"] = 1

    # Limpiar municipio
    df[col_municipio] = df[col_municipio].str.strip().str.title()

    # Agregado total por municipio y tipo
    delitos_agg = (
        df.groupby([col_municipio, col_tipo])["num_delitos"]
          .sum()
          .reset_index()
    )

    # Total de delitos por municipio (para el merge principal)
    delitos_total = (
        df.groupby(col_municipio)["num_delitos"]
          .sum()
          .reset_index()
          .rename(columns={"num_delitos": "total_delitos"})
    )

    # Serie de tiempo: delitos por año/mes (para gráfica de tendencia)
    if col_año in df.columns:
        delitos_tiempo = (
            df.groupby([col_municipio, col_año, col_mes])["num_delitos"]
              .sum()
              .reset_index()
        )
    else:
        delitos_tiempo = None

    print(f"   ✅ {len(delitos_total)} municipios con datos de delitos")
    print(f"   ✅ Tipos de delito: {df[col_tipo].nunique()}")
    return delitos_agg, delitos_total, delitos_tiempo


def cargar_dataset_opcional(ruta: str, nombre: str) -> pd.DataFrame | None:
    """
    Carga datasets opcionales: pobreza, desempleo, menores infractores, educación.
    Retorna None si el archivo no existe.
    """
    if not Path(ruta).exists():
        print(f"   ⚠️  {nombre} no encontrado — se omite")
        return None

    print(f"📂 Cargando {nombre}...")
    df = pd.read_csv(ruta, encoding="latin-1")
    df.columns = df.columns.str.strip().str.lower() \
                   .str.replace(" ", "_").str.replace("á","a") \
                   .str.replace("é","e").str.replace("í","i") \
                   .str.replace("ó","o").str.replace("ú","u")
    print(f"   ✅ {len(df)} filas cargadas")
    return df


# ─────────────────────────────────────────────────
#  2. NORMALIZACIÓN DE NOMBRES DE MUNICIPIO
#     Clave para que el merge no falle
# ─────────────────────────────────────────────────

CORRECCIONES_MUNICIPIO = {
    "Hermosillo, Son.":    "Hermosillo",
    "Cd. Obregon":         "Cajeme",
    "Ciudad Obregon":      "Cajeme",
    "San Luis R.C.":       "San Luis Rio Colorado",
    "Nogales Son":         "Nogales",
    "Guaymas Son.":        "Guaymas",
}

def normalizar_municipio(serie: pd.Series) -> pd.Series:
    """Limpia y estandariza nombres de municipios."""
    s = (serie.str.strip()
              .str.title()
              .str.replace(r"\s+", " ", regex=True)
              .str.replace("á","á")  # preservar tildes normalizadas
    )
    return s.replace(CORRECCIONES_MUNICIPIO)


# ─────────────────────────────────────────────────
#  3. MERGE PRINCIPAL
# ─────────────────────────────────────────────────

def construir_dataset_maestro(
    marg_mun:      pd.DataFrame,
    delitos_total: pd.DataFrame,
    delitos_agg:   pd.DataFrame,
    df_pobreza:    pd.DataFrame | None = None,
    df_desempleo:  pd.DataFrame | None = None,
    df_educacion:  pd.DataFrame | None = None,
    df_menores:    pd.DataFrame | None = None,
) -> pd.DataFrame:
    """
    Une todos los datasets a nivel municipal.
    Retorna un DataFrame maestro limpio.
    """
    print("\n🔗 Construyendo dataset maestro...")

    # Normalizar llaves
    marg_mun["municipio"]      = normalizar_municipio(marg_mun["municipio"])
    delitos_total["municipio"] = normalizar_municipio(delitos_total["municipio"])

    # Merge base
    maestro = pd.merge(marg_mun, delitos_total, on="municipio", how="outer")

    # Calcular tasa de delitos por 10,000 habitantes (si hay población)
    # Si no tienes población, se puede agregar después en Power BI
    if "poblacion_total" in maestro.columns:
        maestro["tasa_delitos_10k"] = (
            maestro["total_delitos"] / maestro["poblacion_total"] * 10_000
        ).round(2)

    # Merge con datasets opcionales
    for df_opt, sufijo in [
        (df_pobreza,   "pobreza"),
        (df_desempleo, "desempleo"),
        (df_educacion, "educacion"),
        (df_menores,   "menores"),
    ]:
        if df_opt is not None:
            df_opt["municipio"] = normalizar_municipio(df_opt["municipio"])
            maestro = pd.merge(maestro, df_opt, on="municipio", how="left")
            print(f"   ✅ Merged: {sufijo}")

    # Rellenar vacíos numéricos con 0 (para Power BI no tener nulls en métricas)
    cols_numericas = maestro.select_dtypes(include=np.number).columns
    maestro[cols_numericas] = maestro[cols_numericas].fillna(0)

    # Columna de índice compuesto (marginación normalizada * total delitos)
    marg_min = maestro["marginacion_promedio"].min()
    marg_max = maestro["marginacion_promedio"].max()
    maestro["marginacion_normalizada"] = (
        (maestro["marginacion_promedio"] - marg_min) / (marg_max - marg_min)
    ).round(4)

    print(f"   ✅ Dataset maestro: {len(maestro)} municipios, {len(maestro.columns)} columnas")
    return maestro


# ─────────────────────────────────────────────────
#  4. TABLAS PIVOTE PARA POWER BI
# ─────────────────────────────────────────────────

def crear_tabla_delitos_tipo(delitos_agg: pd.DataFrame) -> pd.DataFrame:
    """
    Crea tabla pivoteada: municipio x tipo_de_delito (útil para treemap y barras apiladas).
    """
    pivot = delitos_agg.pivot_table(
        index="municipio",
        columns="tipo_delito",
        values="num_delitos",
        aggfunc="sum",
        fill_value=0
    ).reset_index()

    # Limpiar nombres de columnas para Power BI
    pivot.columns = [
        str(c).strip().replace(" ", "_").replace("/", "_").replace("(", "").replace(")", "")
        for c in pivot.columns
    ]
    return pivot


def crear_tabla_correlacion(maestro: pd.DataFrame) -> pd.DataFrame:
    """
    Calcula matriz de correlación entre variables clave.
    Útil para el heatmap en Power BI o matplotlib.
    """
    cols_corr = [c for c in [
        "marginacion_promedio", "total_delitos",
        "tasa_pobreza", "tasa_desempleo",
        "desercion_escolar", "num_menores_infractores"
    ] if c in maestro.columns]

    corr = maestro[cols_corr].corr().round(3).reset_index()
    corr = corr.rename(columns={"index": "variable"})
    return corr


# ─────────────────────────────────────────────────
#  5. ANÁLISIS DE CORRELACIÓN (log en consola)
# ─────────────────────────────────────────────────

def analizar_correlacion(maestro: pd.DataFrame):
    """Imprime correlaciones clave para validación rápida."""
    print("\n📊 Correlaciones con total_delitos:")
    cols_num = maestro.select_dtypes(include=np.number).columns.tolist()
    if "total_delitos" not in cols_num:
        print("   ⚠️  'total_delitos' no encontrado")
        return

    corrs = (
        maestro[cols_num]
          .corr()["total_delitos"]
          .drop("total_delitos")
          .sort_values(ascending=False)
    )
    print(corrs.to_string())


# ─────────────────────────────────────────────────
#  6. EXPORTACIÓN A EXCEL (multi-hoja para Power BI)
# ─────────────────────────────────────────────────

def exportar_excel(
    maestro:        pd.DataFrame,
    delitos_agg:    pd.DataFrame,
    delitos_tiempo: pd.DataFrame | None,
    pivot_tipos:    pd.DataFrame,
    corr_df:        pd.DataFrame,
    nombre_archivo: str = "sonora_seguridad_powerbi.xlsx"
):
    """
    Exporta todas las tablas en un Excel multi-hoja.
    Cada hoja es una tabla que se conecta directamente a Power BI.
    """
    ruta_salida = OUT_DIR / nombre_archivo
    print(f"\n💾 Exportando a {ruta_salida}...")

    with pd.ExcelWriter(ruta_salida, engine="openpyxl") as writer:

        # Hoja 1 — Dataset maestro (tabla principal del dashboard)
        maestro.to_excel(writer, sheet_name="Maestro_Municipal", index=False)

        # Hoja 2 — Delitos por tipo y municipio
        delitos_agg.to_excel(writer, sheet_name="Delitos_Por_Tipo", index=False)

        # Hoja 3 — Pivote de tipos de delito (para barras apiladas / treemap)
        pivot_tipos.to_excel(writer, sheet_name="Pivot_Tipos_Delito", index=False)

        # Hoja 4 — Serie de tiempo (si existe)
        if delitos_tiempo is not None:
            delitos_tiempo.to_excel(writer, sheet_name="Serie_Tiempo", index=False)

        # Hoja 5 — Correlaciones
        corr_df.to_excel(writer, sheet_name="Correlaciones", index=False)

        # Hoja 6 — Diccionario de variables (documentación)
        diccionario = pd.DataFrame({
            "columna": [
                "municipio", "marginacion_promedio", "marginacion_mediana",
                "nivel_marginacion", "total_delitos", "tasa_delitos_10k",
                "marginacion_normalizada"
            ],
            "descripcion": [
                "Nombre oficial del municipio de Sonora",
                "Promedio del índice de marginación de todas las colonias del municipio",
                "Mediana del índice de marginación",
                "Clasificación: Baja / Media / Alta",
                "Suma total de delitos registrados en el municipio",
                "Delitos por cada 10,000 habitantes (requiere columna poblacion_total)",
                "Índice de marginación normalizado entre 0 y 1 para comparación"
            ],
            "fuente": [
                "INEGI", "CONAPO", "CONAPO", "Calculado",
                "SESNSP", "SESNSP + INEGI", "Calculado"
            ]
        })
        diccionario.to_excel(writer, sheet_name="Diccionario", index=False)

    print(f"   ✅ Excel exportado con {5 + (1 if delitos_tiempo is not None else 0)} hojas")
    print(f"\n🎉 ¡Listo! Abre '{ruta_salida}' en Power BI Desktop → Obtener datos → Excel")


# ─────────────────────────────────────────────────
#  7. FUNCIÓN PRINCIPAL — AJUSTA AQUÍ TUS RUTAS
# ─────────────────────────────────────────────────

def main():
    print("=" * 55)
    print("  DATATÓN SEGURIDAD SONORA — Pipeline")
    print("=" * 55)

    # ── AJUSTA ESTAS RUTAS A TUS ARCHIVOS ──────────────
    RUTA_MARGINACION = BASE_DIR / "marginacion_colonias.csv"
    RUTA_DELITOS     = BASE_DIR / "delitos_municipio.csv"

    # Opcionales — si no los tienes, se omiten automáticamente
    RUTA_POBREZA    = BASE_DIR / "pobreza_municipal.csv"
    RUTA_DESEMPLEO  = BASE_DIR / "desempleo_municipal.csv"
    RUTA_EDUCACION  = BASE_DIR / "educacion_municipal.csv"
    RUTA_MENORES    = BASE_DIR / "menores_infractores.csv"
    # ───────────────────────────────────────────────────

    # 1. Cargar datos obligatorios
    marg_mun = cargar_marginacion(RUTA_MARGINACION)
    delitos_agg, delitos_total, delitos_tiempo = cargar_delitos(RUTA_DELITOS)

    # 2. Cargar opcionales
    df_pobreza   = cargar_dataset_opcional(RUTA_POBREZA,   "Pobreza")
    df_desempleo = cargar_dataset_opcional(RUTA_DESEMPLEO, "Desempleo")
    df_educacion = cargar_dataset_opcional(RUTA_EDUCACION, "Educación")
    df_menores   = cargar_dataset_opcional(RUTA_MENORES,   "Menores infractores")

    # 3. Merge maestro
    maestro = construir_dataset_maestro(
        marg_mun, delitos_total, delitos_agg,
        df_pobreza, df_desempleo, df_educacion, df_menores
    )

    # 4. Tablas auxiliares
    pivot_tipos = crear_tabla_delitos_tipo(delitos_agg)
    corr_df     = crear_tabla_correlacion(maestro)

    # 5. Validación en consola
    analizar_correlacion(maestro)

    print("\n📋 Preview del dataset maestro:")
    print(maestro.head(5).to_string(index=False))

    # 6. Exportar
    exportar_excel(maestro, delitos_agg, delitos_tiempo, pivot_tipos, corr_df)


if __name__ == "__main__":
    main()
