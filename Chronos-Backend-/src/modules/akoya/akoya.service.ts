export const fetchAccounts = () => {
  return [{ id: 'acc123', type: 'checking', bank: 'DemoBank' }];
};

export const fetchBalances = () => {
  return [{ accountId: 'acc123', balance: 1290.45 }];
};

export const fetchTransactions = () => {
  return [
    { id: 'txn1', amount: -25.99, date: '2025-08-01', description: 'Uber Ride' },
    { id: 'txn2', amount: 300.0, date: '2025-07-30', description: 'Freelance Payment' },
  ];
};

export const fetchStatements = () => {
  return [
    { month: 'July 2025', link: '/statements/july2025.pdf' },
    { month: 'June 2025', link: '/statements/june2025.pdf' },
  ];
};

export const fetchInvestments = () => {
  return [{ id: 'inv1', asset: 'AAPL', shares: 12, value: 2200 }];
};

export const fetchCustomerInfo = () => {
  return {
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+1234567890',
    address: '123 Tech Blvd, San Francisco, CA',
  };
};
