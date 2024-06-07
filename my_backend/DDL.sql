
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
  Description TEXT,
  EquipmentID INT,
  FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID)
);

CREATE TABLE IF NOT EXISTS RoutineExercise (
  RoutineExerciseID INT PRIMARY KEY,
  RoutineID INT,
  ExerciseID INT,
  Reps INT,
  HoldTime INT,
  Notes TEXT,
  FOREIGN KEY (RoutineID) REFERENCES Routine(RoutineID),
  FOREIGN KEY (ExerciseID) REFERENCES Exercise(ExerciseID)
);

