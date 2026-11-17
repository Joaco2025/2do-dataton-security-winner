"""Merge the SESNSP yearly municipal-incidence CSVs and build the long (monthly) format.

RECONSTRUCTED CODE (2026-11 recovery). Portable rewrite of the team's src/legacy/juntar_datos_ORIGINAL_local.py
(hard-coded Windows paths removed). The long-format step reproduces the historical
`sesnsp_largo_2015_2025.csv` layout, whose original code was NOT recovered: during the recovery it was
verified that the historical long file holds exactly the 56,312 non-zero month cells of the wide file,
so zero-case months are dropped here as well.

Usage: python src/merge_sesnsp.py <folder with 2015.csv ... 2025.csv> <output folder>
"""
from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd

MESES = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto",
         "Septiembre", "Octubre", "Noviembre", "Diciembre"]


def read_year(path: Path) -> pd.DataFrame:
    try:
        df = pd.read_csv(path, encoding="utf-8-sig")
    except UnicodeDecodeError:
        df = pd.read_csv(path, encoding="latin-1")
    df.columns = df.columns.str.strip().str.replace("A�o", "Año", regex=False)
    return df


def merge(folder: Path) -> pd.DataFrame:
    files = sorted(folder.glob("*.csv"))
    if not files:
        raise FileNotFoundError(f"no CSV files in {folder}")
    return pd.concat([read_year(f) for f in files], ignore_index=True)


def to_long(wide: pd.DataFrame) -> pd.DataFrame:
    ids = [c for c in wide.columns if c not in MESES]
    long = wide.melt(id_vars=ids, value_vars=MESES, var_name="Mes", value_name="Casos")
    long = long[long["Casos"] != 0]
    order = {m: i for i, m in enumerate(MESES)}
    return long.sort_values(["Año", "Cve. Municipio", "Mes"], key=lambda s: s.map(order) if s.name == "Mes" else s).reset_index(drop=True)


def main(src: str, out: str) -> None:
    out_dir = Path(out); out_dir.mkdir(parents=True, exist_ok=True)
    wide = merge(Path(src))
    wide.to_csv(out_dir / "sesnsp_2015_2025.csv", index=False, encoding="utf-8-sig")
    long = to_long(wide)
    long.to_csv(out_dir / "sesnsp_largo_2015_2025.csv", index=False, encoding="utf-8")
    print(f"wide: {wide.shape}  long (non-zero months): {long.shape}  years: {sorted(wide['Año'].unique())}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
