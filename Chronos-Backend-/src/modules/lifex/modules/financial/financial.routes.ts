import { Router } from "express";
import { requireAuth, requireAdmin } from "../../../auth/middlewares/auth.middleware";
import { FinancialController } from "./financial.controller";

const router = Router();
const financialCtrl = new FinancialController();

/* ================= DASHBOARD ================= */
router.get("/overview", requireAuth, financialCtrl.overview);

/* ================= SAVINGS ================= */
router.post("/savings", requireAuth, financialCtrl.createSavings);
router.get("/savings", requireAuth, financialCtrl.listSavings);

/* ================= BUDGET ================= */
router.post("/budget", requireAuth, financialCtrl.createBudget);
router.get("/budget", requireAuth, financialCtrl.listBudgets);
router.get("/budget/monthly", requireAuth, financialCtrl.monthlyBudget);

/* ================= LOANS ================= */
router.get("/loans", requireAuth, financialCtrl.listLoans);
router.post("/loans/pay/:id", requireAuth, financialCtrl.payLoan);

router.post('/loans', requireAuth, financialCtrl.createLoan);

/* ================= INVESTMENT ================= */
router.get("/investments/advice", requireAuth, financialCtrl.investmentAdvice);

/* ================= CREDIT ================= */
router.get("/credit-score", requireAuth, financialCtrl.creditScore);

/* ================= ANALYTICS ================= */
router.get(
  "/charts/planned-vs-actual",
  requireAuth,
  financialCtrl.plannedVsActual
);

/* ================= TAX ================= */
router.get("/tax-report", requireAuth, financialCtrl.taxReport);

router.post(
  "/expenses",
  requireAuth,
  financialCtrl.createExpense
);


export default router;
