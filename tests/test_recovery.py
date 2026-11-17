"""Tests for the reconstructed helper code (not for the historical analysis itself)."""
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import audit_checks  # noqa: E402
import merge_sesnsp  # noqa: E402
import reproduce  # noqa: E402


def test_every_stage_artifact_exists():
    for stage, ids in reproduce.STAGES.items():
        for aid in ids:
            assert reproduce.artifact(aid).exists(), (stage, aid)


def test_remap_replaces_all_sandbox_roots(tmp_path):
    text = "a=/mnt/user-data/uploads/x.csv b=/mnt/user-data/outputs/y c=/home/claude/z"
    out = reproduce.remap(text, tmp_path)
    assert "/mnt/" not in out and "/home/claude" not in out
    assert (tmp_path / "up").as_posix() in out


def test_heredoc_and_cp_are_executed(tmp_path, monkeypatch):
    hist = tmp_path / "historical"; hist.mkdir()
    (hist / "T-C001_msg000_bash.sh").write_text(
        "# h1\n# h2\n# h3\n"
        "cp /mnt/user-data/uploads/a.txt /home/claude/a.txt\n"
        "python3 << 'EOF'\nopen('/mnt/user-data/outputs/b.txt','w').write(open('/home/claude/a.txt').read()+'!')\nEOF\n",
        encoding="utf-8")
    monkeypatch.setattr(reproduce, "HIST", hist)
    d = reproduce.stage_dir(tmp_path, "S")
    (d / "up" / "a.txt").write_text("hi")
    reproduce.run_artifact("T-C001", d)
    assert (d / "out" / "b.txt").read_text() == "hi!"


def test_mojibake_detection_and_fix():
    broken = "Bacadéhuachi".encode("utf-8").decode("latin-1")
    assert audit_checks.is_mojibake(broken)
    assert not audit_checks.is_mojibake("Bacadéhuachi")
    assert audit_checks.fix_mojibake(broken) == "Bacadéhuachi"


def test_merge_and_long_format_drop_zero_months(tmp_path):
    cols = ["Año", "Cve. Municipio", "Bien jurídico afectado", "Tipo de delito", "Subtipo de delito", "Modalidad"] + merge_sesnsp.MESES
    row = [2020, 26030, "X", "Robo", "Robo", "M"] + [0] * 11 + [5]
    for y in (2020, 2021):
        r = row.copy(); r[0] = y
        pd.DataFrame([r], columns=cols).to_csv(tmp_path / f"{y}.csv", index=False, encoding="utf-8-sig")
    wide = merge_sesnsp.merge(tmp_path)
    assert list(wide.columns)[0] == "Año" and len(wide) == 2
    long = merge_sesnsp.to_long(wide)
    assert len(long) == 2 and set(long["Mes"]) == {"Diciembre"}
