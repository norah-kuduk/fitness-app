
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
  RoutineID INT,
  ExerciseID INT,
  Sets INT,
  Reps INT,
  HoldTime INT,
  Ord INT,
  Notes TEXT,
  FOREIGN KEY (RoutineID) REFERENCES Routine(RoutineID),
  FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);

