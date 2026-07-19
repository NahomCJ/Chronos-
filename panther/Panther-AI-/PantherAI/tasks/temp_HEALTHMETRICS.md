# Chronos — Financial Health Metrics Framework

**Versión:** 1.0  
**Fecha:** 12 abril 2026  
**Estado:** Definición cerrada — listo para implementación MVP

---

## 1. Visión de producto

Chronos aspira a ser el Whoop de las finanzas personales: un sistema que transforma datos bancarios en bruto en un loop de feedback continuo que informa, alerta y prescribe. El framework se construye sobre una analogía estructural con Whoop, no cosmética — cada métrica ocupa una posición funcional equivalente en el ciclo de feedback.

El objetivo no es optimizar la salud financiera como un fin abstracto. Es dar al usuario suficiente visibilidad y control para que **deje de preocuparse por el dinero**. El sistema debe incorporar un concepto de suficiencia: un estado donde las métricas son sanas y la app felicita en lugar de seguir presionando.

---

## 2. Principios de diseño

**Ortogonalidad.** Las cuatro métricas primarias capturan dimensiones independientes. Ninguna es derivable de las otras. Esto maximiza la información por slot visual y evita redundancia.

**Cadencia escalonada.** Cada métrica se mueve a una frecuencia distinta, generando cuatro razones para volver a la app en momentos diferentes: por transacción, semanal, mensual, y por evento estructural.

**Accionabilidad.** Cada métrica abre una superficie de recomendación diferenciada. No todas dicen "gasta menos" — el set completo permite desde ajustes diarios de ritmo hasta reestructuración de costes fijos.

**Anti-orthorexia financiera.** El sistema no debe patologizar el gasto. Una cena, unas vacaciones o un capricho planificado no son indicadores de mala salud financiera. Las métricas miden sostenibilidad y tendencia, no austeridad.

**Normalización lineal.** Todas las conversiones de métricas a scores usan tramos lineales con breakpoints fijos. El usuario tiene que poder intuir "si hago X, mi score sube Y". Las funciones no lineales lo oscurecen.

---

## 3. Arquitectura del framework

### 3.1 El loop de feedback

```
Momentum ──→ Alerta: "tu tendencia está cayendo"
   │
   ▼
Commitment Ratio ──→ Diagnóstico: "tus fijos han subido un 4%"
   │
   ▼
Burn Rate ──→ Acción diaria: "hoy ajusta tu ritmo"
   │
   ▼
Runway ──→ Resultado: "tu colchón se estabiliza"
   │
   ▼
Momentum ──→ Confirmación: "la tendencia se recupera"
```

Cada métrica diagnostica y la siguiente prescribe. El ciclo completo conecta detección → comprensión → acción → resultado → verificación.

### 3.2 Perfiles de usuario

El sistema soporta dos perfiles de ingreso. La detección es automática.

**Perfil A: nómina estable.** Se detecta cuando existe un pagador con mismo importe (±5%), misma fecha (±3 días), cadencia mensual durante al menos 3 meses consecutivos. El ingreso mensual es ese importe. Si hay pagas extra, se amortizan mensualmente (14 pagas → ingreso mensual = nómina × 14/12). Es el perfil mayoritario.

**Perfil B: ingresos irregulares.** Se activa cuando no se detecta patrón de nómina estable en los últimos 3 meses (freelancers, autónomos, comisiones variables).

```
ingreso_referencia = percentil_25(ingresos_últimos_6_meses)
```

Se usa percentil 25 en lugar de media porque la media sobrestima el ingreso predecible. Esto hace que Burn Rate sea más exigente y Runway más realista — mejor ser conservador que optimista.

**Onboarding con historial insuficiente (< 3 meses).** El usuario declara un ingreso mensual estimado. El sistema recalibra automáticamente a medida que acumula datos reales. Banner visible: "Tus métricas se están calibrando — necesitamos 3 meses de datos para ser precisos."

### 3.3 Detección de transferencias entre cuentas propias

**Requisito previo:** el usuario conecta todas sus cuentas bancarias. Si solo conecta una, no se puede detectar — pero tampoco importa, porque solo ve un lado de la ecuación.

**Lógica de matching con múltiples cuentas conectadas:**

```
IF cuenta_A tiene cargo de X€ en fecha T
AND cuenta_B tiene abono de X€ (±1€) en fecha T (±2 días)
AND ambas cuentas pertenecen al mismo usuario
THEN marcar como transferencia interna → excluir de ingresos Y gastos
```

La tolerancia de ±1€ cubre comisiones de transferencia. La de ±2 días cubre tiempos de procesamiento entre bancos.

**Validación:** las primeras 3-5 transferencias detectadas se muestran al usuario para confirmar. Una vez validado el patrón (mismas dos cuentas, importes similares), se automatizan las siguientes.

**Transferencias a cuentas no conectadas:** el usuario puede marcar un beneficiario como "cuenta propia" y todas las transferencias a ese beneficiario se reclasifican. No es elegante, pero funciona para MVP.

---

## 4. Métricas primarias

### 4.1 Burn Rate

| Campo | Detalle |
|-------|---------|
| **Qué mide** | Ritmo de gasto actual vs. presupuesto sostenible ajustado al día del mes |
| **Analogía Whoop** | Strain — cuánto esfuerzo estás ejerciendo hoy |
| **Cadencia** | Se actualiza con cada transacción |
| **Rol en el loop** | Control de ritmo diario. Es la métrica que el usuario mira al abrir la app |
| **Superficie de recomendación** | "Vas un 15% por encima del ritmo sostenible hoy — considera aplazar compras no urgentes" |

**Fórmula:**

```
burn_rate = gasto_acumulado_mes / (presupuesto_mensual × día_actual / días_del_mes)
```

- Valor < 1.0 → vas por debajo del ritmo (verde)
- Valor = 1.0 → vas exactamente en línea (neutro)
- Valor > 1.0 → vas por encima del ritmo (alerta)

**Normalización a score parcial (0-100):**

| Burn Rate | Score parcial |
|-----------|--------------|
| ≤ 0.70 | 100 |
| 0.70 – 1.00 | 100 → 70 (lineal) |
| 1.00 – 1.30 | 70 → 30 (lineal) |
| ≥ 1.30 | 0 |

La zona 0.70-1.00 puntúa alto intencionadamente. No penalizamos al usuario que va en ritmo — penalizamos al que se pasa. Estar por debajo de 0.70 no da puntos extra para no reforzar orthorexia financiera.

**Umbrales de estado (UI):**

| Estado | Rango |
|--------|-------|
| Óptimo | < 0.80 |
| Saludable | 0.80 – 1.00 |
| Atención | 1.00 – 1.20 |
| Crítico | > 1.20 |

**Amortización de gastos irregulares (lumpy expenses).**

Cargos anuales o trimestrales predecibles (seguro de coche, IBI, revisión dental) se amortizan mensualmente en el presupuesto base. Una póliza anual de 1.200€ contribuye 100€/mes al presupuesto, no un pico de 1.200€ el mes del cargo.

Lógica de detección: escanear 12 meses de historial buscando cargos que cumplen: mismo merchant (±variación menor de nombre), importe similar (±15%), periodicidad anual, semestral o trimestral.

Tratamiento: el cargo detectado se excluye del gasto variable del mes en que ocurre y se redistribuye como gasto fijo mensual amortizado. Se suma al Commitment Ratio y se resta del gasto variable de Burn Rate.

Confirmación: el sistema propone la amortización y el usuario confirma. No se hace automáticamente porque hay cargos anuales que el usuario puede querer cancelar — amortizarlos invisibiliza la oportunidad.

Edge case (< 12 meses de historial): el usuario puede marcar manualmente un gasto como "irregular recurrente" e indicar su frecuencia. Es una experiencia peor, pero funciona desde el día 1.

**Insight derivado incluido en pantalla de detalle:**

> "Al ritmo actual, este mes ahorrarás un 18% de tus ingresos."

Savings Rate proyectado pierde su slot como métrica primaria pero retiene su valor como traductor dentro de Burn Rate. Es demasiado útil para eliminarlo, pero no justifica uno de los cuatro asientos.

---

### 4.2 Commitment Ratio

| Campo | Detalle |
|-------|---------|
| **Qué mide** | Qué porcentaje de tus ingresos está comprometido en obligaciones recurrentes antes de que empiece el mes |
| **Analogía Whoop** | Frecuencia cardíaca en reposo — tu condición estructural de base |
| **Cadencia** | Se mueve cuando cambia una obligación (nueva suscripción, fin de préstamo, subida de alquiler) |
| **Rol en el loop** | Diagnóstico estructural. Responde a "¿por qué me cuesta llegar a fin de mes?" cuando Burn Rate está bien |
| **Superficie de recomendación** | "Tienes 14 suscripciones activas. 3 no las usas desde hace 2 meses — cancelarlas libera 47€/mes" |

**Fórmula:**

```
commitment_ratio = suma(obligaciones_recurrentes_mensuales) / ingreso_mensual_promedio
```

**Qué cuenta como obligación recurrente:** cualquier cargo con periodicidad predecible que requiere una acción explícita de cancelación para dejar de pagarse. Incluye: alquiler/hipoteca, seguros, préstamos, suscripciones, cuotas de gimnasio, pagos de coche. Excluye: supermercado semanal (recurrente en patrón pero no en compromiso — puedes gastar 80€ o 120€ sin cancelar nada).

**Normalización a score parcial (0-100):**

| Commitment Ratio | Score parcial |
|------------------|--------------|
| ≤ 25% | 100 |
| 25% – 50% | 100 → 65 (lineal) |
| 50% – 70% | 65 → 25 (lineal) |
| ≥ 70% | 0 |

El techo de 100 en 25% puede parecer generoso, pero si solo un cuarto de tus ingresos está comprometido, tu estructura es excelente. El cliff real está en 50%+ donde se pierde flexibilidad de maniobra.

**Umbrales de estado (UI):**

| Estado | Rango |
|--------|-------|
| Óptimo | < 30% |
| Saludable | 30% – 50% |
| Atención | 50% – 65% |
| Crítico | > 65% |

**Rol dual:** Commitment Ratio también aparece como modificador contextual de Runway (ver sección 4.3). No es redundancia — la misma señal informa dos preguntas distintas: "qué tan rígida es mi economía" (métrica primaria) y "qué tan estirable es mi colchón si pierdo ingresos" (contexto de Runway).

**Capa de detección proactiva (requisito V1).**

Sin esta capa, Commitment Ratio puede no moverse en 3-4 meses para usuarios asalariados estables. Un número estático en una de las cuatro métricas primarias erosiona la confianza en todo el sistema. Tres features mínimas:

**a) Detector de suscripciones fantasma.** Cargo recurrente mensual de merchant categorizado como servicio/suscripción donde el importe no ha variado en 3+ meses. El sistema cruza con una lista de merchants conocidos (Spotify, Netflix, HBO, gym chains, etc.) y alerta si no hay evidencia de uso. "Evidencia de uso" en MVP = si hay otras transacciones del mismo merchant distintas del cargo fijo. Si la única interacción con Netflix es el cargo mensual de 17.99€, probablemente no se está usando. Limitación: proxy imperfecta — no se sabe si el usuario abre la app. Pero es mejor que nada.

**b) Alertas de renovación anual.** Detección de cargos anuales/semestrales (misma lógica que la amortización de Burn Rate) con alerta push 14 días antes del próximo cargo esperado. El mensaje incluye el importe y la opción de "mantener" o "revisar/cancelar".

**c) Resumen mensual de compromisos.** Una vez al mes, independientemente de si algo ha cambiado, el sistema presenta la lista completa de compromisos recurrentes con sus importes. Muchos usuarios no son conscientes de cuántas suscripciones tienen hasta que las ven listadas juntas. Es el equivalente financiero de pesarse — el número no cambia todos los días pero el acto de mirar tiene valor.

---

### 4.3 Runway

| Campo | Detalle |
|-------|---------|
| **Qué mide** | Cuántos meses podrías mantener tu nivel de vida actual sin ingresos |
| **Analogía Whoop** | Sleep Performance — tu nivel de recuperación base |
| **Cadencia** | Movimiento perceptible mensual |
| **Rol en el loop** | Métrica ancla. Da tranquilidad o genera alarma existencial |
| **Superficie de recomendación** | "Has bajado de 3 meses de colchón — considera reducir gasto discrecional hasta estabilizar" |

**Fórmula:**

```
runway = activos_líquidos / gasto_mensual_suavizado_90d
```

- Se usa media suavizada de 90 días para el denominador, eliminando distorsión por meses atípicos (vacaciones en casa de los padres, gasto extraordinario puntual).
- "Activos líquidos" = saldo disponible en cuentas corrientes + ahorro accesible. No incluye inversiones en brokerage a menos que el usuario las marque explícitamente como liquidables.

**Normalización a score parcial (0-100):**

| Runway (meses) | Score parcial |
|----------------|--------------|
| ≥ 6 | 100 |
| 3 – 6 | 65 → 100 (lineal) |
| 1 – 3 | 25 → 65 (lineal) |
| < 1 | 0 → 25 (lineal) |

El techo de 100 en 6 meses es deliberado. No se dan puntos extra por tener 12 meses de colchón vs 6. Esto evita incentivar acumulación excesiva de liquidez cuando ese capital podría estar invertido. 6 meses es el consenso en finanzas personales como colchón de emergencia suficiente.

**Umbrales de estado (UI):**

| Estado | Rango |
|--------|-------|
| Óptimo | > 6 meses |
| Saludable | 3 – 6 meses |
| Atención | 1 – 3 meses |
| Crítico | < 1 mes |

**Modificadores contextuales (visibles en pantalla de detalle):**

**a) Erosión por deuda.** Si el usuario tiene deuda activa (préstamo, BNPL, tarjeta revolving), Runway muestra:

```
runway_bruto = activos_líquidos / gasto_mensual_suavizado
runway_neto  = (activos_líquidos - deuda_total) / gasto_mensual_suavizado
```

Si runway_neto es negativo (debe más de lo que tiene líquido), el sistema muestra runway_bruto con un indicador de que la posición neta es negativa. Lenguaje: "Tienes 2.4 meses de colchón, pero tu deuda de 8.200€ supera tu liquidez. Priorizar la reducción de deuda fortalecerá tu Runway."

Detección de deuda en MVP: cargos etiquetados como préstamo/financiación por el banco, pagos a financieras conocidas (Cetelem, Cofidis, Klarna, etc.), o marcado manual del usuario.

**b) Flexibilidad del colchón.** Commitment Ratio aparece como contexto de Runway:

```
runway_flexible = activos_líquidos / (gasto_mensual × commitment_ratio)
```

Esto responde a "si pierdo ingresos, ¿cuánto dura mi colchón si solo pago lo que no puedo cancelar?". Un Runway de 3 meses con Commitment Ratio del 35% tiene un runway_flexible de ~8.6 meses — porque se puede cortar el 65% del gasto. Uno de 3 meses con Commitment Ratio del 75% tiene un runway_flexible de ~4 meses — casi no hay margen.

El número primario siempre es runway_bruto (escenario "mantengo mi vida igual"). Los modificadores son contexto, no métricas competidoras.

**Diseño consciente:** Runway es la métrica más lenta del set. Eso es correcto — su función es ser el ancla estable que da contexto a las demás, no generar engagement diario.

---

### 4.4 Momentum

| Campo | Detalle |
|-------|---------|
| **Qué mide** | La dirección y magnitud del cambio en tu posición financiera |
| **Analogía Whoop** | HRV Trend — ¿estás mejorando o empeorando? |
| **Cadencia** | Movimiento perceptible semanal |
| **Rol en el loop** | Señal de alerta temprana y refuerzo positivo |
| **Superficie de recomendación** | "Tu Momentum lleva 2 semanas negativo — revisa tu Commitment Ratio para posibles ajustes estructurales" |

**Fórmula:**

```
momentum = posición_neta_mes_actual - media(posición_neta_últimos_3_meses)
```

Donde `posición_neta` = ingresos acumulados - gastos acumulados en el período.

- Positivo → estás mejorando respecto a tu baseline reciente
- Negativo → estás empeorando
- La magnitud indica cuánto

**Normalización a score parcial (0-100):**

| Momentum (% vs baseline) | Score parcial |
|---------------------------|--------------|
| ≥ +15% | 100 |
| 0% – +15% | 70 → 100 (lineal) |
| -15% – 0% | 30 → 70 (lineal) |
| ≤ -15% | 0 |

Momentum neutro (0%) puntúa 70, no 50. Razón: mantener la posición estable no es mediocre, es sano. Solo se penaliza la tendencia negativa.

**Umbrales de estado (UI):**

| Estado | Rango |
|--------|-------|
| Óptimo | > +10% |
| Saludable | 0% – +10% |
| Atención | -10% – 0% |
| Crítico | < -10% |

**Decisión de diseño: simplicidad sobre velocidad.** Se consideró un cruce de EMAs estilo MACD (EMA 30d vs EMA 90d del cashflow neto diario). Es matemáticamente más reactivo pero behaviorally opaque — el usuario no puede construir intuición sobre qué mueve un cruce de medias exponenciales. La formulación elegida sacrifica algo de velocidad de respuesta a cambio de que el usuario pueda verbalizar qué significa: "este mes me está yendo mejor/peor que los últimos tres."

---

## 5. Chronos Score (métrica compuesta)

**Fórmula:**

```
chronos_score = burn_rate_norm × 0.30
              + commitment_ratio_norm × 0.25
              + runway_norm × 0.25
              + momentum_norm × 0.20
```

| Métrica | Peso |
|---------|------|
| Burn Rate | 30% |
| Commitment Ratio | 25% |
| Runway | 25% |
| Momentum | 20% |

**Umbrales de estado (UI):**

| Estado | Rango |
|--------|-------|
| Óptimo | > 80 |
| Saludable | 60 – 80 |
| Atención | 40 – 60 |
| Crítico | < 40 |

**Pesos fijos, no adaptativos.** Los pesos no cambian según la "etapa financiera" del usuario. Los pesos adaptativos destruyen la capacidad del usuario de predecir qué mueve su score. "Hice lo mismo que el mes pasado pero mi puntuación cambió porque los pesos se reajustaron" genera desconfianza. Si un usuario con Runway crítico necesita atención especial, eso se resuelve con alertas contextuales, no manipulando el score.

### 5.1 Modo suficiencia

**Activación:** Chronos Score ≥ 80 durante 4 semanas consecutivas.

La ventana de 4 semanas evita que un mes atípicamente bueno (paga extra, mes con pocos gastos) active el modo prematuramente. Se requiere consistencia, no un pico.

**Comportamiento del modo suficiencia:**

- La pantalla principal muestra un estado visual de calma (no celebración excesiva — calma). Mensaje tipo: "Tu salud financiera está en buen estado."
- Las notificaciones se reducen a un resumen semanal en vez de alertas por transacción.
- Las recomendaciones pasan de "qué mejorar" a "qué mantener" — refuerzo positivo, no optimización.
- Si alguna métrica individual entra en Atención o Crítico, el modo suficiencia se pausa para esa métrica específica sin desactivar todo el sistema.

---

## 6. Tabla resumen

| # | Métrica | Qué mide | Cadencia | Whoop | Superficie de recomendación |
|---|---------|----------|----------|-------|-----------------------------|
| 1 | **Burn Rate** | Ritmo de gasto vs presupuesto | Cada transacción | Strain | "Ajusta tu ritmo hoy" |
| 2 | **Commitment Ratio** | Rigidez de costes fijos | Cambio de obligación | Resting HR | "Reestructura tus fijos" |
| 3 | **Runway** | Meses de colchón | Mensual | Sleep | "Refuerza tu buffer" |
| 4 | **Momentum** | Dirección del cambio | Semanal | HRV Trend | "Tu tendencia mejora/empeora" |
| Σ | **Chronos Score** | Salud financiera global | Derivado | Recovery | Score 0-100 |

---

## 7. Riesgos de producto identificados

### 7.1 Orthorexia financiera (riesgo alto)

El mayor riesgo del producto es crear una relación ansiosa con el dinero. La analogía con Whoop es poderosa pero peligrosa: Whoop funciona porque "más Recovery = mejor" es casi siempre verdad. "Mayor Chronos Score = mejor" solo es verdad hasta un punto. Un usuario que ahorra el 50% de sus ingresos y nunca viaja tiene un score perfecto y una vida empobrecida. El sistema debe celebrar el gasto consciente, no solo penalizar el gasto.

**Mitigación:** concepto de suficiencia (sección 5.1), techo en normalización de Burn Rate (no se premia estar por debajo de 0.70), techo en Runway (no se premia más de 6 meses de colchón), lenguaje positivo en recomendaciones, y ausencia deliberada de cualquier métrica que puntúe la "calidad" del gasto discrecional.

### 7.2 Comparación social tóxica (riesgo medio)

Whoop permite comparar HRV con amigos de forma relativamente inocua. La comparación financiera es psicológicamente peligrosa — desigualdad de ingresos, inflación de estilo de vida, y vergüenza financiera hacen que los rankings sean más dañinos que motivadores.

**Mitigación:** si se implementan features sociales, comparar solo contra el propio histórico del usuario, nunca contra otros usuarios.

### 7.3 Discontinuidades financieras (riesgo medio)

No te despiertas un día con tu HRV a cero porque tu empresa quebró. Pero sí puedes despertar con tu Runway a cero por un gasto inesperado de 10.000€. Las finanzas tienen step functions que la biología no tiene.

**Mitigación:** detección de anomalías que contextualiza eventos extraordinarios en lugar de dejar que distorsionen las métricas durante meses.

### 7.4 Commitment Ratio inerte (riesgo medio)

Sin la capa de detección proactiva, Commitment Ratio puede no moverse en 3-4 meses para usuarios asalariados estables. Un número estático en una de las cuatro métricas primarias erosiona la confianza en todo el sistema.

**Mitigación:** capa de detección proactiva como requisito de V1 (sección 4.2: suscripciones fantasma, alertas de renovación, resumen mensual).

---

## 8. Requisitos de infraestructura de datos (MVP)

### 8.1 APIs necesarias

| Capacidad | Función |
|-----------|---------|
| `get_transactions(account_id, date_range)` | Historial de transacciones para todas las métricas |
| `get_balance(account_id)` | Saldo actual para Runway y Burn Rate |
| `get_accounts(user_id)` | Lista de cuentas conectadas para detección de transferencias propias |
| `get_recurring_charges(account_id)` | Cargos recurrentes detectados para Commitment Ratio |
| `get_scheduled_payments(account_id)` | Pagos programados para amortización de Burn Rate |

### 8.2 Procesamiento derivado

| Proceso | Input | Output |
|---------|-------|--------|
| Detección de transferencias internas | Transacciones de todas las cuentas | Exclusión de movimientos entre cuentas propias |
| Clasificación ingreso/gasto/transferencia | Transacciones brutas | Transacciones limpias categorizadas |
| Detección de recurrencia | 12 meses de transacciones | Lista de obligaciones recurrentes con periodicidad |
| Amortización de lumpy expenses | Gastos recurrentes no mensuales | Distribución mensual de costes irregulares |
| Detección de perfil de ingreso | 3+ meses de ingresos | Perfil A (nómina estable) o Perfil B (irregular) |
| Cálculo de ingreso de referencia | Historial de ingresos | Nómina fija (Perfil A) o P25 de 6 meses (Perfil B) |

---

## Apéndice A: Ejemplo numérico

**Usuario ejemplo: nómina de 2.200€/mes, alquiler 700€, suscripciones 85€, seguros amortizados 120€/mes, gasto variable medio 800€/mes, ahorro acumulado 5.500€, sin deuda.**

| Métrica | Cálculo | Valor | Estado |
|---------|---------|-------|--------|
| Burn Rate (día 15 del mes) | 580€ gastados / (800€ × 15/30) | 1.45 | Crítico |
| Commitment Ratio | (700 + 85 + 120) / 2.200 | 41.1% | Saludable |
| Runway | 5.500 / 1.705 (media 90d) | 3.2 meses | Saludable |
| Momentum | posición neta actual vs media 3 meses | +4% | Saludable |
| Chronos Score | 30×0.30 + 78×0.25 + 73×0.25 + 82×0.20 | 55.1 | Atención |

**Lectura:** el usuario tiene buena estructura (Commitment Ratio saludable), buen colchón (Runway 3.2 meses), y tendencia positiva (Momentum +4%), pero este mes concreto está gastando demasiado rápido (Burn Rate 1.45). La recomendación se centra en Burn Rate: "Vas un 45% por encima de tu ritmo sostenible a mitad de mes. Aplaza compras no urgentes los próximos 15 días para cerrar el mes en equilibrio."

---

## Apéndice B: Glosario

| Término | Definición |
|---------|-----------|
| **Activos líquidos** | Saldo disponible en cuentas corrientes + ahorro accesible. No incluye inversiones a menos que el usuario las marque como liquidables. |
| **Gasto mensual suavizado** | Media de gasto total de los últimos 90 días, dividida entre 3. Elimina distorsión por meses atípicos. |
| **Lumpy expense** | Gasto predecible pero no mensual (anual, semestral, trimestral). Se amortiza en el presupuesto mensual. |
| **Obligación recurrente** | Cargo con periodicidad predecible que requiere acción explícita de cancelación para detenerse. |
| **Posición neta** | Ingresos acumulados menos gastos acumulados en un período dado. |
| **Modo suficiencia** | Estado del sistema cuando Chronos Score ≥ 80 durante 4+ semanas. Reduce presión de optimización. |
| **Runway flexible** | Estimación de cuánto dura el colchón si se eliminan todos los gastos no comprometidos (modulado por Commitment Ratio). |