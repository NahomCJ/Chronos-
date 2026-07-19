export interface AgentResult {
  domain: string;
  content: string;
}

export function compileMultiDomainResponse(
  results: AgentResult[],
  responseMode: "text" | "voice"
): string {
  if (results.length === 1) return results[0].content;

  if (responseMode === "voice") {
    const parts = results.map((r) => r.content).join(" ");
    const words = parts.split(/\s+/).slice(0, 60);
    return words.join(" ");
  }

  const sections = results.map((r) => {
    const label = r.domain.charAt(0) + r.domain.slice(1).toLowerCase();
    return `**${label}:** ${r.content}`;
  });

  return sections.join("\n\n");
}
