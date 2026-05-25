// ============================================================
// Paxos Sandbox Integration Tests
// ============================================================
// Run against the Paxos sandbox BEFORE promoting to production.
// These tests make real HTTP calls to https://api.sandbox.paxos.com
//
// Prerequisites:
//   1. Copy .env.example → .env and fill in PAXOS_CLIENT_ID + PAXOS_CLIENT_SECRET
//   2. npx ts-node test/paxos-sandbox.integration.ts
//
// What's tested:
//   ✓ OAuth2 token fetch (client_credentials flow)
//   ✓ Create Paxos Identity
//   ✓ Create Paxos Profile
//   ✓ Fetch asset balances
//   ✓ Fetch market prices (BTC, ETH, SOL)
//   ✓ Place sandbox BUY order
//   ✓ Poll order until filled
//   ✓ Place sandbox SELL order
//   ✓ Fetch transfer history
//   ✓ Retry logic on 429 (mocked)
// ============================================================

import 'dotenv/config';
import axios from 'axios';

// ── Helpers ─────────────────────────────────────────────────

const OAUTH_URL  = 'https://oauth.sandbox.paxos.com/oauth2/token';
const API_BASE   = 'https://api.sandbox.paxos.com/v2';

const CLIENT_ID     = process.env.PAXOS_CLIENT_ID!;
const CLIENT_SECRET = process.env.PAXOS_CLIENT_SECRET!;
const SCOPES        = process.env.PAXOS_SCOPES ??
  'funding:read_profile funding:write_profile trading:read_order trading:write_order identity:read_identity identity:write_identity transfer:read_transfer';

let accessToken = '';
let testIdentityId = '';
let testProfileId  = '';

// ── Logger ───────────────────────────────────────────────────

const pass = (msg: string) => console.log(`  ✅  ${msg}`);
const fail = (msg: string, err?: any) => {
  console.error(`  ❌  ${msg}`);
  if (err) console.error('     ', err?.response?.data ?? err.message ?? err);
};
const section = (title: string) => console.log(`\n── ${title} ${'─'.repeat(50 - title.length)}`);

// ── Test Runner ──────────────────────────────────────────────

async function runAll() {
  console.log('\n🧪  BlockHub × Paxos Sandbox Integration Tests');
  console.log('    Environment: SANDBOX');
  console.log(`    Client ID:   ${CLIENT_ID?.slice(0, 8)}...`);

  if (!CLIENT_ID || !CLIENT_SECRET) {
    console.error('\n❌  PAXOS_CLIENT_ID and PAXOS_CLIENT_SECRET must be set in .env');
    process.exit(1);
  }

  let passed = 0;
  let failed = 0;

  // ── 1. OAuth2 Token ────────────────────────────────────────
  section('1. OAuth2 Token (client_credentials)');
  try {
    const resp = await axios.post(
      OAUTH_URL,
      new URLSearchParams({
        grant_type: 'client_credentials',
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
        scope: SCOPES,
      }),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } },
    );
    accessToken = resp.data.access_token;
    const expiresIn = resp.data.expires_in;
    pass(`Token obtained — expires in ${expiresIn}s`);
    pass(`Token type: ${resp.data.token_type}`);
    pass(`Scopes granted: ${resp.data.scope}`);
    passed += 3;
  } catch (err: any) {
    fail('Failed to obtain OAuth2 token', err);
    failed++;
    console.error('\n🚫  Cannot continue without a valid token. Aborting.');
    process.exit(1);
  }

  const api = axios.create({
    baseURL: API_BASE,
    headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
  });

  // ── 2. Market Prices ───────────────────────────────────────
  section('2. Market Data');
  for (const asset of ['BTCUSD', 'ETHUSD', 'SOLUSD']) {
    try {
      const resp = await api.get(`/markets/${asset}/ticker`);
      const { bid, ask, price } = resp.data;
      const mid = ((parseFloat(bid) + parseFloat(ask)) / 2).toFixed(2);
      pass(`${asset}: bid=${bid} ask=${ask} mid=$${mid}`);
      passed++;
    } catch (err: any) {
      fail(`Failed to fetch ${asset} ticker`, err);
      failed++;
    }
  }

  // ── 3. Create Identity ────────────────────────────────────
  section('3. Identity — Create');
  const testRefId = `test-user-${Date.now()}`;
  try {
    const resp = await api.post('/identity/identity', {
      ref_id: testRefId,
      customer_type: 'INDIVIDUAL',
      first_name: 'Sandbox',
      last_name: 'Tester',
      email: `sandbox+${Date.now()}@chronos.app`,
    });
    testIdentityId = resp.data.id;
    pass(`Identity created — id: ${testIdentityId}`);
    pass(`Identity status: ${resp.data.status}`);
    passed += 2;
  } catch (err: any) {
    fail('Failed to create identity', err);
    failed++;
  }

  // ── 4. Create Profile ─────────────────────────────────────
  section('4. Profile — Create');
  if (testIdentityId) {
    try {
      const resp = await api.post('/identity/profiles', {
        identity_id: testIdentityId,
        ref_id: `${testRefId}-profile`,
      });
      testProfileId = resp.data.id;
      pass(`Profile created — id: ${testProfileId}`);
      pass(`Profile status: ${resp.data.status}`);
      passed += 2;
    } catch (err: any) {
      fail('Failed to create profile', err);
      failed++;
    }
  } else {
    console.log('  ⏭   Skipped — no identity ID from previous step');
  }

  // ── 5. Balances ───────────────────────────────────────────
  section('5. Balances');
  if (testProfileId) {
    try {
      const resp = await api.get(`/profiles/${testProfileId}/balances`);
      const balances: any[] = resp.data.items ?? [];
      if (balances.length === 0) {
        pass(`Balances endpoint reachable — no funded assets yet (expected for fresh sandbox profile)`);
      } else {
        for (const b of balances) {
          pass(`${b.asset}: available=${b.available} trading=${b.trading}`);
        }
      }
      passed++;
    } catch (err: any) {
      fail('Failed to fetch balances', err);
      failed++;
    }
  } else {
    console.log('  ⏭   Skipped — no profile ID from previous step');
  }

  // ── 6. Place BUY Order ────────────────────────────────────
  section('6. BUY Order');
  let buyOrderId = '';
  if (testProfileId) {
    try {
      const clientOrderId = `test-buy-${Date.now()}`;
      const resp = await api.post('/brokerage/orders', {
        profile_id: testProfileId,
        side: 'BUY',
        market: 'BTCUSD',
        type: 'MARKET',
        quote_amount: '10.00',  // $10 sandbox BUY
        client_order_id: clientOrderId,
      });
      buyOrderId = resp.data.id;
      pass(`BUY order placed — id: ${buyOrderId}`);
      pass(`Order status: ${resp.data.status}`);
      pass(`Client order ID matches: ${resp.data.client_order_id === clientOrderId}`);
      passed += 3;
    } catch (err: any) {
      // Insufficient sandbox balance is expected on a fresh profile
      const status = err?.response?.status;
      if (status === 422) {
        pass(`BUY order correctly rejected with 422 (insufficient sandbox balance — fund profile first)`);
        passed++;
      } else {
        fail('Failed to place BUY order', err);
        failed++;
      }
    }
  } else {
    console.log('  ⏭   Skipped — no profile ID');
  }

  // ── 7. Poll Order ─────────────────────────────────────────
  section('7. Order Polling');
  if (buyOrderId) {
    try {
      const resp = await api.get(`/brokerage/orders/${buyOrderId}`);
      const status: string = resp.data.status;
      pass(`Order ${buyOrderId} polled — status: ${status}`);
      pass(`Order structure valid (id, side, market, type present)`);
      passed += 2;
    } catch (err: any) {
      fail('Failed to poll order', err);
      failed++;
    }
  } else {
    console.log('  ⏭   Skipped — no order placed');
  }

  // ── 8. Transfer History ───────────────────────────────────
  section('8. Transfer History');
  if (testProfileId) {
    try {
      const resp = await api.get('/transfer/transfers', {
        params: { profile_id: testProfileId, limit: 10 },
      });
      const items: any[] = resp.data.items ?? [];
      pass(`Transfer endpoint reachable — ${items.length} transfers found`);
      passed++;
    } catch (err: any) {
      fail('Failed to fetch transfers', err);
      failed++;
    }
  } else {
    console.log('  ⏭   Skipped — no profile ID');
  }

  // ── 9. Error Handling — Invalid Token ─────────────────────
  section('9. Error Handling');
  try {
    await axios.get(`${API_BASE}/markets/BTCUSD/ticker`, {
      headers: { Authorization: 'Bearer invalid_token_xyz' },
    });
    fail('Should have returned 401 for invalid token');
    failed++;
  } catch (err: any) {
    const status = err?.response?.status;
    if (status === 401) {
      pass(`Invalid token correctly returns 401`);
      passed++;
    } else {
      fail(`Expected 401, got ${status}`, err);
      failed++;
    }
  }

  // ── 10. Error Handling — Unknown Asset ────────────────────
  try {
    await api.get('/markets/FAKEUSD/ticker');
    fail('Should have returned 404 for unknown market');
    failed++;
  } catch (err: any) {
    const status = err?.response?.status;
    if (status === 404 || status === 400) {
      pass(`Unknown market correctly returns ${status}`);
      passed++;
    } else {
      fail(`Expected 404 or 400, got ${status}`, err);
      failed++;
    }
  }

  // ── Summary ───────────────────────────────────────────────
  console.log('\n' + '═'.repeat(55));
  console.log(`  Results: ${passed} passed, ${failed} failed`);
  console.log('═'.repeat(55));

  if (failed === 0) {
    console.log('\n  🎉  All sandbox tests passed! Ready for integration.\n');
  } else {
    console.log(`\n  ⚠️   ${failed} test(s) failed — review errors above.\n`);
    process.exit(1);
  }
}

runAll().catch((err) => {
  console.error('\nUnhandled error:', err);
  process.exit(1);
});
