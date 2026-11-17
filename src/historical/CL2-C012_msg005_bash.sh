# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=5 message_id=019db80d-52e5-78fe-82e2-fb8088c2429a sender=assistant created_at=2026-04-23T02:02:18.499691Z kind=bash
# DESCRIPTION/PATH: Fix sheet names and copy to output
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
# Fix sheet name length issue - rename long sheets
python3 << 'EOF'
from openpyxl import load_workbook

wb = load_workbook('/home/claude/sonora_seguridad_powerbi.xlsx')
# Rename any sheet > 31 chars
renames = {
    '13_ACLED_Sonora_Detalle': '13_ACLED_Detalle',
    '14_ACLED_Resumen_Anual': '14_ACLED_Resumen',
    '15_CONEVAL_Pobreza': '15_CONEVAL_Pobreza',
    '16_IRS_Rezago_Social': '16_IRS_Rezago_Social',
    '17_Rezago_Habitacional': '17_Rezago_Habit',
    '18_Viviendas_Precarias': '18_Viviendas_Prec',
}
for old, new in renames.items():
    if old in wb.sheetnames and len(old) > 31:
        wb[old].title = new
        print(f"Renamed: {old} -> {new}")

wb.save('/home/claude/sonora_seguridad_powerbi.xlsx')
print("Saved. Sheets:", wb.sheetnames)
EOF

# Copy both files to output
cp /home/claude/sonora_seguridad_powerbi.xlsx /mnt/user-data/outputs/sonora_seguridad_powerbi.xlsx
cp /home/claude/nuevos_datasets_sonora.xlsx /mnt/user-data/outputs/nuevos_datasets_sonora.xlsx
echo "Both files copied to output"