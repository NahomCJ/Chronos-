import nodemailer from "nodemailer";

let _transporter: nodemailer.Transporter | null = null;

function getTransporter() {
  if (_transporter) return _transporter;
  if (!process.env.SMTP_HOST) return null;
  _transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT) || 587,
    secure: false,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });
  return _transporter;
}

export async function sendEmail(to: string, subject: string, html: string): Promise<void> {
  try {
    const t = getTransporter();
    if (!t) return;
    await t.sendMail({
      from: process.env.SMTP_FROM || '"Chronos" <noreply@chronos.app>',
      to,
      subject,
      html,
    });
  } catch (err: any) {
    console.error("[Email] send failed:", err?.message);
  }
}
