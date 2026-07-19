export interface Account {
  id: string;
  type: string;
  bank: string;
}

export interface Transaction {
  id: string;
  amount: number;
  date: string;
  description: string;
}

export interface Investment {
  id: string;
  asset: string;
  shares: number;
  value: number;
}

export interface Statement {
  month: string;
  link: string;
}

export interface CustomerInfo {
  name: string;
  email: string;
  phone: string;
  address: string;
}
