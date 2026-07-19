import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
TC_CLASSIFIER_ROOT = PROJECT_ROOT / "services" / "TC-TransactionClassifier"
TC_CLASSIFIER_MODULES = TC_CLASSIFIER_ROOT / "classifier"
BANKING_MODULES = PROJECT_ROOT / "services" / "banking"

for path in (PROJECT_ROOT, TC_CLASSIFIER_ROOT, TC_CLASSIFIER_MODULES, BANKING_MODULES):
    if str(path) not in sys.path:
        sys.path.insert(0, str(path))
