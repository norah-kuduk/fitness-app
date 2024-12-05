-- CREATE TYPE completion_status AS ENUM ('Scheduled', 'Completed', 'Missed');

CREATE TABLE IF NOT EXISTS Routine (
  RoutineID INT PRIMARY KEY,
  RoutineName VARCHAR(255) NOT NULL,
  Description TEXT
);

CREATE TABLE IF NOT EXISTS Equipment (
  EquipmentID INT PRIMARY KEY,
  EquipmentName VARCHAR(255) NOT NULL,
  Description TEXT
);

CREATE TABLE IF NOT EXISTS Exercise (
  ExerciseID INT PRIMARY KEY,
  ExerciseName VARCHAR(255) NOT NULL,
  Description TEXT
);

CREATE TABLE IF NOT EXISTS RoutineExercise (
  RoutineID INT NOT NULL,
  ExerciseID INT NOT NULL,
  Sets INT,
  Reps INT,
  HoldTime INT,
  Ord INT,
  Notes TEXT,
  FOREIGN KEY (RoutineID) REFERENCES Routine(RoutineID),
  FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);

CREATE TABLE IF NOT EXISTS ScheduledRoutine (
    RoutineID INT NOT NULL,
    ScheduledDate DATE NOT NULL,
    CompletionStatus completion_status DEFAULT 'Scheduled',
    CompletionDateTime TIMESTAMP NULL,
    Notes TEXT,
    FOREIGN KEY (RoutineID) REFERENCES Routine(RoutineID),
    UNIQUE (RoutineID, ScheduledDate) -- Ensures a routine is scheduled only once per day
);
