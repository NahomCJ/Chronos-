# Roadmap: Shopping Assistant

**Status:** NOT STARTED
**Sprint:** 2 (Semanas 3-4)
**Owner:** TBD
**Depends on:** Financial Health Metrics (Sprint 1). El recommender necesita el score y las métricas para filtrar.
**Blocks:** Nada directamente. Futuro: checkout execution (Phase 2+).

---

## Objetivo

El usuario dice que quiere un producto. CHRONOS busca opciones en la web via Firecrawl, las cruza con los datos financieros del usuario, y sugiere las 3 mejores opciones. Sin ejecución de compra. Solo consejo.

**Regla inamovible (CLAUDE.md):** Phase 1 = advice only. No auto-investing, no trade execution, no checkout.

---

## Flujo completo

```
Usuario (via Kevin): "Quiero unos audífonos bluetooth"
    |
    v
Kevin detecta intención de compra
    |
    v
Firecrawl busca "audifonos bluetooth" en la web
    |
    v
Motor de recomendación recibe:
  - Lista de productos (nombre, precio, URL, merchant)
  - Financial Health del usuario (score, savings capacity, debt load)
    |
    v
Filtra, rankea, selecciona top 3
    |
    v
Kevin presenta opciones con contexto financiero:
  "Opción 1: Sony WH-1000XM5 - $279 - Está dentro de tu capacidad mensual.
   Opción 2: Anker Soundcore Q45 - $89 - Te deja $X de margen este mes.
   Opción 3: JBL Tune 770NC - $149 - Buena relación calidad-precio para tu perfil."
```

---

## Tareas

### FASE 1 — Investigación Firecrawl [Semana 3, día 1-2]

**1.1 Spike técnico**
- [ ] Documentar Firecrawl API: endpoints disponibles (search vs scrape vs crawl)
- [ ] Rate limits, pricing, latencia promedio
- [ ] Formato de respuesta: qué campos devuelve por resultado
- [ ] Evaluar: ¿Firecrawl search es suficiente o necesitamos scrape + parsing custom?
- [ ] Definir fallback si Firecrawl está caído o lento (> 5s)
- [ ] Agregar `FIRECRAWL_API_KEY` a `.env.example`

**Done when:** Hay un documento corto (< 1 página) con la decisión técnica y un curl de ejemplo funcionando.

---

### FASE 2 — Cliente Firecrawl [Semana 3, día 2-3]

**2.1 Wrapper**
- [ ] Crear `services/shopping/firecrawl_client.py`
- [ ] Clase `FirecrawlClient` con:
  - `search_products(query: str, max_results: int = 10) -> list[RawProduct]`
  - Retry con backoff exponencial (max 3 intentos)
  - Timeout configurable via env var (`FIRECRAWL_TIMEOUT_S`, default 10)
  - Logging estructurado (query, latencia, num resultados)
- [ ] Modelo `RawProduct`: nombre, precio (float), url, merchant, descripción corta, imagen_url (opcional)

**2.2 Parsing de precios**
- [ ] Extraer precio de texto: "$279.99", "USD 279", "279 dollars" -> `float`
- [ ] Si no hay precio parseable -> `price = None`, excluir del ranking
- [ ] Tests de parsing: al menos 8 formatos distintos

**2.3 Tests**
- [ ] Mock de Firecrawl API para tests (no llamadas reales en CI)
- [ ] Test happy path: query -> lista de RawProduct
- [ ] Test: Firecrawl devuelve 0 resultados -> lista vacía, no error
- [ ] Test: Firecrawl timeout -> excepción controlada con mensaje claro
- [ ] Test: resultado sin precio -> se excluye

**Done when:** `FirecrawlClient().search_products("wireless headphones")` devuelve lista tipada con tests pasando.

---

### FASE 3 — Motor de recomendación [Semana 3, día 3-4 / Semana 4, día 1]

**3.1 Lógica de filtrado y ranking**
- [ ] Crear `services/shopping/recommender.py`
- [ ] Función `recommend_products(products: list[RawProduct], health: FinancialHealthResponse, max_results: int = 3) -> list[Recommendation]`
- [ ] Reglas de filtrado:
  - **Hard filter:** Descartar si `precio > Monthly Savings Capacity * 2`
  - **Soft filter:** Si `Debt Load Ratio > 0.4`, penalizar productos caros en ranking
  - **Warning trigger:** Si `Health Score < 40`, incluir warning en cada recomendación
- [ ] Ranking:
  - Score por producto = relevancia (posición en Firecrawl) * affordability_factor
  - `affordability_factor` = 1.0 si precio < 30% savings capacity, decrece linealmente hasta 0.2
- [ ] Output: `Recommendation` con campos: product (RawProduct), financial_fit (str), warning (str | None), affordability_score (float)

**3.2 Justificación financiera**
- [ ] Cada recomendación incluye un `financial_fit` en lenguaje natural:
  - "Dentro de tu capacidad mensual sin problema"
  - "Posible, pero te deja con poco margen este mes"
  - "Alto para tu situación actual. Considera ahorrar X meses"
- [ ] La justificación se genera con templates, no con LLM (rápido y determinístico)

**3.3 Tests**
- [ ] Test: usuario HEALTHY, 10 productos -> top 3 variados
- [ ] Test: usuario AT_RISK, todos los productos caros -> lista vacía + warning general
- [ ] Test: usuario CAUTION, mix de precios -> prioriza baratos
- [ ] Test: menos de 3 productos pasan filtro -> devuelve los que haya (1 o 2)
- [ ] Test: 0 productos -> response vacío con mensaje explicativo
- [ ] Test: health score < 40 -> todas las recomendaciones llevan warning

**Done when:** `recommend_products(products, health)` devuelve top 3 con justificación financiera, tests pasando.

---

### FASE 4 — API endpoint [Semana 4, día 1-2]

**4.1 Router**
- [ ] Crear `routers/shopping/router.py`
- [ ] `POST /api/shopping/search`
  - Body: `{"user_id": "user_marcus", "product_query": "wireless headphones"}`
  - Response:
    ```json
    {
      "recommendations": [
        {
          "product": {"name": "...", "price": 279.99, "url": "...", "merchant": "..."},
          "financial_fit": "Dentro de tu capacidad mensual",
          "affordability_score": 0.85,
          "warning": null
        }
      ],
      "health_snapshot": {
        "score": 72,
        "level": "HEALTHY",
        "monthly_savings_capacity": 450.00
      },
      "query": "wireless headphones",
      "total_found": 10,
      "filtered_out": 7
    }
    ```
- [ ] Registrar router en `main.py`

**4.2 Tests de integración**
- [ ] Test happy path con Firecrawl mockeado
- [ ] Test user inexistente -> error claro
- [ ] Test query vacía -> 422
- [ ] Test Firecrawl caído -> response con error message, no 500

**Done when:** `POST /api/shopping/search` devuelve recomendaciones con contexto financiero.

---

### FASE 5 — Integración con Kevin [Semana 4, día 2-3]

**5.1 Nueva tool**
- [ ] Agregar `search_product` en `services/conversational_ai/tools.py`
- [ ] Parámetros: `user_id` (str), `product_query` (str)
- [ ] Devuelve: top 3 recomendaciones con financial_fit

**5.2 Detección de intención**
- [ ] Kevin detecta intención de compra: "quiero comprar X", "busco un X", "recomiendame un X", "necesito un X"
- [ ] Si detecta intención -> invoca `search_product` automáticamente
- [ ] Kevin presenta resultados en formato conversacional, no JSON
- [ ] Kevin incluye warnings financieros si aplican
- [ ] Kevin NO ofrece ejecutar compra. Si el usuario pide "cómpralo", responde que aún no está disponible.

**5.3 Tests**
- [ ] Test: "quiero unos audifonos" -> Kevin invoca search_product
- [ ] Test: Kevin presenta 3 opciones con precios y justificación
- [ ] Test: usuario AT_RISK -> Kevin incluye advertencia financiera
- [ ] Test: "compra el primero" -> Kevin rechaza educadamente
- [ ] Test: cross-user security (usuario A no recibe recomendaciones basadas en datos de usuario B)

**Done when:** Flujo conversacional completo funciona end-to-end con Kevin.

---

### FASE 6 — Documentación [Semana 4, día 4]

- [ ] Crear `docs/PantherAI/ShoppingAssistant/ARCHITECTURE.md`
  - Flujo completo con diagrama
  - Decisiones: por qué Firecrawl, por qué templates vs LLM para justificación
  - Reglas de filtrado y ranking documentadas
  - Limitaciones: no ejecuta compra, depende de Firecrawl uptime
- [ ] Actualizar `CLAUDE.md` project map
- [ ] Actualizar tools de Kevin en docs

**Done when:** Un dev nuevo entiende el flujo leyendo solo ARCHITECTURE.md.

---

## Riesgos específicos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Firecrawl no devuelve precios parseables | Alta | Medio | Parser robusto + fallback: excluir productos sin precio |
| Firecrawl latencia > 5s | Media | Alto | Timeout + response parcial: "Encontré X resultados pero la búsqueda fue lenta" |
| Firecrawl API key costosa para dev | Baja | Medio | Mock completo para dev local; Firecrawl solo en staging/prod |
| Recomendaciones financieras malas (umbral muy laxo) | Media | Alto | Empezar conservador (Monthly Savings * 2). Iterar con feedback real |
| Usuarios piden comprar y no pueden | Alta | Bajo | Kevin responde claro: "Todavía no puedo comprar por ti, pero te ayudo a elegir" |

---

## Decisiones de diseño pendientes

1. **Firecrawl search vs scrape.** Search es más rápido pero menos control. Spike en Fase 1 lo resuelve.
2. **Límite de precio por defecto.** ¿Monthly Savings * 2 es el corte correcto? Podría ser * 1.5 para ser más conservador. Decidir con datos de los perfiles demo.
3. **Caché de búsquedas.** ¿Cachear resultados de Firecrawl por query + hora? Útil si múltiples usuarios buscan lo mismo. [PLANNED] para post-MVP.
4. **Imagen de producto.** Firecrawl puede devolver imagen. ¿La incluimos en el response? Depende del frontend. Por ahora: campo opcional, no bloquea.
