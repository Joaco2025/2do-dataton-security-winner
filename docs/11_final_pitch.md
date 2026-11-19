# 11 · Final pitch

## Pitch evolution (all versions recovered from the Claude exports; texts kept in the private evidence archive)

| Ver. | Time (local) | Source | Form | Key traits |
|---|---|---|---|---|
| P0 | 24 Apr 17:01 | CL2 msg 33 | advice | Claude recommends writing a 5-minute script while a teammate finishes the dashboard |
| P1 | 25 Apr 00:18 | CL2 msg 65 | 5-min timed script | requested as "el mejor vendedor del mundo"; hook "El crimen no está donde está la pobreza. Está donde están los jóvenes"; cites r = −0.49 and r = +0.90 |
| G1–G3 | 25 Apr 00:33 / 00:48 / 01:23 | ChatGPT GPT-A `69ec6e24`, `69ec71c3`, `69ec79d1` msg 1 | hero's-journey scripts from the three latest PDF exports | **G3 introduces the title "Lo que los datos sí nos dejaron ver"** |
| G4 | 25 Apr 09:37 | GPT-A `69ec79d1` msg 3 | cards | "un toque relajado de Steve Jobs" |
| G5 | 25 Apr 10:04–10:14 | GPT-A `69ec79d1` msgs 5–7 | cards in **dashboard order** | team: *"no digas un dato que sale en una gráfica de hasta abajo, tiene que seguir la secuencia de aparición"*; the team pastes its own card set (CARD 1 CONTEXTO…) |
| P2 | 25 Apr 10:24 | CL1 msg 69 | cards | "Del Aula a la Calle", hero's journey + relaxed Steve Jobs tone, "nada de inferencias"; opens on Aconchi |
| P3 | 25 Apr 10:33–10:54 | CL1 msgs 71–75 | 9–10 cards | team pastes a ChatGPT-style skeleton (Contexto → Pregunta → Lo inesperado…); 3 key municipalities on the map; sources per card; policy close (becas, reinserción) + FAQ card |
| P4 | 25 Apr 11:03–11:13 | CL1 msgs 77, 79 | FAQ | "¿Cómo podemos hilar todo esto?"; honest answer on projection uncertainty ("bastante, y lo sabemos"; 6 annual points) |
| P5 | 25 Apr 11:44 | CL1 msg 81 (skeleton in msg 80 = the ChatGPT G3 structure pasted by the team) | cards | team: "tu conclusión asume, todo lo tenemos que sacar de los datos"; title **"Lo que los datos sí nos dejaron ver"** |
| **P6** | **25 Apr 11:59** | **CL1 msg 83** | **continuous script** | **last version produced before the presentation – reproduced verbatim below** |

**Status:** P6 is the final *written* pitch [VERIFIED]. Whether it was delivered verbatim, abridged, or split
among speakers is **[UNKNOWN]**. The presenter planned to read **cards from a phone** (GPT-A msgs 8–11, 11:00 local, asking for a card/teleprompter app), so the last ChatGPT card set (G5) and P6 are both candidates. No recording, slides or speaker notes exist in the material. The organisers
required no slides; the dashboard itself was the visual (stage directions such as *[Abrir el mapa de Sonora]*).

### How the narrative changed

1. **From accusation to discovery.** P1 is a sales pitch ("pueden venderle una oración al papa"). P5–P6 reframe it as testing a comfortable narrative with data.
2. **From certainty to coexistence.** Google Trends goes from evidence of "normalización cultural del crimen" (sheet 28 note) to *"No estamos diciendo que cause el delito. Pero sí que coexiste con él"* in P6.
3. **The team pushed for less inference** (CL1 msgs 68, 80). The written conclusion still contains claims that the data do not support as stated (see the annotations below and `10_limitations.md`, K1–K5).

### Claim check of P6 (recovery annotation, not part of the pitch)

| Claim in P6 | Check |
|---|---|
| marginación vs delitos "débil. 0.32" | r = +0.321 [REPRODUCED] – weak but significant (p = 0.006) |
| "El **porcentaje** de jóvenes de 15 a 17 años fuera de la escuela … 0.61 / 0.78 / 0.90" | values are for the **absolute count**; for the percentage: −0.06 / −0.08 / −0.10 [REPRODUCED]. The published dashboard labels the row correctly as "Jóvenes 15-17 sin escuela (abs)", so the error is only in the spoken script |
| Hermosillo: "8,844 jóvenes … fuera de la escuela … más menores internados en el ITAMA" | 8,844 [REPRODUCED]; Hermosillo 16 matched ITAMA cases (Cajeme's 16 "Obregon" cases were lost in the join) |
| 77 % narcomenudeo · 16 años · 86 % hombres · 91 % ciudades grandes | 27/35 = 77.1 %, mean 16.1, 30/35 = 85.7 % [REPRODUCED]; 91 % depends on locality parsing |
| Google Trends interest ×10 2021–2023 | ≈ ×9.5 for the sum of four artists [REPRODUCED]; fell in 2025 |
| "Regresión polinomial de grado 2. R² de 0.934 … explica el 93 % de lo que ya pasó" | in-sample fit on 6 points [STORED]; not on the submitted dashboard |
| Policy: becas for 15–17 in Hermosillo, Cajeme, Guaymas, Navojoa | recommendation, framed by the pitch as "lo que los datos sugieren" |

---

## P6 — "Lo que los datos sí nos dejaron ver" (verbatim)

> Source: Claude.ai account A, conversation `676e8ecf…`, message index 83, 2026-04-25 18:59:29 UTC (11:59 local).
> AI-generated from the team's skeleton and instructions; preserved without edits.

# 🎤 "Lo que los datos sí nos dejaron ver"

---

Vivimos en una narrativa muy cómoda.

Cuando hablamos de delincuencia, repetimos casi en automático:
"es la pobreza", "es la marginación", "es la densidad poblacional".

Es una historia sencilla. Ordenada. Tranquilizadora.

Pero nosotros decidimos comprobarla con datos.

*[Abrir el mapa de Sonora.]*

---

Tomamos información de Sonora — incidencia delictiva, factores educativos, marginación, población, datos de menores internados y modelos predictivos.

Queríamos responder una pregunta simple:

¿Qué está realmente detrás del aumento del delito?

*[Seleccionar Hermosillo. Pausa. Seleccionar Guaymas. Pausa. Seleccionar Quiriego.]*

Tres municipios. Perfiles completamente distintos. Y los datos empezaron a contar algo que no esperábamos.

---

Porque aquí fue donde todo se empezó a romper.

*[Señalar scatter plot.]*

La relación entre marginación y delitos… es débil. 0.32.
La relación con densidad poblacional… tampoco explica el fenómeno.

La narrativa clásica no se sostiene.

---

Entonces dejamos de buscar lo obvio… y empezamos a observar lo incómodo.

*[Señalar tabla de correlaciones.]*

Encontramos algo distinto.

El porcentaje de jóvenes de 15 a 17 años fuera de la escuela tiene correlaciones fuertes:
0.61 con menores detenidos.
0.78 con menores internados.
0.90 con total de detenidos.

No es una pista… es una señal luminosa.

---

Aquí cambiamos la pregunta.

Ya no es "¿qué tan pobre es un lugar?"

Ahora es "¿cuántos jóvenes están fuera del sistema educativo?"

*[Seleccionar Hermosillo en el mapa.]*

Marginación muy baja. 8,844 jóvenes de 15 a 17 años fuera de la escuela. El municipio con más menores internados en el ITAMA.

Eso no lo explica la narrativa tradicional.

---

Los datos de menores internados refuerzan la historia.

*[Señalar donut y KPIs.]*

77% están por narcomenudeo.
Edad promedio: 16 años.
86% hombres.
91% provienen de ciudades grandes.

Esto no es crimen sofisticado.
Es entrada temprana al delito.

---

Y luego aparece el patrón más delicado.

*[Señalar gráfica Google Trends.]*

Medimos el interés en narcocultura en Sonora usando Google Trends — Peso Pluma, Junior H, Natanael Cano, Gabito Ballesteros. Entre 2021 y 2023 ese interés se multiplicó por diez en el estado.

El mismo periodo en que el narcomenudeo empezó su alza sostenida.

No estamos diciendo que cause el delito.
Pero sí que coexiste con él en el mismo ecosistema social.

---

El modelo predictivo, basado en datos históricos, dice algo claro.

*[Señalar gráfica de proyección.]*

Si la tendencia sigue, los delitos vinculados a delincuencia organizada seguirán aumentando.

No es opinión.
Es proyección. Regresión polinomial de grado 2. R² de 0.934. El modelo explica el 93% de lo que ya pasó.

---

Entonces juntamos todo.

*[Seleccionar Hermosillo, luego Cajeme, luego Guaymas en el mapa.]*

Tres ciudades. Marginación muy baja. Las tres con los mayores volúmenes de jóvenes fuera de la escuela. Las tres concentrando el grueso de menores detenidos e internados.

No es principalmente marginación.
No es principalmente densidad.

Es una combinación donde destaca: deserción educativa en jóvenes urbanos, expuestos a entornos de riesgo.

---

Y esto cambia completamente cómo deberíamos responder al problema.

Porque si atacamos solo con estrategias de seguridad…
estamos llegando tarde.

El origen no está en la calle.
Está antes.

---

Lo que los números permiten decir es esto:

Becas para jóvenes de 15 a 17 años en Hermosillo, Cajeme, Guaymas y Navojoa. Programas de reingreso escolar en las colonias con mayor deserción. Incentivos reales para que un joven de 16 años elija el aula antes de que alguien más le ofrezca otra opción.

No es intuición.
Es lo que los datos sugieren.

---

No venimos a dar una solución mágica.

Venimos a decir esto:

La historia que nos contamos sobre el crimen…
no es la historia completa.

Pero los datos sí nos dejan ver una grieta clara:

Ahí donde un joven sale de la escuela,
el sistema pierde control…
y el delito encuentra espacio.
