import { UserFinancialContext } from "../../core/data-retrieval.service";
import { ResponseMode } from "../../llm/prompt-compiler";

export async function runBlockHubAgent(
  _ctx: UserFinancialContext,
  _userMessage: string,
  _responseMode: ResponseMode
): Promise<string> {
  return "BlockHub (crypto) intelligence is not yet available — our crypto module is currently being deployed. Once it's live, I'll be able to analyze your portfolio, track prices, detect concentration risk, and give you tailored insights. Stay tuned!";
}

export async function runCryptoPortfolioAnalysis(
  _ctx: UserFinancialContext,
  _responseMode: ResponseMode
): Promise<string> {
  return "Crypto portfolio analysis will be available once BlockHub is deployed. I'll connect to your wallet holdings and provide full risk scoring and trend detection.";
}
