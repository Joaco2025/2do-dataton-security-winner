# NOTE (recovery): personal user folder in hard-coded paths replaced by <USER>; otherwise verbatim.
# PROVENANCE: account=c1 conversation=676e8ecf-240a-4846-ad7a-c09195d6828c message_index=19 message_id=019db26f-592b-74d0-83f9-01734343f107 sender=assistant created_at=2026-04-21T23:45:39.418526Z kind=fenced_assistant
# DESCRIPTION/PATH: 
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
import pandas as pd
import glob
from pathlib import Path

carpeta = Path(r"C:\Users\<USER>\Downloads\Dataton\Incidencia delictiva municipal\datos")

archivos = glob.glob(str(carpeta / "*.csv"))

dfs = []
for archivo in archivos:
    df = pd.read_csv(archivo, encoding="utf-8-sig")  # ← esto elimina el BOM
    dfs.append(df)

sesnsp_completo = pd.concat(dfs, ignore_index=True)

# Limpiar nombres de columnas por si acaso
sesnsp_completo.columns = sesnsp_completo.columns.str.strip()

print(f"Total filas: {len(sesnsp_completo)}")
print(f"Columnas: {list(sesnsp_completo.columns)}")
print(f"Años: {sorted(sesnsp_completo['Año'].unique())}")

sesnsp_completo.to_csv(r"C:\Users\<USER>\Downloads\Dataton\sesnsp_2015_2025.csv", index=False, encoding="utf-8")
print("✅ Archivo guardado")
