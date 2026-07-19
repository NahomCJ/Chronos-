/**
 * Thin HTTP client to Panther AI's financial-advisor service
 * (panther/Panther-AI-/PantherAI: routers/financial_advisor/router.py).
 *
 * The backend does not re-implement expense categorization, gym/supplement
 * flagging, liability/DTI analysis, or tax estimation — it forwards the
 * caller's financial data to Panther and returns the report as-is. No
 * PANTHER_AI_URL client existed in this backend before; this is the first.
 */

const PANTHER_AI_URL = process.env.PANTHER_AI_URL || 'http://localhost:8000';

export class PantherFinancialAdvisorClient {
  private async post(path: string, body: unknown) {
    const response = await fetch(`${PANTHER_AI_URL}/api/financial-advisor${path}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const detail = await response.text().catch(() => response.statusText);
      throw new Error(`Panther financial-advisor request failed (${response.status}): ${detail}`);
    }

    return response.json();
  }

  analyzePerson(person: unknown) {
    return this.post('/analyze', person);
  }

  analyzeBatch(people: unknown[]) {
    return this.post('/analyze/batch', { people });
  }
}
