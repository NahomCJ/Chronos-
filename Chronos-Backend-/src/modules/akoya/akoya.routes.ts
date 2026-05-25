import { Router } from 'express';
import {
  getAccounts,
  getBalances,
  getTransactions,
  getStatements,
  getInvestments,
  getCustomerInfo,
} from './akoya.controller';

const router = Router();

router.get('/accounts', getAccounts);
router.get('/balances', getBalances);
router.get('/transactions', getTransactions);
router.get('/statements', getStatements);
router.get('/investments', getInvestments);
router.get('/customer', getCustomerInfo);

export default router;
