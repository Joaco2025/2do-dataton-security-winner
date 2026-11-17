# PROVENANCE: account=c2 conversation=c22aaa72-a3e6-4b5a-a462-de4bd1707311 message_index=15 message_id=019dbdfb-08ab-7aec-9476-077eb8f42efe sender=assistant created_at=2026-04-24T05:36:15.202890Z kind=bash
# DESCRIPTION/PATH: Build regression models for narco and crime trends
# Preserved verbatim below this header. Not executed during recovery unless stated in reproducibility_audit.md.
python3 << 'EOF'
import pandas as pd
import numpy as np
from scipy import stats
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.metrics import r2_score

df_sesnsp = pd.read_excel('/mnt/user-data/uploads/sonora_seguridad_powerbi_2_.xlsx', sheet_name='03_SESNSP_2020_2025', header=0)

# Narcomenudeo anual
narco = df_sesnsp[df_sesnsp['tipo_delito']=='Narcomenudeo'].groupby('año')['casos'].sum().reset_index()
narco.columns = ['año','casos_narco']
total = df_sesnsp.groupby('año')['casos'].sum().reset_index()
total.columns = ['año','casos_total']
df_t = narco.merge(total, on='año')
print("Datos reales:")
print(df_t.to_string())

# Regresión lineal narco
X = df_t[['año']]
y_narco = df_t['casos_narco']
y_total = df_t['casos_total']

# Modelo narco
model_narco = LinearRegression().fit(X, y_narco)
r2_narco = r2_score(y_narco, model_narco.predict(X))
slope_narco = model_narco.coef_[0]
print(f"\nNarco - pendiente: {slope_narco:.1f} casos/año, R²={r2_narco:.3f}")

# Proyecciones 2026-2028
años_pred = pd.DataFrame({'año': [2026, 2027, 2028]})
pred_narco = model_narco.predict(años_pred)
print(f"Proyección narco: 2026={pred_narco[0]:.0f}, 2027={pred_narco[1]:.0f}, 2028={pred_narco[2]:.0f}")

# Modelo total
model_total = LinearRegression().fit(X, y_total)
r2_total = r2_score(y_total, model_total.predict(X))
print(f"\nTotal delitos - R²={r2_total:.3f}")

# Robo
robo = df_sesnsp[df_sesnsp['tipo_delito']=='Robo'].groupby('año')['casos'].sum().reset_index()
robo.columns = ['año','casos_robo']
model_robo = LinearRegression().fit(robo[['año']], robo['casos_robo'])
r2_robo = r2_score(robo['casos_robo'], model_robo.predict(robo[['año']]))
pred_robo = model_robo.predict(años_pred)
slope_robo = model_robo.coef_[0]
print(f"\nRobo - pendiente: {slope_robo:.1f} casos/año, R²={r2_robo:.3f}")
print(f"Proyección robo: 2026={pred_robo[0]:.0f}, 2027={pred_robo[1]:.0f}, 2028={pred_robo[2]:.0f}")

EOF
