# PROVENANCE: ChatGPT export "GPT-B", conversation 69e80c4c-c108-83e8-8e6e-1eec9c985357, message index 7,
# 2026-04-21 23:49:25Z (16:49 Hermosillo). Verbatim except the personal user folder (replaced by <USER>).
# Produces the historical sesnsp_largo_2015_2025.csv: re-run in the recovery = identical rows AND order (56,312 x 8).
import pandas as pd

# Cargar el dataset que ya generaste
input_path = r"C:\Users\<USER>\Downloads\Dataton\sesnsp_2015_2025.csv"
df = pd.read_csv(input_path, encoding="utf-8-sig")

# Limpiar nombres de columnas
df.columns = df.columns.str.strip()

# Lista de meses
meses = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
]

# Columnas que se quedan fijas
id_vars = [
    "Año", "Cve. Municipio", "Bien jurídico afectado",
    "Tipo de delito", "Subtipo de delito", "Modalidad"
]

# Transformar a formato largo
df_largo = df.melt(
    id_vars=id_vars,
    value_vars=meses,
    var_name="Mes",
    value_name="Casos"
)

# Opcional: eliminar filas con 0 (reduce tamaño si quieres eficiencia)
df_largo = df_largo[df_largo["Casos"] > 0]

# Resetear índice
df_largo = df_largo.reset_index(drop=True)

# Guardar resultado
output_path = r"C:\Users\<USER>\Downloads\Dataton\sesnsp_largo_2015_2025.csv"
df_largo.to_csv(output_path, index=False, encoding="utf-8-sig")

print("Dataset transformado a formato largo correctamente 🚀")
print(f"Total filas nuevas: {len(df_largo)}")
