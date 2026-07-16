# Sprint Plan — Financial Health Metrics Framework

**Sprint:** 2 semanas (10 días laborables)
**Fecha inicio:** 14 abril 2026
**Fecha fin:** 25 abril 2026
**Equipo:** Martín (AI/backend)
**Objetivo:** MVP funcional de backend que calcula 4 métricas primarias + Chronos Score a partir de datos bancarios (mock) y los expone vía API REST lista para ser consumida por la mobile app más adelante.

---

## Estado del codebase (auditado antes de empezar)

**Ya existe y se reutiliza** (reduce esfuerzo en varias tareas — ver notas en cada tarea afectada):

| Asset | Path | Reutilizable en |
|-------|------|----------------|
| Mock Banking API (`get_balance`, `get_transactions`, `get_upcoming_bills`) + JSON con usuarios mock (`user_marcus`, `user_sarah`, `user_bob`) | `services/banking/mock_api.py`, `datasets/mock/mock_transactions.json` | Tarea 1.2 |
| Spending analytics engine (~700 líneas, cálculos mensuales, deltas, heurística básica de recurrencia "≤3 txns + ≥70% del mismo merchant") | `services/insights/spending_analytics.py` | Tareas 2.2, 2.3, 5.1 |
| Insights API endpoints (patrón FastAPI listo: `/api/insights/spending-summary`, `/top-categories`, `/warnings-history`) | `routers/insights/router.py` | Tarea 4.1 |
| Transactions API (CRUD + filtros + corrección de categoría) | `routers/transactions/router.py` | Toda la capa de ingesta |
| Tablas Supabase `accounts` + `transactions` + `plaid_tokens` ya creadas | Referenciadas en routers | Tarea 1.1 (solo añadir tablas nuevas) |
| Risk assessment (`assess_payment_risk`) y BNPL risk scoring | `services/risk_assessment/`, `services/bnpl_risk_scoring/` | Patrones reutilizables para lógica de métricas |
| Taxonomía 14 categorías + 44 subcategorías con colores WCAG AA | `services/TC-TransactionClassifier/classifier/taxonomy.py`, `services/insights/constants.py` | Tarea 7.1 (colores UI) |

**No existe y hay que construir desde cero:**
- Las 4 fórmulas de métricas + Chronos Score
- Detección de perfil de ingreso (Perfil A/B)
- Detección de transferencias internas entre cuentas propias
- Tablas Supabase: `users` (con `monthly_income`, `income_profile`), `recurring_charges`, `metrics_snapshot`

**Implicación para el plan:** ~4.5h de ahorro neto en backend (1.1, 1.2, 4.1, 5.1). Ese colchón se reasigna a endurecer el pipeline, rescatar stretch goals, y dejar contratos de API listos para la mobile app.


---

## Definición de "Done" del sprint

El sprint se considera exitoso cuando:

1. [ ] Existe un generador de datos mock que produce transacciones realistas para al menos 6 meses de historial
2. [ ] Las 4 métricas (Burn Rate, Commitment Ratio, Runway, Momentum) se calculan correctamente según las fórmulas del spec
3. [ ] El Chronos Score se calcula con los pesos definidos (30/25/25/20)
4. [ ] Cada métrica devuelve: valor raw, score normalizado (0-100), y estado (óptimo/saludable/atención/crítico)
5. [ ] Los tests unitarios de todas las fórmulas pasan (incluido el ejemplo numérico del Apéndice A)
6. [ ] La API expone un endpoint que dado un `user_id` devuelve el payload completo (4 métricas + Chronos Score + metadatos) con schema estable y documentado (OpenAPI)
7. [ ] El pipeline detecta perfil de ingreso (nómina estable vs irregular) — ver spec §3.2
8. [ ] Endpoints de detalle por métrica devuelven el desglose suficiente para alimentar vistas de detalle en la mobile app (sin UI en este sprint)

---

## Riesgos técnicos

| # | Riesgo | Impacto | Mitigación |
|---|--------|---------|------------|
| 1 | **Detección de recurrencia es compleja.** Matching fuzzy de merchants + periodicidad + variación de importe requiere iteraciones | Commitment Ratio depende de esto | Implementar detección simple primero (exact match + mismo importe ±15%), iterar si sobra tiempo |
| 2 | **Normalización tiene edge cases.** División por cero cuando no hay ingresos, día 1 del mes, historial < 90 días para suavizado | Scores incorrectos o crasheos | Definir fallbacks explícitos para cada edge case en día 3, testearlos con datos mock extremos |
| 3 | **Datos mock insuficientemente realistas.** Si el generador no produce patrones reales (nómina regular, subs mensuales, lumpy expenses), los tests no validan nada útil | Falsa confianza en que el pipeline funciona | Diseñar el generador con perfiles de usuario reales (Apéndice A del spec como perfil base) |
| 4 | **Modelo de datos Supabase mal alineado con las queries del pipeline.** Si el esquema no encaja, habrá reescrituras downstream | Pérdida de 1-2 días | Martín alinea esquema DB el día 1 antes de escribir código |
| 5 | **Amortización de lumpy expenses añade complejidad a Burn Rate.** No es solo "gasto acumulado / presupuesto" — hay que distribuir gastos anuales mensualmente | Burn Rate da valores incorrectos sin esto | Marcar amortización como stretch de semana 2 — el MVP funciona sin ella usando solo gasto raw |

---

## SEMANA 1 — Infraestructura + Pipeline de cálculo

### Día 1 (Lun 14 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 1.1 | **Extender modelo de datos en Supabase.** `accounts` y `transactions` ya existen. Añadir tablas nuevas: `users` (con `monthly_income`, `income_profile`, `currency`, `onboarded_at`), `recurring_charges` (account_id, merchant, amount, frequency, next_expected_date), `metrics_snapshot` (account_id, timestamp, valores y estados de las 4 métricas + Chronos Score). Migration file + RLS policies. **Reutiliza:** esquema actual de `accounts`/`transactions`. | Martín | 2h | — | §8.1 (APIs necesarias), §8.2 (procesamiento derivado) |
| 1.2 | **Extender generador de datos mock.** `services/banking/mock_api.py` ya tiene base con 3 usuarios. Extender para producir 6 meses de historial con: nómina mensual regular (Perfil A), variante con ingresos irregulares (Perfil B), suscripciones (Netflix, Spotify, gym), alquiler, gastos variables (supermercado, restaurantes, transporte), y al menos 1 lumpy expense anual. Output: inserción en Supabase o JSON. Usar Apéndice A como perfil base. **Reutiliza:** estructura de `mock_transactions.json`. | Martín | 2.5h | 1.1 (esquema) | §3.2 (perfiles), Apéndice A |
| 1.3 | **Scaffold del módulo `services/healthmetrics/`.** Estructura de carpetas (`formulas/`, `pipeline/`, `detection/`, `schemas/`), `__init__.py`, conexión al Supabase client existente, env vars. | Martín | 1h | — | — |
| 1.4 | **Definir Pydantic schemas (contratos de API).** Modelos para `MetricResult` (value, score, status, unit, breakdown), `ChronosScoreResponse`, `MetricsDashboardResponse`, `UserProfilePayload`. Estos schemas son el contrato público que consumirá la mobile app. Incluir ejemplos para OpenAPI. | Martín | 2h | 1.1 | §6 (tabla resumen) |

### Día 2 (Mar 15 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 2.1 | **Implementar detección de perfil de ingreso.** Función que analiza transacciones de ingresos de los últimos 3-6 meses y clasifica como Perfil A (nómina estable: mismo pagador, ±5% importe, ±3 días fecha, 3+ meses consecutivos) o Perfil B (irregular: P25 de últimos 6 meses). Retorna `{ profile: 'A' | 'B', monthly_income: number }`. | Martín | 3h | 1.2 (datos mock) | §3.2 (perfiles de usuario) |
| 2.2 | **Implementar cálculo de Burn Rate.** `burn_rate = gasto_acumulado_mes / (presupuesto_mensual × día_actual / días_del_mes)`. Incluir normalización a score 0-100 según los 4 tramos lineales. Incluir clasificación de estado (óptimo/saludable/atención/crítico). Sin amortización de lumpy expenses por ahora — se añade en semana 2. | Martín | 3h | 1.2, 2.1 (para presupuesto_mensual) | §4.1 (Burn Rate, fórmula + normalización + umbrales) |
| 2.3 | **Implementar cálculo de Commitment Ratio.** `commitment_ratio = suma(obligaciones_recurrentes) / ingreso_mensual`. Paso 1: usar lista estática de recurring charges del mock data (la detección automática viene en día 5). Normalización + estado. | Martín | 2h | 1.2, 2.1 | §4.2 (Commitment Ratio, fórmula + normalización + umbrales) |
| 2.4 | **Tests unitarios: Burn Rate.** Testear con el ejemplo del Apéndice A (día 15, 580€ gastados, presupuesto 800€ → BR = 1.45 → score ~30 → estado Crítico). Testear edge cases: día 1 del mes, sin transacciones, presupuesto 0. | Martín | 1h | 2.2 | Apéndice A |
| 2.5 | **Hardening de `services/banking/seed_healthmetrics.py` (deuda del día 1).** Ver detalle abajo en "Deuda técnica — TASK 1.2 review". | Martín | 1.5h | 1.2 | code-review feedback |

#### Deuda técnica — TASK 1.2 review (entra como TASK 2.5)

Hallazgos del `code-review` del día 1 que deben resolverse antes de que el pipeline de métricas (2.1-3.5) consuma el generador en serio:

**Critical — bloqueantes para re-usar Phase 2**
1. **Idempotencia del insert en Supabase** (`seed_healthmetrics.py:_insert_transactions_supabase`). Re-correr `--output supabase` duplica las ~400 filas porque el `id` es `uuid.uuid4()` nuevo cada vez. Fix: derivar `id` determinísticamente (`hash(user_id|profile|seed|idx)` vía `uuid.UUID(int=...)`) y usar `upsert(on_conflict="id")`, o borrar las filas del rango de fechas antes de insertar.
2. **Determinismo real con `seed=42`** (`seed_healthmetrics.py:_txn`, `seed_six_months`). `uuid.uuid4()` no está sembrado y `today = today or date.today()` acopla la salida al wall clock. Fix: generar UUIDs desde el `rng` sembrado y requerir `today` explícito en CLI (o loguearlo).

**Important — fiabilidad en el borde Supabase**
3. **TOCTOU en `_ensure_user_and_account`**. Select-then-insert hace race y deja huérfanos si falla el segundo paso. Fix: `upsert(..., on_conflict="id")` para `users` + try/except que reporte qué paso falló.
4. **Sin error handling en `.execute()`**. `supabase-py` no levanta excepción por defecto; hay que inspeccionar `response.data` / `response.error` y surfaceear el índice del chunk que falló en `_insert_transactions_supabase`.
5. **Verificar que `sub_side_hustle` existe en `taxonomy.py`**. Si no, las filas de Perfil B se caerán en silencio en joins downstream.
6. **Test 2 (`test_profile_b_produces_irregular_income`) es frágil**. El `stdev/mean > 0.2` depende del seed; si se resembla puede flakear. Fix: asertar sobre diversidad de pagadores + rango (`max/min > 3`) en vez de una estadística de distribución.

**Nits (fine to leave, apply si toca el archivo)**
7. `duration_ms=0.0` hardcodeado en `log.result` — medir con `time.perf_counter()` o quitar el campo (engañoso para observability).
8. `import calendar as _cal` dentro de `_clamp_day` → mover al top del módulo.
9. Comentario en `seed_healthmetrics.py:108` ("mean = 14 €/tx → ~840 €/mes") queda desactualizado una vez que el clip `max(2, min(amount, 120))` se aplica — actualizar o añadir un assert en `test_apendice_a_totals_for_marcus`.
10. `test_seed_six_months_writes_json` no verifica `sum(sub_counts.values()) == report.transactions_inserted`. Añadir una línea.

**Done when (2.5):**
- [ ] Re-correr `python -m services.banking.seed_healthmetrics --user user_marcus --profile A --output supabase` dos veces → el count total en Supabase no cambia tras la segunda corrida.
- [ ] `generate_transactions("user_marcus", "A", today=date(2026,4,15), seed=42)` produce los mismos `id`s byte-a-byte en dos procesos distintos.
- [ ] Los 6 tests existentes siguen verdes + test nuevo para idempotencia del upsert.
- [ ] Issues 3-5 atendidos o explícitamente marcados como "no aplicable" con razón.

### Día 3 (Mié 16 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 3.1 | **Implementar cálculo de Runway.** `runway = activos_líquidos / gasto_mensual_suavizado_90d`. Usar media suavizada de 90 días. Normalización + estado. | Martín | 2h | 1.2 | §4.3 (Runway, fórmula + normalización + umbrales) |
| 3.2 | **Implementar cálculo de Momentum.** `momentum = posición_neta_actual - media(posición_neta_últimos_3_meses)`. Convertir a porcentaje vs baseline para normalización. Score + estado. | Martín | 2h | 1.2 | §4.4 (Momentum, fórmula + normalización + umbrales) |
| 3.3 | **Tests unitarios: Commitment Ratio, Runway, Momentum.** Validar con ejemplo del Apéndice A. CR: (700+85+120)/2200 = 41.1% → score 78 → Saludable. Runway: 5500/1705 = 3.2 meses → score 73 → Saludable. Momentum: +4% → score 82 → Saludable. | Martín | 2h | 2.3, 3.1, 3.2 | Apéndice A |
| 3.4 | **Implementar Chronos Score.** Combinar los 4 scores con pesos (0.30, 0.25, 0.25, 0.20). Normalización + estado. Validar: 30×0.30 + 78×0.25 + 73×0.25 + 82×0.20 = 55.15 → Atención. | Martín | 1.5h | 2.2, 2.3, 3.1, 3.2 | §5 (Chronos Score, fórmula + pesos + umbrales) |
| 3.5 | **Tests unitarios: Chronos Score + test de integración completo.** Alimentar el pipeline con datos del Apéndice A de inicio a fin, verificar que cada métrica produce el resultado esperado. | Martín | 1.5h | 3.4 | Apéndice A, §5 |

### Día 4 (Jue 17 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 4.1 | **API endpoint: GET `/api/metrics/{user_id}`.** Endpoint que ejecuta el pipeline completo y devuelve las 4 métricas + Chronos Score en JSON. Crear `routers/metrics/router.py` siguiendo el patrón de `routers/insights/router.py` (que ya tiene paginación, anclaje de fechas para mock, y manejo de errores). **Reutiliza:** Supabase client init y patrón FastAPI de insights. | Martín | 2h | 3.4 (pipeline completo) | §8.1 |
| 4.2 | **Edge case handling en todas las métricas.** Definir y implementar comportamiento cuando: historial < 90 días (Runway usa lo que hay), historial < 3 meses (Momentum usa lo que hay, banner de calibración), sin ingresos detectados (no se puede calcular CR ni BR — mostrar estado "insuficiente"), día 1 del mes (BR usa gasto de ayer o muestra "calculando"). Documentar cada decisión. | Martín | 3h | 3.4 | §3.2 (onboarding con historial insuficiente) |
| 4.3 | **Supabase function o RPC para calcular métricas.** Evaluar si el cálculo vive en el frontend (Supabase client queries + cálculo en JS) o en una Supabase Edge Function. Decisión pragmática: lo que sea más rápido para el MVP. Implementar según decisión. | Martín | 2h | 4.1 | — |

### Día 5 (Vie 18 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 5.1 | **Detección de recurrencia (extender heurística existente).** `services/insights/spending_analytics.py` ya tiene una heurística básica ("≤3 txns + ≥70% del mismo merchant"). Extenderla a un detector serio: agrupar por merchant (normalizado: sin números/puntuación), verificar periodicidad (mensual: ±3 días, trimestral/anual: ±7 días), importe ±15%. Output: `{ merchant, amount, frequency, next_expected_date }`. Persistir en tabla `recurring_charges` (creada en 1.1). | Martín | 3h | 1.2 | §4.2 (definición de obligación recurrente), §8.2 (detección de recurrencia) |
| 5.2 | **Integrar detección de recurrencia con Commitment Ratio.** Reemplazar la lista estática de recurring charges con la detección automática de 5.1. Re-correr tests para verificar que los resultados se mantienen. | Martín | 2h | 5.1 | §4.2 |
| 5.3 | **Detección de transferencias entre cuentas propias.** Matching: cargo en cuenta A de X€ en fecha T ↔ abono en cuenta B de X€ (±1€) en fecha T (±2 días), mismo usuario. Marcar como `internal_transfer` y excluir de ingresos y gastos. | Martín | 2h | 1.2 | §3.3 (transferencias entre cuentas propias) |
| 5.4 | **Buffer / bug fixing / catch-up.** Tiempo reservado para tareas que se desbordaron de días anteriores. Si no hay atrasos: escribir tests adicionales para edge cases de detección de recurrencia. | Martín | 2h | — | — |
| 5.5 | **OpenAPI contract freeze (v1).** Congelar el schema de `/api/metrics/{user_id}` y endpoints relacionados. Exportar `openapi.json` a `docs/banking/healthmetrics_api/openapi.json` y añadir ejemplos de response por perfil. Este artefacto es lo que la mobile app va a consumir — cualquier cambio posterior es breaking. | Martín | 2h | 1.4, 4.1 | §6 |

---

## SEMANA 2 — Endpoints de detalle + Detección avanzada + Hardening

### Día 6 (Lun 21 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 6.1 | **Endpoint `GET /api/metrics/{user_id}/burn-rate`.** Response con: valor raw, score, estado, presupuesto del mes, gasto acumulado, día del mes, serie diaria (gasto acumulado vs línea de presupuesto lineal) e insight derivado (`projected_savings_rate_pct`). Schema versionado en el módulo `schemas/`. | Martín | 3h | 2.2, 4.1 | §4.1 (insight derivado de Savings Rate proyectado) |
| 6.2 | **Endpoint `GET /api/metrics/{user_id}/commitment-ratio`.** Response con: valor raw, score, estado, ingreso mensual detectado, lista de obligaciones recurrentes (`merchant`, `amount`, `frequency`, `next_expected_date`), total comprometido. | Martín | 2h | 2.3, 5.1 | §4.2 (superficie de recomendación) |
| 6.3 | **Endpoint `GET /api/metrics/{user_id}/runway`.** Response con: meses de runway bruto, saldo líquido, gasto mensual suavizado 90d, `runway_neto` (si hay deuda) y `runway_flexible` como campo secundario. Incluir `context_notes` tipadas para que la app pueda surfaceear warnings ("deuda > liquidez"). | Martín | 3h | 3.1 | §4.3 (modificadores contextuales: erosión por deuda + flexibilidad) |

### Día 7 (Mar 22 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 7.1 | **Endpoint `GET /api/metrics/{user_id}/momentum`.** Response con: valor porcentual, score, estado, posición neta actual, media 3 meses, serie semanal de posición neta (últimas 4-8 semanas) para que la app pinte el mini-trend. | Martín | 2h | 3.2 | §4.4 |
| 7.2 | **Persistencia de `metrics_snapshot`.** Al llamar a `/api/metrics/{user_id}`, escribir un snapshot en la tabla `metrics_snapshot` (creada en 1.1) con timestamp + los 5 valores/estados. Idempotente: un snapshot por `(user_id, day)`, upsert. Esto habilita series históricas para el modo suficiencia. | Martín | 2h | 1.1, 4.1 | §8.2 (procesamiento derivado) |
| 7.3 | **Test de contrato API (pytest + httpx).** Hit a los 5 endpoints con los 3 perfiles mock (Apéndice A Perfil A, Perfil B freelancer, Perfil A con deuda). Snapshot-test del JSON response contra fixtures commiteadas. Verificar que el schema cumple los Pydantic models. | Martín | 2h | 4.1, 6.1, 6.2, 6.3, 7.1 | Apéndice A |
| 7.4 | **Test E2E: flujo completo mock → pipeline → API.** Alimentar el generador, correr el pipeline, pegar a la API, comparar contra cálculo manual del Apéndice A. Cubre la línea completa end-to-end. | Martín | 2h | 4.1 | Apéndice A |

### Día 8 (Mié 23 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 8.1 | **Modo suficiencia (lógica + persistencia).** Tracker que, al escribir cada snapshot en `metrics_snapshot`, evalúa si Chronos Score ≥ 80 durante 4 semanas consecutivas. Si se activa, setea un flag `sufficiency_mode` en el row de `users` y expone `sufficiency_mode: bool` + `sufficiency_since: date` en el payload principal. Si una métrica individual entra en Atención/Crítico, la respuesta añade `sufficiency_paused_for: [metric]`. | Martín | 3h | 3.4, 7.2 | §5.1 (modo suficiencia) |
| 8.2 | **Tests unitarios de modo suficiencia.** Simular series de snapshots (4 semanas sanas → activa; una métrica baja en semana 3 → no activa; activa y métrica entra en Atención → paused_for). Cubrir edge cases en el tracker. | Martín | 1.5h | 8.1 | §5.1 |
| 8.3 | **Endurecer `/api/metrics/{user_id}` (caching + error shapes).** Añadir cache en memoria por `(user_id, hoy)` con TTL, respuestas de error estructuradas (`{code, message, details}`) y códigos HTTP consistentes para los estados "insuficiente" del 4.2. | Martín | 2h | 4.1, 4.2 | §3.2 |
| 8.4 | **Rate limiting + auth stub en el router de metrics.** Decorator de rate limit (token bucket básico por `user_id`) y dependencia `get_current_user` stub lista para plug-in del JWT real cuando llegue la mobile app. | Martín | 1.5h | 4.1 | — |

### Día 9 (Jue 24 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 9.1 | **[STRETCH] Amortización de lumpy expenses en Burn Rate.** Escanear 12 meses de historial buscando cargos: mismo merchant (exact match), importe ±15%, periodicidad anual/semestral/trimestral. Redistribuir como gasto fijo mensual. Recalcular Burn Rate excluyendo el pico del mes de cargo. | Martín | 4h | 5.1 (detección de recurrencia) | §4.1 (amortización de gastos irregulares) |
| 9.2 | **[STRETCH] Detección proactiva de Commitment Ratio — suscripciones fantasma.** Identificar cargos recurrentes mensuales donde la única interacción con ese merchant es el cargo fijo (sin otras transacciones del mismo merchant en 2+ meses). Generar alerta: "Llevas 3 meses sin usar [merchant] — ¿quieres revisar esta suscripción?" | Martín | 3h | 5.1 | §4.2 (capa de detección proactiva, punto a) |
| 9.3 | **[STRETCH] Alertas de renovación anual.** Detectar cargos anuales/semestrales con fecha próxima (en los próximos 14 días). Mostrar alerta en dashboard con importe y opción de "mantener" o "revisar". | Martín | 2h | 9.1 (detección de lumpy expenses) | §4.2 (capa de detección proactiva, punto b) |

### Día 10 (Vie 25 abril)

| # | Tarea | Asignado | Horas | Dependencia | Ref spec |
|---|-------|----------|-------|-------------|----------|
| 10.1 | **Integration testing final.** Correr el pipeline completo con 3 perfiles mock distintos (Perfil A estándar tipo Apéndice A, Perfil B freelancer con ingresos irregulares, Perfil A con deuda activa). Verificar que todas las métricas producen resultados sensatos para cada perfil. | Martín | 2h | Todo | Apéndice A, §3.2 |
| 10.2 | **Observability del pipeline.** Instrumentar con `@contract` + logs JSON (ver `core/logger.py`) los entry points del pipeline y cada endpoint de métricas. Incluir `duration_ms`, `user_id`, `profile`, métricas calculadas. Dejar trazas listas para debug desde la mobile app. | Martín | 2h | Todo backend | CLAUDE.md (observability skill) |
| 10.3 | **Documentación del pipeline + API.** README en `services/healthmetrics/` que explica: qué calcula cada función, input/output esperado, cómo se conectan. Sumar `docs/banking/healthmetrics_api/README.md` con ejemplos de `curl` por endpoint y el link al `openapi.json` (de la tarea 5.5). Es lo mínimo para que el dev de la mobile app pueda consumir sin preguntar. | Martín | 2h | Todo, 5.5 | — |
| 10.4 | **Demo prep.** Preparar 2-3 escenarios mock que muestren: usuario saludable, usuario en estado crítico, y transición atención→saludable. Script curl/httpie que hits a la API y printea los responses en orden para una demo live sin UI. | Martín | 1.5h | Todo | — |
| 10.5 | **Buffer de cierre.** Tiempo para bugs finales, ajustes de último minuto, o tareas stretch que no se completaron. | Martín | 2h | — | — |

---

## Resumen de carga

| Semana | Horas estimadas | Foco |
|--------|----------------|------|
| Semana 1 | ~20h | Esquema DB (extender), scaffold módulo, Pydantic contracts, perfil ingreso, las 4 fórmulas, Chronos Score, API base, edge cases, detección de recurrencia, OpenAPI freeze |
| Semana 2 | ~20h | Endpoints de detalle (BR/CR/Runway/Momentum), persistencia de snapshots, tests de contrato + E2E, modo suficiencia, caching/error shapes, rate limit + auth stub, stretch, integration testing, observability, docs |
## Tareas marcadas como STRETCH (sacrificables)

Si el sprint se complica, estas tareas se postponen sin comprometer el MVP:

1. **9.1** — Amortización de lumpy expenses en Burn Rate (§4.1). El MVP funciona con gasto raw.
2. **9.2** — Detección de suscripciones fantasma (§4.2a). Commitment Ratio funciona sin esta capa proactiva.
3. **9.3** — Alertas de renovación anual (§4.2b). Es una feature de engagement, no de cálculo.
4. **8.1 / 8.2** — Modo suficiencia (§5.1). Requiere 4 semanas de datos para activarse — no es demostrable en el sprint de todas formas. Si se sacrifica, el payload devuelve `sufficiency_mode: null`.
5. Modificadores contextuales de Runway (erosión por deuda, runway_flexible) en 6.3 — el runway bruto es suficiente para MVP.
6. **8.4** — Rate limit + auth stub. El endpoint funciona sin esto; se puede añadir cuando llegue la integración de la mobile app.

---

## Dependencias críticas (diagrama simplificado)

```
Día 1: [1.1 Esquema DB] ──→ [1.2 Mock Data] ──→ Día 2+: todo el pipeline
       [1.3 Scaffold módulo] + [1.4 Pydantic schemas] ──→ contratos de API

Día 2-3: [Métricas individuales] ──→ [3.4 Chronos Score] ──→ [4.1 API endpoint base]

Día 5: [5.1 Detección recurrencia] ──→ [5.2 CR real]
       [5.5 OpenAPI freeze] ──→ contrato congelado para mobile app

Día 6-7: [Endpoints de detalle BR/CR/Runway/Momentum] + [7.2 snapshots]
         ──→ [7.3 contract tests] + [7.4 E2E] ──→ Día 8+: suficiencia + hardening
```

**Bottleneck principal:** tarea 1.1 (esquema DB) y 1.2 (mock data) son prerequisito de casi todo. Deben completarse el día 1 sin falta.
