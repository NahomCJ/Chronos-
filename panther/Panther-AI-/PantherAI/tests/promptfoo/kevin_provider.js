/**
 * Custom promptfoo provider for Kevin Chat API.
 *
 * Sends properly typed JSON (arrays stay arrays, strings stay strings).
 * The built-in HTTP provider stringifies arrays via Nunjucks, which breaks
 * Pydantic validation on the FastAPI side.
 */

class KevinProvider {
  constructor(options) {
    this.config = options.config || {};
    this.baseUrl = this.config.baseUrl || "http://localhost:8000";
    this.timeoutMs = this.config.timeoutMs || 180000;
  }

  id() {
    return "kevin-chat";
  }

  async callApi(prompt, context) {
    const { user_id, message, conversation_history, history_user_id } = context.vars;

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);

    try {
      const res = await fetch(`${this.baseUrl}/api/kevin/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user_id,
          message,
          conversation_history: conversation_history || [],
          ...(history_user_id && { history_user_id }),
        }),
        signal: controller.signal,
      });

      const data = await res.json();

      if (!res.ok) {
        return { output: data, metadata: { status: res.status } };
      }

      return { output: data };
    } catch (err) {
      if (err.name === "AbortError") {
        return { error: `Request timed out after ${this.timeoutMs}ms` };
      }
      return { error: err.message };
    } finally {
      clearTimeout(timeout);
    }
  }
}

module.exports = KevinProvider;
