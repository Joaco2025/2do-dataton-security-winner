"""Compare reproduced workbooks with the historical ones, sheet by sheet (RECONSTRUCTED CODE, 2026-11 recovery).

Usage: python src/verify.py --work build --reference <dir containing the historical workbooks>
Historical workbooks are not in the repository (see data/README.md); this step is optional.
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

PAIRS = [  # (reproduced, historical file name, expectation recorded in recovery/reproducibility_audit.md)
    ("A1/out/sonora_seguridad_powerbi.xlsx", "sonora_seguridad_powerbi.xlsx", "identical (12 sheets)"),
    ("A2/home/sonora_seguridad_powerbi.xlsx", "sonora_seguridad_powerbi__2026-04-22_1905.xlsx", "identical (18 sheets)"),
    ("A2/home/nuevos_datasets_sonora.xlsx", "nuevos_datasets_sonora(1).xlsx", "identical (7 sheets)"),
    ("A3/home/sonora_seguridad_powerbi.xlsx", "sonora_seguridad_powerbi(3).xlsx", "25/28 identical; 01 (accents), 24, 25 differ"),
    ("B/out/google_trends_sonora_narco.xlsx", "google_trends_sonora_narco(1).xlsx", "identical (6 sheets)"),
    ("C/out/sonora_maestro_v5.xlsx", "sonora_maestro_v5(1).xlsx", "identical (33 sheets)"),
    ("C/out/sonora_maestro_v6.xlsx", "sonora_maestro_v6.xlsx", "identical (36 sheets)"),
]


def same(a: pd.Series, b: pd.Series) -> np.ndarray:
    try:
        x = pd.to_numeric(a, errors="raise").fillna(-9e9).to_numpy()
        y = pd.to_numeric(b, errors="raise").fillna(-9e9).to_numpy()
        return np.isclose(x, y, atol=1e-6)
    except (ValueError, TypeError):
        return a.astype(str).to_numpy() == b.astype(str).to_numpy()


def compare(rep: Path, hist: Path) -> dict:
    A = pd.read_excel(rep, sheet_name=None)
    B = pd.read_excel(hist, sheet_name=None)
    res = {}
    for s, b in B.items():
        if s not in A:
            res[s] = "missing"; continue
        a = A[s]
        if a.shape != b.shape or list(a.columns) != list(b.columns):
            res[s] = f"shape {a.shape} vs {b.shape}"; continue
        bad = [c for c in b.columns if not same(a[c], b[c]).all()]
        res[s] = "identical" if not bad else f"differs in {bad[:3]}"
    return res


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--work", type=Path, default=Path("build"))
    ap.add_argument("--reference", type=Path, required=True)
    a = ap.parse_args()
    for rep, hist, expect in PAIRS:
        r, h = a.work / rep, next(a.reference.rglob(hist), None)
        if not r.exists() or h is None:
            print(f"SKIP {rep} (missing {'reproduced' if not r.exists() else 'reference'} file)"); continue
        res = compare(r, h)
        ok = sum(v == "identical" for v in res.values())
        print(f"{rep} vs {hist}: {ok}/{len(res)} sheets identical  [expected: {expect}]")
        for s, v in res.items():
            if v != "identical":
                print(f"    {s}: {v}")


if __name__ == "__main__":
    main()
