from pathlib import Path

import coremltools as ct
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split

BASE_DIR = Path(__file__).parent

SYNTHETIC_DATA_PATH = BASE_DIR / "task_placement_training_data.csv"
USER_FEEDBACK_DATA_PATH = BASE_DIR / "task_placement_feedback.csv"
MODEL_PATH = BASE_DIR / "TaskPlacementScorer.mlpackage"

FEATURE_COLUMNS = [
    "priority",
    "energyLevel",
    "durationMinutes",
    "minutesUntilDeadline",
    "startHour",
    "slotDurationMinutes",
    "remainingSlotMinutes",
    "categoryValue",
]

TARGET_COLUMN = "targetScore"
WEIGHT_COLUMN = "sampleWeight"


def load_training_data() -> pd.DataFrame:
    datasets = []

    if SYNTHETIC_DATA_PATH.exists():
        synthetic_data = pd.read_csv(SYNTHETIC_DATA_PATH)
        datasets.append(synthetic_data)

        print(
            f"Loaded {len(synthetic_data)} synthetic training examples"
        )

    if USER_FEEDBACK_DATA_PATH.exists():
        feedback_data = pd.read_csv(USER_FEEDBACK_DATA_PATH)

        if WEIGHT_COLUMN not in feedback_data.columns:
            feedback_data[WEIGHT_COLUMN] = 1.0

        if "source" not in feedback_data.columns:
            feedback_data["source"] = "user_feedback"

        datasets.append(feedback_data)

        print(
            f"Loaded {len(feedback_data)} user feedback examples"
        )

    if not datasets:
        raise FileNotFoundError(
            "No training data found. Run generate_training_data.py first."
        )

    return pd.concat(datasets, ignore_index=True)


def main() -> None:
    data = load_training_data()

    X = data[FEATURE_COLUMNS]
    y = data[TARGET_COLUMN]

    if WEIGHT_COLUMN in data.columns:
        weights = data[WEIGHT_COLUMN]
    else:
        weights = pd.Series(1.0, index=data.index)

    (
        X_train,
        X_test,
        y_train,
        y_test,
        weights_train,
        _,
    ) = train_test_split(
        X,
        y,
        weights,
        test_size=0.2,
        random_state=42,
    )

    model = RandomForestRegressor(
        n_estimators=150,
        max_depth=12,
        random_state=42,
        n_jobs=-1,
    )

    model.fit(
        X_train,
        y_train,
        sample_weight=weights_train,
    )

    predictions = model.predict(X_test)

    mae = mean_absolute_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)

    print()
    print(f"Total training examples: {len(data)}")
    print(f"MAE: {mae:.4f}")
    print(f"R²: {r2:.4f}")

    coreml_model = ct.converters.sklearn.convert(
        model,
        input_features=FEATURE_COLUMNS,
        output_feature_names="score",
    )

    coreml_model.author = "Vidhi Dave"
    coreml_model.short_description = (
        "Scores candidate task placements for Smart Day Planner."
    )

    coreml_model.save(MODEL_PATH)

    print(f"Saved Core ML model to: {MODEL_PATH}")


if __name__ == "__main__":
    main()