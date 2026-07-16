import { NextFunction, Request, Response } from 'express';
import { FinancialService } from './financial.service';

const service = new FinancialService();

export class FinancialController {
  recalculateFinancials(arg0: string, requireAuth: (req: Request, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined, requireAdmin: (req: Request, res: Response, next: NextFunction) => Response<any, Record<string, any>> | undefined, recalculateFinancials: any) {
      throw new Error("Method not implemented.");
  }

  /* ---------- DASHBOARD ---------- */
  overview = async (req: any, res: Response) => {
    const data = await service.overview(req.user.id);
    res.json(data);
  };

  /* ---------- SAVINGS ---------- */
  createSavings = async (req: any, res: Response) => {
    const result = await service.createSavings(req.user.id, req.body);
    res.json(result);
  };

  listSavings = async (req: any, res: Response) => {
    const result = await service.listSavings(req.user.id);
    res.json(result);
  };

  /* ---------- BUDGET ---------- */
  createBudget = async (req: any, res: Response) => {
    const result = await service.createBudget(req.user.id, req.body);
    res.json(result);
  };

  listBudgets = async (req: any, res: Response) => {
    const result = await service.listBudgets(req.user.id);
    res.json(result);
  };

  /* ---------- LOANS ---------- */
  listLoans = async (req: any, res: Response) => {
    const result = await service.listLoans(req.user.id);
    res.json(result);
  };

  payLoan = async (req: any, res: Response) => {
    const { id } = req.params;
    const { amount } = req.body;

    const result = await service.payLoan(req.user.id, id, amount);
    res.json(result);
  };
  createLoan = async (req: any, res: Response) => {
  res.json(
    await service.createLoan(req.user.id, req.body)
  );
};


  /* ---------- INVESTMENT ---------- */
  investmentAdvice = async (req: any, res: Response) => {
    const result = await service.investmentAdvice(req.user.id);
    res.json(result);
  };

  /* ---------- CREDIT SCORE ---------- */
  creditScore = async (req: any, res: Response) => {
    const result = await service.creditScore(req.user.id);
    res.json(result);
  };

  /* ---------- ANALYTICS ---------- */
  monthlyBudget = async (req: any, res: Response) => {
    const { period } = req.query; // YYYY-MM
    const result = await service.monthlyBudget(req.user.id, period);
    res.json(result);
  };

  plannedVsActual = async (req: any, res: Response) => {
    const { period } = req.query;
    const result = await service.plannedVsActualChart(req.user.id, period);
    res.json(result);
  };

  /* ---------- TAX REPORT ---------- */
  taxReport = async (req: any, res: Response) => {
    const format = (req.query.format || 'csv') as 'csv' | 'pdf';

    const result = await service.taxReport(req.user.id, format);

    if (result.type === 'csv') {
      res.header('Content-Type', 'text/csv');
      res.attachment('tax-report.csv');
      return res.send(result.data);
    }

    if (!result.path) {
      return res.status(500).json({ error: 'File path not available' });
    }

    return res.download(result.path);
  };

  createExpense = async (req: any, res: Response) => {
  res.json(
    await service.createExpense(req.user.id, req.body)
  );
};

}
