"""Post-hoc audit checks on the historical master table (RECONSTRUCTED CODE, 2026-11 recovery).

These functions do not change the historical results. They quantify problems found during the
recovery (see docs/10_limitations.md):
  * mojibake municipality names caused by reading the UTF-8 census file as latin-1,
  * rows lost in name-based joins,
  * how many municipalities actually carry the ITAMA signal behind r = +0.784.

Usage: python src/audit_checks.py <master workbook .xlsx>
"""
from __future__ import annotations

import sys

import pandas as pd

MOJIBAKE_MARKERS = ("Ã", "Â", "ã©", "ã¡", "ã³", "ã­", "ãº", "ã±")


def is_mojibake(name: str) -> bool:
    """True when a string shows the typical UTF-8-read-as-latin-1 pattern (e.g. 'BacadÃ©huachi')."""
    return isinstance(name, str) and any(m in name for m in MOJIBAKE_MARKERS)


def fix_mojibake(name: str) -> str:
    """Reverse a latin-1 mis-decoding of UTF-8 text when possible; return the input otherwise."""
    try:
        return name.encode("latin-1").decode("utf-8")
    except (UnicodeEncodeError, UnicodeDecodeError, AttributeError):
        return name


def join_losses(maestro: pd.DataFrame, detenidos: pd.DataFrame, itama: pd.DataFrame) -> dict:
    return {
        "municipios": len(maestro),
        "mojibake_names": int(maestro["municipio"].map(is_mojibake).sum()),
        "detentions_total": len(detenidos),
        "detentions_in_master": int(maestro["total_detenidos"].sum()),
        "itama_total": len(itama),
        "itama_in_master": int(maestro["menores_internados"].sum()),
        "municipios_with_itama_gt0": int((maestro["menores_internados"] > 0).sum()),
    }


def main(path: str) -> None:
    m = pd.read_excel(path, sheet_name="01_Maestro_Municipal")
    d = pd.read_excel(path, sheet_name="05_Personas_Detenidas")
    i = pd.read_excel(path, sheet_name="06_ITAMA_Menores")
    for k, v in join_losses(m, d, i).items():
        print(f"{k:28s} {v}")
    nz = m.loc[m["menores_internados"] > 0, ["municipio", "abs_NO_asiste_15a17", "menores_internados"]]
    print("\nMunicipalities with ITAMA > 0 (drive r(abs_NO_asiste_15a17, menores_internados)):")
    print(nz.to_string(index=False))
    r_all = m["abs_NO_asiste_15a17"].corr(m["menores_internados"])
    r_wo = m.loc[m["municipio"] != "Hermosillo", "abs_NO_asiste_15a17"].corr(m.loc[m["municipio"] != "Hermosillo", "menores_internados"])
    print(f"\nr with all 72 municipalities: {r_all:.3f} | without Hermosillo: {r_wo:.3f}")
    print("\nSensitivity (absolute counts vs percentages vs population):")
    print(sensitivity(m).to_string(index=False))


PAIRS = [
    ("abs_NO_asiste_15a17", "total_detenidos"),
    ("abs_NO_asiste_15a17", "menores_detenidos"),
    ("abs_NO_asiste_15a17", "menores_internados"),
    ("abs_NO_asiste_15a17", "poblacion_total"),
    ("pct_NO_asiste_15a17", "total_detenidos"),
    ("pct_NO_asiste_15a17", "menores_internados"),
    ("pct_NO_asiste_15a17", "tasa_detenidos_10k"),
    ("indice_marginacion", "tasa_delitos_10k"),
    ("pct_sin_educ_basica", "tasa_delitos_10k"),
]


def sensitivity(m: pd.DataFrame) -> pd.DataFrame:
    from scipy.stats import pearsonr, spearmanr
    rows = []
    for a, b in PAIRS:
        r, p = pearsonr(m[a], m[b])
        rows.append({"x": a, "y": b, "pearson_r": round(r, 3), "p_value": float(f"{p:.3g}"),
                     "spearman_rho": round(spearmanr(m[a], m[b])[0], 3), "n": len(m)})
    return pd.DataFrame(rows)


if __name__ == "__main__":
    main(sys.argv[1])
