const base = (content: string) => `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f4f4f5; margin: 0; padding: 32px 16px; }
    .card { background: #fff; border-radius: 12px; max-width: 520px; margin: 0 auto; padding: 40px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
    .logo { font-size: 22px; font-weight: 700; color: #111; margin-bottom: 32px; letter-spacing: -0.5px; }
    h2 { font-size: 20px; color: #111; margin: 0 0 12px; }
    p { font-size: 15px; color: #444; line-height: 1.6; margin: 0 0 16px; }
    .amount { font-size: 28px; font-weight: 700; color: #111; margin: 20px 0; }
    .badge { display: inline-block; padding: 6px 14px; border-radius: 99px; font-size: 13px; font-weight: 600; margin-bottom: 20px; }
    .badge-success { background: #dcfce7; color: #16a34a; }
    .badge-warn { background: #fef9c3; color: #854d0e; }
    .badge-error { background: #fee2e2; color: #b91c1c; }
    .otp { font-size: 36px; font-weight: 800; letter-spacing: 8px; color: #111; text-align: center; margin: 24px 0; }
    .row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f0f0f0; font-size: 14px; }
    .row span:first-child { color: #888; }
    .row span:last-child { color: #111; font-weight: 500; }
    .footer { margin-top: 32px; font-size: 12px; color: #aaa; text-align: center; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">⟡ Chronos</div>
    ${content}
    <div class="footer">© ${new Date().getFullYear()} Chronos · All rights reserved</div>
  </div>
</body>
</html>`;

export const welcome = (firstName: string) => base(`
  <h2>Welcome to Chronos, ${firstName}!</h2>
  <p>Your account has been created. You now have access to banking, BNPL, FX, and more — all in one place.</p>
  <p>Complete your identity verification to unlock the full suite of Chronos features.</p>
`);

export const otp = (code: string) => base(`
  <h2>Your password reset code</h2>
  <p>Use the code below to reset your Chronos password. It expires in <strong>15 minutes</strong>.</p>
  <div class="otp">${code}</div>
  <p>If you didn't request this, you can safely ignore this email.</p>
`);

export const passwordChanged = () => base(`
  <h2>Password changed</h2>
  <span class="badge badge-success">Secured</span>
  <p>Your Chronos password was successfully changed. If you did not make this change, contact support immediately.</p>
`);

export const transferCompleted = (amount: string, currency: string, note?: string) => base(`
  <h2>Transfer Completed</h2>
  <span class="badge badge-success">Completed</span>
  <div class="amount">${currency} ${amount}</div>
  ${note ? `<p>${note}</p>` : ""}
  <p>The transfer has been processed and funds are on their way.</p>
`);

export const transferFailed = (amount: string, currency: string) => base(`
  <h2>Transfer Failed</h2>
  <span class="badge badge-error">Failed</span>
  <div class="amount">${currency} ${amount}</div>
  <p>We were unable to process your transfer. No funds have been moved. Please try again or contact support.</p>
`);

export const transferCancelled = (amount: string, currency: string) => base(`
  <h2>Transfer Cancelled</h2>
  <span class="badge badge-warn">Cancelled</span>
  <div class="amount">${currency} ${amount}</div>
  <p>Your transfer has been cancelled and no funds have been moved.</p>
`);

export const cardIssued = (type: string, last4: string) => base(`
  <h2>Your ${type} Card is Ready</h2>
  <span class="badge badge-success">Active</span>
  <div class="row"><span>Card type</span><span>${type}</span></div>
  <div class="row"><span>Last 4 digits</span><span>•••• ${last4}</span></div>
  <p style="margin-top:16px;">Your card is active and ready to use.</p>
`);

export const cardReplaced = (last4: string) => base(`
  <h2>Card Replaced</h2>
  <span class="badge badge-success">Active</span>
  <p>Your old card has been deactivated. Your new card ending in <strong>${last4}</strong> is now active.</p>
`);

export const cardFrozen = (last4: string) => base(`
  <h2>Card Frozen</h2>
  <span class="badge badge-warn">Frozen</span>
  <p>Your card ending in <strong>${last4}</strong> has been frozen. All transactions on this card are paused.</p>
  <p>Contact support or log in to your account to manage your card.</p>
`);

export const pinChanged = (last4: string) => base(`
  <h2>Card PIN Updated</h2>
  <span class="badge badge-success">Updated</span>
  <p>The PIN for your card ending in <strong>${last4}</strong> was successfully changed.</p>
  <p>If you did not make this change, please freeze your card immediately.</p>
`);

export const billPayment = (providerName: string, amount: string, reference: string) => base(`
  <h2>Bill Payment Received</h2>
  <span class="badge badge-success">Pending</span>
  <div class="amount">$${amount}</div>
  <div class="row"><span>Provider</span><span>${providerName}</span></div>
  <div class="row"><span>Reference</span><span>${reference}</span></div>
  <p style="margin-top:16px;">Your bill payment is being processed.</p>
`);

export const fxExecuted = (sellAmount: string, sellCurrency: string, buyAmount: string, buyCurrency: string, rate: string) => base(`
  <h2>FX Order Executed</h2>
  <span class="badge badge-success">Executed</span>
  <div class="row"><span>You sold</span><span>${sellCurrency} ${sellAmount}</span></div>
  <div class="row"><span>You received</span><span>${buyCurrency} ${buyAmount}</span></div>
  <div class="row"><span>Rate</span><span>${rate}</span></div>
  <p style="margin-top:16px;">Funds have been credited to your wallet.</p>
`);

export const kycApproved = (firstName: string) => base(`
  <h2>Identity Verified, ${firstName}!</h2>
  <span class="badge badge-success">Approved</span>
  <p>Your identity has been verified. You now have full access to all Chronos banking features including transfers, FX, and cards.</p>
`);

export const kycRejected = (firstName?: string) => base(`
  <h2>Verification Update${firstName ? `, ${firstName}` : ""}</h2>
  <span class="badge badge-error">Not Verified</span>
  <p>We were unable to verify your identity at this time. Please log in and retry the verification process with a valid government-issued ID.</p>
  <p>If you believe this is an error, contact our support team.</p>
`);

export const kycBankReauthRequired = () => base(`
  <h2>Bank Re-authentication Required</h2>
  <span class="badge badge-warn">Action Needed</span>
  <p>Your linked bank account requires re-authentication. Please log in to Chronos and reconnect your bank to continue using banking features.</p>
`);

export const bnplAccountCreated = () => base(`
  <h2>TickPay Account Created</h2>
  <span class="badge badge-success">Active</span>
  <p>Your TickPay (Buy Now, Pay Later) account is ready. You can now split eligible purchases into installments.</p>
`);

export const bnplCardIssued = () => base(`
  <h2>Your TickPay Card is Ready</h2>
  <span class="badge badge-success">Active</span>
  <p>Your TickPay virtual card has been issued and is ready to use for eligible purchases.</p>
`);

export const bnplPurchaseApproved = (amount: string, merchant: string) => base(`
  <h2>Purchase Approved</h2>
  <span class="badge badge-success">Approved</span>
  <div class="amount">$${amount}</div>
  <div class="row"><span>Merchant</span><span>${merchant}</span></div>
  <p style="margin-top:16px;">Your TickPay purchase has been approved. Installment details will be shared separately.</p>
`);

export const bnplPurchaseDenied = (amount: string, merchant: string) => base(`
  <h2>Purchase Not Approved</h2>
  <span class="badge badge-error">Denied</span>
  <div class="amount">$${amount}</div>
  <div class="row"><span>Merchant</span><span>${merchant}</span></div>
  <p style="margin-top:16px;">This purchase could not be approved at this time. Try a smaller amount or contact support.</p>
`);
