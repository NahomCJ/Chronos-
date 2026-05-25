import { Parser } from 'json2csv';
import PDFDocument from 'pdfkit';
import fs from 'fs';

export const generateCSV = (transactions: any[]) => {
  const fields = ['createdAt', 'type', 'category', 'amount', 'currency'];
  const parser = new Parser({ fields });
  return parser.parse(transactions);
};

export const generatePDF = async (transactions: any[]) => {
  const doc = new PDFDocument();
  const filePath = `/tmp/tax-report-${Date.now()}.pdf`;

  doc.pipe(fs.createWriteStream(filePath));

  doc.fontSize(18).text('LifeX – Tax Report', { align: 'center' });
  doc.moveDown();

  transactions.forEach(tx => {
    doc
      .fontSize(12)
      .text(
        `${tx.createdAt} | ${tx.type} | ${tx.category} | ${tx.amount} ${tx.currency}`
      );
  });

  doc.end();
  return filePath;
};
