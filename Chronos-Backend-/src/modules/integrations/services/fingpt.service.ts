import axios, { AxiosError } from "axios";
import { FINGPT_API_URL, FINGPT_API_KEY } from "../../config/fingpt.config";
import type { AdviceInput, AdviceDTO, TickPayAnalysisInput, TickPayAnalysisDTO } from "../dto/fingpt.dto";

function authHeaders() {
  const h: Record<string, string> = { "Content-Type": "application/json" };
  if (FINGPT_API_KEY) h.Authorization = `Bearer ${FINGPT_API_KEY}`;
  return h;
}

async function post(endpoint: string, payload: any) {
  try {
    const res = await axios.post(`${FINGPT_API_URL}/${endpoint}`, payload, { headers: authHeaders(), timeout: 20000 });
    return res.data;
  } catch (e) {
    const err = e as AxiosError;
    const msg = (err.response?.data as any)?.message || err.message;
    throw new Error(`FinGPT POST ${endpoint} failed: ${msg}`);
  }
}

class FinGPTService {
  async getFinancialAdvice(input: AdviceInput): Promise<AdviceDTO> {
    const data = await post("financial-advice", input);
    // You can normalize/validate shape here if your FinGPT returns free-form text.
    return data as AdviceDTO;
  }

  async analyzeTickPay(input: TickPayAnalysisInput): Promise<TickPayAnalysisDTO> {
    const data = await post("tickpay-analysis", input);
    return data as TickPayAnalysisDTO;
  }
}

export default new FinGPTService();
