import csv
import random
from pathlib import Path

OUTPUT_PATH = Path(__file__).parent / "task_placement_training_data.csv"
ROW_COUNT = 30000


def clamp(value: float, minimum: float = 0.0, maximum: float = 1.0) -> float:
    return max(minimum, min(value, maximum))


def priority_score(priority: int) -> float:
    if priority >= 5:
        return 0.20
    if priority == 4:
        return 0.15
    if priority == 3:
        return 0.10
    if priority == 2:
        return 0.05
    return 0.0


def deadline_score(hours_remaining: float) -> float:
    if hours_remaining <= 0:
        return -0.25
    if hours_remaining <= 6:
        return 0.20
    if hours_remaining <= 24:
        return 0.15
    if hours_remaining <= 72:
        return 0.10
    return 0.05


def duration_fit_score(remaining_minutes: float) -> float:
    if remaining_minutes < 0:
        return -1.0
    if remaining_minutes <= 30:
        return 0.15
    if remaining_minutes <= 90:
        return 0.10
    return 0.05


def energy_time_score(energy_level: int, hour: int) -> float:
    if energy_level >= 4:
        if 8 <= hour < 12:
            return 0.15
        if 12 <= hour < 17:
            return 0.10
        return 0.0

    if energy_level <= 2:
        if hour >= 17:
            return 0.10
        return 0.05

    return 0.075


def category_time_score(category_value: int, hour: int) -> float:
    if category_value == 0:  # study
        return 0.10 if 8 <= hour < 14 else 0.05

    if category_value == 1:  # coding
        return 0.10 if 8 <= hour < 15 else 0.05

    if category_value == 2:  # work
        return 0.10 if 9 <= hour < 17 else 0.03

    if category_value == 3:  # admin
        return 0.08 if 9 <= hour < 17 else 0.03

    if category_value == 4:  # exercise
        return 0.10 if hour < 10 or hour >= 16 else 0.05

    if category_value == 5:  # errand
        return 0.08 if 9 <= hour < 18 else 0.03

    return 0.06  # personal


def target_score(
    priority: int,
    energy_level: int,
    duration_minutes: int,
    minutes_until_deadline: float,
    start_hour: int,
    slot_duration_minutes: int,
    category_value: int,
) -> float:
    remaining_slot_minutes = slot_duration_minutes - duration_minutes

    if remaining_slot_minutes < 0:
        return 0.0

    score = 0.5
    score += priority_score(priority)
    score += deadline_score(minutes_until_deadline / 60.0)
    score += duration_fit_score(remaining_slot_minutes)
    score += energy_time_score(energy_level, start_hour)
    score += category_time_score(category_value, start_hour)

    return clamp(score)


def generate_row() -> dict:
    priority = random.randint(1, 5)
    energy_level = random.randint(1, 5)

    duration_minutes = random.choice(
        [15, 30, 45, 60, 75, 90, 120, 150, 180]
    )

    slot_duration_minutes = random.choice(
        [30, 45, 60, 90, 120, 150, 180, 240]
    )

    minutes_until_deadline = random.randint(-180, 7 * 24 * 60)
    start_hour = random.randint(6, 22)
    category_value = random.randint(0, 6)

    remaining_slot_minutes = slot_duration_minutes - duration_minutes

    score = target_score(
        priority=priority,
        energy_level=energy_level,
        duration_minutes=duration_minutes,
        minutes_until_deadline=minutes_until_deadline,
        start_hour=start_hour,
        slot_duration_minutes=slot_duration_minutes,
        category_value=category_value,
    )

    return {
        "priority": float(priority),
        "energyLevel": float(energy_level),
        "durationMinutes": float(duration_minutes),
        "minutesUntilDeadline": float(minutes_until_deadline),
        "startHour": float(start_hour),
        "slotDurationMinutes": float(slot_duration_minutes),
        "remainingSlotMinutes": float(remaining_slot_minutes),
        "categoryValue": float(category_value),
        "targetScore": score,

        # Metadata used during training, not Core ML inputs.
        "source": "synthetic",
        "sampleWeight": 0.25,
    }


def main() -> None:
    random.seed(42)

    rows = [generate_row() for _ in range(ROW_COUNT)]

    with OUTPUT_PATH.open("w", newline="") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

    print(f"Generated {len(rows)} synthetic training examples")
    print(f"Saved to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()