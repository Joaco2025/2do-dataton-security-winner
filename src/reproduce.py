"""Reproduce the historical Datatón master workbooks from raw data.

RECONSTRUCTED CODE (written during the 2026-11 recovery, not part of the original project).
It does NOT re-implement the analysis. It replays the *original* scripts recovered verbatim
from the Claude.ai conversation exports (src/historical/*.sh), in the order in which they were
executed in the Claude sandbox, after re-mapping the sandbox paths:

    /mnt/user-data/uploads   -> <work>/<stage>/up     (files the team uploaded)
    /mnt/user-data/outputs   -> <work>/<stage>/out    (files Claude handed back)
    /home/claude             -> <work>/<stage>/home   (Claude's scratch directory)

Each historical .sh file contains one or more `python3 << 'EOF' ... EOF` blocks and
occasionally `cp` commands. This runner executes the python blocks with the current
interpreter and performs the `cp` commands with shutil. Nothing else is executed.

Usage:
    python src/reproduce.py --raw <dir with raw files, see data/README.md> --work build
    python src/reproduce.py --raw ... --work build --stage C --v4 <sonora_maestro_v4.xlsx>
    python src/verify.py --work build --reference <dir with historical workbooks>   (optional)
"""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

HIST = Path(__file__).resolve().parent / "historical"

# Raw inputs: sandbox filename -> path relative to --raw (layout documented in data/README.md)
RAW_A = {
    "conjunto_de_datos_iter_26CSV20.csv": "censo_iter_2020/iter_26_cpv2020/conjunto_de_datos/conjunto_de_datos_iter_26CSV20.csv",
    "indice-de-marginacion-municipios-2020.xlsx": "contexto_socioeconomico/indice-de-marginacion-municipios-2020.xlsx",
    "DELITOS_DEL_2020_AL_2025.xlsx": "seguridad_incidencia/DELITOS_DEL_2020_AL_2025.xlsx",
    "sesnsp_largo_2015_2025.csv": "../interim/sesnsp_largo_2015_2025.csv",
    "Personas_Detenidas_en_el_primer_trimestre_2026.xlsx": "seguridad_incidencia/Personas Detenidas/datos/Personas Detenidas en el primer trimestre 2026.xlsx",
    # PERSONAL DATA (minors' names). Never commit. The scripts read only sex, age, locality, offence.
    "poblacion-itama-internamiento-1-trimestre-2026.xlsx": "restricted/poblacion-itama-internamiento-1-trimestre-2026.xlsx",
    "enoe_indicadores_estrategicos_2005_2026_mensual.xlsx": "contexto_socioeconomico/enoe_indicadores_estrategicos_2005_2026_mensual.xlsx",
    "Tasas_Infor_enti-1.xlsx": "enoe_informalidad/Tasas de informalidad por trimestre/Tasas_Infor_enti-1.xlsx",
    "Nacional_Tasas_Inf_Resu-1.xlsx": "enoe_informalidad/Tasas de informalidad por área geográfica/Nacional/Nacional_Tasas_Inf_Resu-1.xlsx",
    "Areas_Tasas_Inf_Resu-1.xlsx": "enoe_informalidad/Tasas de informalidad por área geográfica/Áreas urbanas/Areas_Tasas_Inf_Resu-1.xlsx",
}
RAW_A2 = {
    "Latin-America-the-Caribbean_aggregated_data_up_to_week_of-2026-04-11.xlsx": "seguridad_incidencia/Latin-America-the-Caribbean_aggregated_data_up_to_week_of-2026-04-11.xlsx",
    "Concentrado_indicadores_de_pobreza_2020.xlsx": "contexto_socioeconomico/Concentrado_indicadores_de_pobreza_2020.xlsx",
    "irs_municipal_2020.csv": "contexto_socioeconomico/irs_municipal_2020.csv",
    "02_rezago_habitacional_mun_2015.csv": "contexto_socioeconomico/02_rezago_habitacional_mun_2015.csv",
    "03_rezago_habitacional_mun_2020.csv": "contexto_socioeconomico/03_rezago_habitacional_mun_2020.csv",
    "01_viviendas_precarias_SIODS.csv": "contexto_socioeconomico/01_viviendas_precarias_SIODS.csv",
}
RAW_B = {f"multiTimeline_{i}_.csv": f"google_trends/multiTimeline({i}).csv" for i in range(1, 9)}
RAW_B["multiTimeline.csv"] = "google_trends/multiTimeline.csv"

# Stage definitions: ordered lists of recovered artifact ids (see recovery/recovered_code_catalog.csv)
STAGES = {
    # A1: 21-22 Apr, Claude account A -> sonora_seguridad_powerbi.xlsx (8 -> 12 sheets)
    "A1": ["CL1-C025", "CL1-C035", "CL1-C048", "CL1-C050"],
    # A2: 22 Apr, Claude account B -> 18-sheet master + nuevos_datasets_sonora.xlsx
    "A2": ["CL2-C008", "CL2-C010", "CL2-C011", "CL2-C012", "CL2-C013", "CL2-C015"],
    # A3: 23 Apr, account B -> relational table, sheets 19-25 (approximates sonora_seguridad_powerbi(3).xlsx)
    "A3": ["CL2-C021", "CL2-C025", "CL2-C029", "CL2-C030"],
    # B: 24 Apr, account A -> google_trends_sonora_narco.xlsx (anchor-rescaled, 14 terms discarded)
    "B": ["CL1-C059"],
    # C: 24 Apr, account B -> sonora_maestro_v5(1).xlsx and sonora_maestro_v6.xlsx (canonical)
    #    requires the historical intermediate sonora_maestro_v4.xlsx (its generating code was NOT recovered)
    "C": ["CL2-C043", "CL2-C047"],
}

HEREDOC = re.compile(r"python3\s*<<\s*'EOF'\n(.*?)\nEOF", re.S)


def artifact(aid: str) -> Path:
    hits = sorted(HIST.glob(f"{aid}_*.sh"))
    if not hits:
        raise FileNotFoundError(f"historical artifact {aid} not found in {HIST}")
    return hits[0]


def remap(text: str, d: Path) -> str:
    for old, sub in (("/mnt/user-data/uploads", "up"), ("/mnt/user-data/outputs", "out"), ("/home/claude", "home")):
        text = text.replace(old, (d / sub).as_posix())
    return text


def run_artifact(aid: str, d: Path) -> None:
    src = artifact(aid).read_text(encoding="utf-8")
    body = "\n".join(src.split("\n")[3:])  # drop the 3-line provenance header
    body = remap(body, d)
    pos = 0
    for m in HEREDOC.finditer(body):
        _run_cp_lines(body[pos:m.start()], d)
        script = d / f"_{aid}.py"
        script.write_text(m.group(1), encoding="utf-8")
        print(f"  [{aid}] python block ({m.group(1).count(chr(10)) + 1} lines)")
        r = subprocess.run([_python(), "-W", "ignore", str(script.resolve())], cwd=d, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", env={**_env(), "PYTHONIOENCODING": "utf-8"})
        if r.returncode != 0:
            print(r.stdout[-2000:], r.stderr[-3000:])
            raise SystemExit(f"historical artifact {aid} failed")
        pos = m.end()
    _run_cp_lines(body[pos:], d)


def _env():
    import os
    return dict(os.environ)


def _python() -> str:
    """Interpreter of the active environment (Windows venvs may report the base interpreter)."""
    import os
    cand = Path(sys.prefix) / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
    return str(cand) if cand.exists() else sys.executable


def _run_cp_lines(chunk: str, d: Path) -> None:
    for line in chunk.splitlines():
        line = line.strip()
        if line.startswith("cp "):
            parts = line.split()
            shutil.copy(parts[1], parts[2])
            print(f"  cp {Path(parts[1]).name} -> {Path(parts[2]).parent.name}/")


def stage_dir(work: Path, name: str) -> Path:
    d = work / name
    for sub in ("up", "out", "home"):
        (d / sub).mkdir(parents=True, exist_ok=True)
    return d


def put(mapping: dict, raw: Path, d: Path) -> None:
    for dst, rel in mapping.items():
        src = (raw / rel).resolve()
        if not src.exists():
            raise SystemExit(f"missing raw input: {src} (see data/README.md)")
        shutil.copy(src, d / "up" / dst)


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--raw", type=Path, required=True, help="data/raw directory (interim/ must be its sibling)")
    ap.add_argument("--work", type=Path, default=Path("build"))
    ap.add_argument("--stage", choices=["A", "B", "C", "all"], default="all")
    ap.add_argument("--v4", type=Path, help="historical sonora_maestro_v4.xlsx (needed for stage C)")
    ap.add_argument("--itama", type=Path, help="ITAMA 1T2026 workbook (PERSONAL DATA; default: <raw>/restricted/...)")
    a = ap.parse_args()
    a.work = a.work.resolve(); a.raw = a.raw.resolve()
    a.work.mkdir(parents=True, exist_ok=True)
    if a.itama:
        RAW_A["poblacion-itama-internamiento-1-trimestre-2026.xlsx"] = str(a.itama.resolve())

    if a.stage in ("A", "all"):
        d1 = stage_dir(a.work, "A1"); put(RAW_A, a.raw, d1)
        print("Stage A1"); [run_artifact(x, d1) for x in STAGES["A1"]]
        d2 = stage_dir(a.work, "A2"); put(RAW_A2, a.raw, d2)
        shutil.copy(d1 / "out" / "sonora_seguridad_powerbi.xlsx", d2 / "up" / "sonora_seguridad_powerbi.xlsx")
        print("Stage A2"); [run_artifact(x, d2) for x in STAGES["A2"]]
        d3 = stage_dir(a.work, "A3")
        shutil.copy(d2 / "home" / "sonora_seguridad_powerbi.xlsx", d3 / "up" / "sonora_seguridad_powerbi_2_.xlsx")
        shutil.copy(d2 / "home" / "nuevos_datasets_sonora.xlsx", d3 / "up" / "nuevos_datasets_sonora_1_.xlsx")
        shutil.copy(d2 / "home" / "sonora_seguridad_powerbi.xlsx", d3 / "home" / "sonora_seguridad_powerbi.xlsx")
        print("Stage A3"); [run_artifact(x, d3) for x in STAGES["A3"]]
    if a.stage in ("B", "C", "all"):
        db = stage_dir(a.work, "B"); put(RAW_B, a.raw, db)
        print("Stage B"); [run_artifact(x, db) for x in STAGES["B"]]
    if a.stage in ("C", "all"):
        if not a.v4:
            print("Stage C skipped: pass --v4 <historical sonora_maestro_v4.xlsx> (generating code not recovered)")
        else:
            dc = stage_dir(a.work, "C")
            shutil.copy(a.v4, dc / "up" / "sonora_maestro_v4.xlsx")
            shutil.copy(a.work / "B" / "out" / "google_trends_sonora_narco.xlsx", dc / "up" / "google_trends_sonora_narco_1_.xlsx")
            print("Stage C"); [run_artifact(x, dc) for x in STAGES["C"]]
    print("done ->", a.work.resolve())


if __name__ == "__main__":
    main()
