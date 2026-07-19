import os

repo_root = "/Users/martin/My Drive/Kalós/martinhijarx/AI Projects/CHRONOS"
skills_dir = os.path.join(repo_root, ".agent/skills")

# CODE-REVIEW_SKILL
with open(os.path.join(skills_dir, "CODE-REVIEW_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace("`score >= 70` is LOW risk", "`value >= threshold` is STATE_A")
text = text.replace(
    "`amount = 0`, empty list of bills, `num_payments = 0`",
    "`input_a = 0`, empty list of items, `count = 0`",
)
text = text.replace(
    "`projected_balance` not `pb`, `risk_level` not `rl`",
    "`calculated_metric` not `cm`, `status_level` not `sl`",
)
text = text.replace(
    "Supabase or another service", "a database or another external service"
)
text = text.replace(
    "Review services/<module>/<file>.py", "Review path/to/<module>/<file>.py"
)
with open(os.path.join(skills_dir, "CODE-REVIEW_SKILL.md"), "w") as f:
    f.write(text)

# DEBUG_SKILL
with open(os.path.join(skills_dir, "DEBUG_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace(
    "Reading `user.balance` instead of `user.available_balance`",
    "Reading `object.value` instead of `object.active_value`",
)
text = text.replace("Supabase connection", "database connection")
with open(os.path.join(skills_dir, "DEBUG_SKILL.md"), "w") as f:
    f.write(text)

# DOC_SKILL
with open(os.path.join(skills_dir, "DOC_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace(
    "`services/<dependency_module>.py`, `models/<model>.py`",
    "`path/to/<dependency_module>.py`, `path/to/<model>.py`",
)
text = text.replace('{"entity_id": 123, "amount": 500}', '{"id": 123, "value": 500}')
text = text.replace(
    '{"score": 85, "status": "approved"}', '{"status": "success", "metric": 85}'
)
text = text.replace(
    "pytest services/module_name/tests/test_foo.py -v",
    "pytest path/to/tests/test_module.py -v",
)
text = text.replace("get_balance()", "get_user_data()")
text = text.replace(
    """def evaluate_entity(entity_data: dict, strict_mode: bool = False) -> dict:""",
    """def process_data(input_data: dict, strict_mode: bool = False) -> dict:""",
)
text = text.replace(
    """Evaluates an entity against the module's scoring criteria.""",
    """Processes the input data strictly according to the module's validation rules.""",
)
text = text.replace(
    """entity_data (dict): Must contain 'entity_id' and all required scoring fields.""",
    """input_data (dict): Must contain 'id' and all required fields.""",
)
text = text.replace(
    """dict: {"approved": bool, "score": int (0-100), "reason": str}""",
    """dict: {"status": "success|failure", "metric": int, "reason": str}""",
)
text = text.replace(
    """ValueError: If required keys are missing in entity_data.""",
    """ValueError: If required keys are missing in input_data.""",
)
with open(os.path.join(skills_dir, "DOC_SKILL.md"), "w") as f:
    f.write(text)

# INTEGRATION_TEST_SKILL
with open(os.path.join(skills_dir, "INTEGRATION_TEST_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace("Supabase connection", "database connection")
text = text.replace("services/<producer>/<module>.py", "path/to/<producer>.py")
text = text.replace("services/<consumer>/<module>.py", "path/to/<consumer>.py")
text = text.replace(
    """- [ ] HIGH-tier user — tests nominal flow end-to-end
- [ ] LOW-tier user — tests the other extreme
- [ ] MEDIUM-tier user — tests the middle tier""",
    """- [ ] Scenario A (Nominal) — tests typical flow end-to-end
- [ ] Scenario B (Alternate) — tests the other extreme
- [ ] Scenario C (Edge) — tests a valid but rare state""",
)
text = text.replace(
    """- [ ] Input that lands exactly at the LOW/MEDIUM threshold
- [ ] Input that lands exactly at the MEDIUM/HIGH threshold
- [ ] Zero amount / zero balance edge case""",
    """- [ ] Input that lands exactly at the Boundary A/B threshold
- [ ] Input that lands exactly at the Boundary B/C threshold
- [ ] Zero or empty edge case""",
)

tests_code_before = """# ─── Fixtures ────────────────────────────────────────────────────────────────

@pytest.fixture
def high_tier_entity():
    \"\"\"HIGH-tier entity. Near the threshold for the worst outcome.\"\"\"
    return "entity_high"  # Provide values that trigger HIGH tier

@pytest.fixture
def low_tier_entity():
    \"\"\"LOW-tier entity. Comfortable margin.\"\"\"
    return "entity_low"   # Provide values that trigger LOW tier

@pytest.fixture
def mid_tier_entity():
    \"\"\"MEDIUM-tier entity. Tight but manageable.\"\"\"
    return "entity_mid"   # Provide values that trigger MEDIUM tier


# ─── Happy Path ──────────────────────────────────────────────────────────────

def test_high_tier_contract_holds(high_tier_entity):
    \"\"\"Producer returns shape consumer can use. Entity should be HIGH.\"\"\"
    result = consumer_function(high_tier_entity, 200.00)
    assert "risk_level" in result
    assert "warning_message" in result
    assert result["risk_level"] == "HIGH"

def test_low_tier_contract_holds(low_tier_entity):
    \"\"\"Comfortable margin should yield LOW tier.\"\"\"
    result = consumer_function(low_tier_entity, 200.00)
    assert result["risk_level"] == "LOW"

def test_mid_tier_contract_holds(mid_tier_entity):
    \"\"\"Lands in the MEDIUM tier.\"\"\"
    result = consumer_function(mid_tier_entity, 200.00)
    assert result["risk_level"] == "MEDIUM"


# ─── Boundary Values ─────────────────────────────────────────────────────────

def test_threshold_low_medium_boundary():
    \"\"\"Exactly at the LOW/MEDIUM boundary. Verify which side it falls on.\"\"\"
    result = consumer_function("entity_mid", [THRESHOLD_AMOUNT])
    assert result["risk_level"] in ("LOW", "MEDIUM")  # Clarify exact value with spec

def test_zero_amount_edge_case(low_tier_entity):
    \"\"\"Zero input should not crash and should return LOW or equivalent.\"\"\"
    result = consumer_function(low_tier_entity, 0.00)
    assert result is not None
    assert "risk_level" in result"""

tests_code_after = """# ─── Fixtures ────────────────────────────────────────────────────────────────

@pytest.fixture
def scenario_a_input():
    \"\"\"Scenario A input. Typical nominal flow.\"\"\"
    return "input_a"  # Provide values that trigger Scenario A

@pytest.fixture
def scenario_b_input():
    \"\"\"Scenario B input. The other extreme.\"\"\"
    return "input_b"   # Provide values that trigger Scenario B

@pytest.fixture
def scenario_c_input():
    \"\"\"Scenario C input. Tight but manageable state.\"\"\"
    return "input_c"   # Provide values that trigger Scenario C


# ─── Happy Path ──────────────────────────────────────────────────────────────

def test_scenario_a_contract_holds(scenario_a_input):
    \"\"\"Producer returns expected shape for Scenario A.\"\"\"
    result = consumer_function(scenario_a_input, 200.00)
    assert "status" in result
    assert "message" in result
    assert result["status"] == "SCENARIO_A"

def test_scenario_b_contract_holds(scenario_b_input):
    \"\"\"Alternate margin should yield Scenario B.\"\"\"
    result = consumer_function(scenario_b_input, 200.00)
    assert result["status"] == "SCENARIO_B"

def test_scenario_c_contract_holds(scenario_c_input):
    \"\"\"Lands in Scenario C.\"\"\"
    result = consumer_function(scenario_c_input, 200.00)
    assert result["status"] == "SCENARIO_C"


# ─── Boundary Values ─────────────────────────────────────────────────────────

def test_threshold_ab_boundary():
    \"\"\"Exactly at the Boundary A/B threshold. Verify which side it falls on.\"\"\"
    result = consumer_function("input_c", [BOUNDARY_THRESHOLD])
    assert result["status"] in ("SCENARIO_A", "SCENARIO_B")  # Clarify exact value with spec

def test_zero_edge_case(scenario_b_input):
    \"\"\"Zero input should not crash and should return safe default.\"\"\"
    result = consumer_function(scenario_b_input, 0.00)
    assert result is not None
    assert "status" in result"""

text = text.replace(tests_code_before, tests_code_after)

table_before = """| HIGH-tier entity | risk_level: HIGH | ... | ✅/❌ | [name] |
| LOW-tier entity | risk_level: LOW | ... | ✅/❌ | [name] |
| MEDIUM-tier entity | risk_level: MEDIUM | ... | ✅/❌ | [name] |
| Boundary LOW/MED | defined by spec | ... | ✅/❌ | [name] |"""
table_after = """| Scenario A Input | status: SCENARIO_A | ... | ✅/❌ | [name] |
| Scenario B Input | status: SCENARIO_B | ... | ✅/❌ | [name] |
| Scenario C Input | status: SCENARIO_C | ... | ✅/❌ | [name] |
| Boundary A/B | defined by spec | ... | ✅/❌ | [name] |"""

text = text.replace(table_before, table_after)
with open(os.path.join(skills_dir, "INTEGRATION_TEST_SKILL.md"), "w") as f:
    f.write(text)

# OBSERVABILITY_SKILL.md
with open(os.path.join(skills_dir, "OBSERVABILITY_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace(
    'entity_id="entity_123", amount=200.0', 'id="item_123", params=200.0'
)
text = text.replace(
    "process_request(entity_id: str, amount: float) -> dict:",
    "process_request(item_id: str, amount: float) -> dict:",
)
text = text.replace(
    "evaluate_entity(entity_id: str, amount: float, num_items: int) -> dict:",
    "calculate_metrics(item_id: str, value: float, count: int) -> dict:",
)
text = text.replace("--user entity_123", "--id item_123")
text = text.replace("trace a specific entity", "trace a specific item")
text = text.replace("Supabase, APIs", "Databases, APIs")
text = text.replace("services/<module>/<file>.py", "path/to/<module>/<file>.py")
with open(os.path.join(skills_dir, "OBSERVABILITY_SKILL.md"), "w") as f:
    f.write(text)

# ONBOARDING_SKILL.md
with open(os.path.join(skills_dir, "ONBOARDING_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace("OPENAI_API_KEY, SUPABASE_URL, etc.", "API_KEY, DATABASE_URL, etc.")
with open(os.path.join(skills_dir, "ONBOARDING_SKILL.md"), "w") as f:
    f.write(text)

# TASK-DEFINER_SKILL.md
with open(os.path.join(skills_dir, "TASK-DEFINER_SKILL.md"), "r") as f:
    text = f.read()
text = text.replace(
    "The Brain that decides if something is risky",
    "The Core Engine that processes the primary logic",
)
text = text.replace("services.x.y", "path.to.module")
with open(os.path.join(skills_dir, "TASK-DEFINER_SKILL.md"), "w") as f:
    f.write(text)

print("Done fixing overfitting!")
