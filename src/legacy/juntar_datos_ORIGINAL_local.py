# NOTE (recovery): personal user folder in hard-coded paths replaced by <USER>; otherwise verbatim.
import pandas as pd
import glob
from pathlib import Path
import sys

# Forzar salida en UTF-8 (evita errores con caracteres especiales)
try:
    sys.stdout.reconfigure(encoding='utf-8')
except:
    pass

carpeta = Path(r"C:\Users\<USER>\Downloads\Dataton\Incidencia delictiva municipal\datos")

archivos = glob.glob(str(carpeta / "*.csv"))

dfs = []
for archivo in archivos:
    try:
        # Intentar UTF-8 primero
        df = pd.read_csv(archivo, encoding="utf-8-sig")
    except:
        # Si falla, usar latin1 (muy común en datasets mexicanos)
        df = pd.read_csv(archivo, encoding="latin1")
    
    dfs.append(df)

# Unir todos los dataframes
sesnsp_completo = pd.concat(dfs, ignore_index=True)

# Limpiar nombres de columnas (quitar espacios raros)
sesnsp_completo.columns = sesnsp_completo.columns.str.strip()

# Arreglar nombres mal codificados (por si acaso)
sesnsp_completo.columns = sesnsp_completo.columns.str.replace("A�o", "Año")

print(f"Total filas: {len(sesnsp_completo)}")
print(f"Columnas: {list(sesnsp_completo.columns)}")

# Validar columna Año de forma segura
if "Año" in sesnsp_completo.columns:
    print(f"Años: {sorted(sesnsp_completo['Año'].unique())}")
else:
    print("⚠️ No se encontró la columna 'Año', revisa encoding")

# Guardar archivo final
output_path = r"C:\Users\<USER>\Downloads\Dataton\sesnsp_2015_2025.csv"
sesnsp_completo.to_csv(output_path, index=False, encoding="utf-8-sig")

print("Archivo guardado correctamente en:", output_path)