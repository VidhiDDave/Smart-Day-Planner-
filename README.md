 Smart Day Planner

Smart Day Planner is an iOS app I built to help organize tasks around a user's actual free time.

The main idea is that instead of just keeping a normal to-do list, the app looks at your tasks, deadlines, priorities, energy levels, and calendar events and creates a schedule for your day.

I also wanted to experiment with using Core ML for task scheduling, so the app uses a trained model to score different task/time combinations.

Features

- Google Sign-In
- Add, complete, and delete tasks
- Task priorities and deadlines
- Task duration and energy level
- Task categories
- Manual calendar events
- Google Calendar import
- Automatic free-time detection
- AI-generated daily schedules
- Core ML task placement scoring
- Edit/move scheduled tasks
- Calendar and schedule conflict detection
- Supabase database persistence
- Saves generated schedules
- Collects user feedback for future ML training
- Unit and UI tests

How Scheduling Works

The app first looks at calendar events and figures out what parts of the day are free.

It then compares unfinished tasks against those available time slots.

Each possible task placement is scored using a Core ML model based on things like:

- task priority
- task energy level
- task duration
- time until the deadline
- time of day
- available slot length
- remaining time in the slot
- task category

The scheduler uses these scores to choose where tasks should go while still making sure they fit within the available time.

 Machine Learning

The project includes a small ML training pipeline inside the `ML` folder.

I generated synthetic task scheduling examples and used them to train a Random Forest regression model with scikit-learn.

The model is then converted to Core ML using `coremltools` so it can run directly inside the iOS app.

The current model was trained using 30,000 synthetic examples.
The training files are:

```text
ML/
├── generate_training_data.py
├── train_task_placement_model.py
└── requirements.txt

```

I also added a feedback system so the project can eventually train on real user behavior instead of only synthetic data.
For example, if the app schedules a task for 9:00 AM but the user moves it to 7:00 PM, the app stores information about both placements.
Currently the app can store feedback such as:
accepted
completed
moved
skipped

The same features used by the Core ML model are stored with the feedback in Supabase.
The next step would be using enough real feedback to retrain the model and compare it against the original synthetic model.
Schedule Editing
Generated tasks can also be moved manually.
When moving a task, the app checks that:
it does not overlap a calendar event
it does not overlap another scheduled task
it does not go past the task’s deadline
The duration of the task stays the same.
The updated schedule is then saved back to Supabase.
Google Calendar
The app can import today’s events from Google Calendar.
Imported events are treated as unavailable time so the scheduler works around them.
Manual calendar blocks can also be added directly inside the app.

Backend:
I used Supabase for the backend.
It stores:
user profiles
tasks
calendar events
generated schedules
task placement feedback
Supabase Row Level Security is used so users can only access their own data.

Tech Stack
iOS
Swift
SwiftUI
Combine
Core ML
Backend
Supabase
PostgreSQL
Authentication
Google Sign-In
Supabase Auth
Calendar
Google Calendar API
Machine Learning
Python
pandas
NumPy
scikit-learn
coremltools
Testing
Swift Testing
XCTest
XCUITest
Project Structure
```text
Smart-Day-Planner-
│
├── Backend/
│   └── supabase_schema.sql
│
├── ML/
│   ├── generate_training_data.py
│   ├── train_task_placement_model.py
│   └── requirements.txt
│
└── Smart Day Planner/
    │
    ├── Smart Day Planner/
    │   ├── CoreML/
    │   ├── Logic/
    │   ├── Models/
    │   ├── Services/
    │   ├── Store/
    │   ├── Utilities/
    │   ├── ViewModels/
    │   └── Views/
    │
    ├── Smart Day PlannerTests/
    └── Smart Day PlannerUITests/
```
Testing

I added unit tests around the main scheduling logic, including:

- Task placement features
- Available time slot calculations
- Completed task filtering
- Deadline handling
- Making sure tasks fit into available slots
- Preventing scheduled tasks from overlapping
- Chronological schedule ordering

There are also UI tests for basic app launch and authentication screen behavior.

Tests can be run in Xcode with Command + U.

 Running the Project

Clone the repository:

git clone https://github.com/VidhiDDave/Smart-Day-Planner-.git

cd Smart-Day-Planner-

Open the Xcode project inside the Smart Day Planner folder.

The project uses Swift packages for Google Sign-In and Supabase, which Xcode should resolve automatically.

You will need your own Supabase and Google Cloud configuration to use authentication and calendar features.

I keep API keys and other local configuration out of Git.

The Supabase database schema is available here:

Backend/supabase_schema.sql

Training the Model

I used Python 3.12 for the ML environment.

Create a virtual environment:

python3.12 -m venv ML/.venv

source ML/.venv/bin/activate

Install the requirements:

pip install -r ML/requirements.txt

Generate training data:

python ML/generate_training_data.py

Train the model:

python ML/train_task_placement_model.py

The training data and virtual environment are ignored by Git.

Current Status

The main goal of this project was to build out the complete scheduling idea and learn more about iOS development, backend integration, and using an ML model inside an app.

The main functionality is working, including task management, calendar integration, schedule generation, schedule editing, Core ML scoring, persistence, feedback collection, and testing.

I am treating the current version as the GitHub/project version rather than a production release.

 Future Ideas

Some things I would like to add later:

- Train the model using real user feedback
- Compare different ML models
- Multi-day scheduling
- Recurring tasks
- Better personalization based on user habits
- Offline support
- More UI and integration tests
- General UI/UX improvements
- TestFlight testing
- Production setup
- App Store release
