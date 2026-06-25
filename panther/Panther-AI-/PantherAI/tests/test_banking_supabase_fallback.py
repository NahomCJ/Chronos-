"""
Regression coverage for banking local fallback behavior.

The mobile sprint depends on demo flows staying runnable when Supabase is
configured but unreachable, which is the normal local development setup.
"""

from services.banking import mock_api


class BrokenSupabaseClient:
    def table(self, _name):
        return self

    def select(self, *_args, **_kwargs):
        return self

    def eq(self, *_args, **_kwargs):
        return self

    def neq(self, *_args, **_kwargs):
        return self

    def gte(self, *_args, **_kwargs):
        return self

    def order(self, *_args, **_kwargs):
        return self

    def execute(self):
        raise RuntimeError("supabase is offline")


def force_broken_supabase(monkeypatch):
    monkeypatch.setattr(mock_api, "_get_supabase", lambda: BrokenSupabaseClient())
    monkeypatch.setattr(mock_api, "_get_plaid_access_token", lambda _user_id: None)


def test_balance_falls_back_when_supabase_query_fails(monkeypatch):
    force_broken_supabase(monkeypatch)

    assert mock_api.get_balance("user_marcus") == 1600.0


def test_bills_fall_back_when_supabase_query_fails(monkeypatch):
    force_broken_supabase(monkeypatch)

    bills = mock_api.get_upcoming_bills("user_marcus", days_ahead=7)

    assert {bill["name"] for bill in bills} >= {"Rent", "Netflix", "Utilities"}


def test_transactions_fall_back_when_supabase_query_fails(monkeypatch):
    force_broken_supabase(monkeypatch)

    transactions = mock_api.get_transactions("user_marcus", days_back=90)

    assert len(transactions) >= 20
    assert transactions[0]["merchant"]
    assert transactions[0]["category"]


def test_bnpl_counts_fall_back_when_supabase_query_fails(monkeypatch):
    force_broken_supabase(monkeypatch)

    assert mock_api.count_active_bnpls("user_marcus") == 2
    assert mock_api.get_active_bnpl_amount("user_marcus") == 350.0
    assert mock_api.count_late_bnpl_payments("user_bob") == 1
