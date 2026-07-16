# Regex Hit Rate Report

**Generated**: 2026-02-03 21:58

> **IMPORTANT CONTEXT**: This report measures regex performance **on the ground truth dataset, which was itself labeled using the same regex dictionary**. The near-perfect numbers confirm internal consistency — they do NOT predict real-world hit rates on unseen data. Expected real-world coverage is **80-85%**. See [ARCHITECTURE.md](../ARCHITECTURE.md) for production targets.

---

## Overall Metrics (Ground Truth Validation)

| Metric | Value |
|--------|-------|
| Total Records | 1,002,440 |
| Matched by Regex | 1,002,439 |
| Unmatched | 1 |
| **Hit Rate** | **99.9999%** |
| Correct Matches | 1,002,438 |
| Incorrect Matches | 1 |
| **Accuracy (when matched)** | **99.9999%** |

## 🔧 Match Type Breakdown

| Type | Count | % of Matches |
|------|-------|--------------|
| Merchant | 811,772 | 81.0% |
| Keyword | 190,667 | 19.0% |

## 📋 Coverage by Subcategory

| Subcategory | Total | Matched | Hit Rate | Accuracy |
|-------------|-------|---------|----------|----------|
| 🟢 sub_restaurants_bars | 113,835 | 113,835 | 100.0% | 100.0% |
| 🟢 sub_internet_phone | 109,886 | 109,886 | 100.0% | 100.0% |
| 🟢 sub_medical_pharmacy | 103,206 | 103,206 | 100.0% | 100.0% |
| 🟢 sub_cash_transfers | 70,539 | 70,538 | 100.0% | 100.0% |
| 🟢 sub_fashion | 56,813 | 56,813 | 100.0% | 100.0% |
| 🟢 sub_taxi_ride | 50,160 | 50,160 | 100.0% | 100.0% |
| 🟢 sub_home_general | 46,595 | 46,595 | 100.0% | 100.0% |
| 🟢 sub_gifts_donations | 45,559 | 45,559 | 100.0% | 100.0% |
| 🟢 sub_fitness_gym | 43,745 | 43,745 | 100.0% | 100.0% |
| 🟢 sub_public_transport | 40,200 | 40,200 | 100.0% | 100.0% |
| 🟢 sub_groceries | 36,223 | 36,223 | 100.0% | 100.0% |
| 🟢 sub_taxes_fees | 30,134 | 30,134 | 100.0% | 100.0% |
| 🟢 sub_salary | 26,405 | 26,405 | 100.0% | 100.0% |
| 🟢 sub_other_income | 19,794 | 19,794 | 100.0% | 100.0% |
| 🟢 sub_events_culture | 17,212 | 17,212 | 100.0% | 100.0% |
| 🟢 sub_flights | 16,204 | 16,204 | 100.0% | 100.0% |
| 🟢 sub_investments | 16,048 | 16,048 | 100.0% | 100.0% |
| 🟢 sub_subscriptions | 14,839 | 14,839 | 100.0% | 100.0% |
| 🟢 sub_fuel_tolls | 13,335 | 13,335 | 100.0% | 100.0% |
| 🟢 sub_utility_bills | 12,089 | 12,089 | 100.0% | 100.0% |
| 🟢 sub_electronics | 11,670 | 11,670 | 100.0% | 100.0% |
| 🟢 sub_side_hustle | 10,133 | 10,133 | 100.0% | 100.0% |
| 🟢 sub_delivery | 8,000 | 8,000 | 100.0% | 100.0% |
| 🟢 sub_dividends | 6,755 | 6,755 | 100.0% | 100.0% |
| 🟢 sub_cashback | 6,671 | 6,671 | 100.0% | 100.0% |
| 🟢 sub_home_maintenance | 5,781 | 5,781 | 100.0% | 100.0% |
| 🟢 sub_wellness_beauty | 5,686 | 5,686 | 100.0% | 100.0% |
| 🟢 sub_hotels_acc | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_supplementation | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_hobbies | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_family_kids | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_pets | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_crypto | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_savings | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_interest | 5,000 | 5,000 | 100.0% | 100.0% |
| 🟢 sub_refunds | 3,437 | 3,437 | 100.0% | 100.0% |
| 🟢 sub_rent_mortgage | 3,242 | 3,242 | 100.0% | 100.0% |
| 🟢 sub_atm_withdrawals | 3,214 | 3,214 | 100.0% | 100.0% |
| 🟢 sub_debt_loans | 3,137 | 3,137 | 100.0% | 100.0% |
| 🟢 sub_insurance | 3,070 | 3,070 | 100.0% | 100.0% |
| 🟢 sub_nfts | 3,000 | 3,000 | 100.0% | 100.0% |
| 🟢 sub_holidays_trips | 2,920 | 2,920 | 100.0% | 100.0% |
| 🟢 sub_education | 2,903 | 2,903 | 100.0% | 100.0% |

## ⚠️ Sample Misclassifications

| Description | True | Predicted | Type |
|-------------|------|-----------|------|
| Pharmacy Purchase | sub_cash_transfers | sub_medical_pharmacy | merchant |

## Next Steps

- **Target Hit Rate**: >80% on unseen, real-world transaction data
- Validate against external datasets not labeled by this regex dictionary
- Focus on subcategories with <50% hit rate on newly ingested data
- Review misclassifications to improve pattern precision
