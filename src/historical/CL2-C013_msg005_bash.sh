# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=5 message_id=019db80d-52e5-78fe-82e2-fb8088c2429a sender=assistant created_at=2026-04-23T02:02:18.499691Z kind=bash
# DESCRIPTION/PATH: Trim all sheet names to 31 chars max
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
# Fix ALL sheet names > 31 chars
python3 << 'EOF'
from openpyxl import load_workbook

wb = load_workbook('/home/claude/sonora_seguridad_powerbi.xlsx')
for ws in wb.worksheets:
    if len(ws.title) > 31:
        old = ws.title
        ws.title = ws.title[:31]
        print(f"Trimmed: '{old}' -> '{ws.title}'")

wb.save('/home/claude/sonora_seguridad_powerbi.xlsx')

import shutil
shutil.copy('/home/claude/sonora_seguridad_powerbi.xlsx', '/mnt/user-data/outputs/sonora_seguridad_powerbi.xlsx')
print("Done. All sheets:", wb.sheetnames)
EOF