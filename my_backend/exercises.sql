CREATE TABLE IF NOT EXISTS Exercise (
    ExerciseID SERIAL PRIMARY KEY,
    ExerciseName VARCHAR(255) NOT NULL,
    Description TEXT
);
DELETE FROM Exercise;
INSERT INTO Exercise (exercisename, description)
VALUES
    ('Squats', NULL),
    ('Lunges', NULL),
    ('Plank', NULL),
    ('Bridge', 'Lift your hips off the ground while lying on your back'),
    ('Shoulder Press', 'Lift weights overhead while seated or standing'),
    ('Bicep Curls', 'Curl weights towards your shoulders'),
    ('Tricep Dips', 'Lower and raise your body using a bench or chair'),
    ('Leg Press', 'Push weights away with your legs while seated'),
    ('Calf Raises', 'Stand on your toes and then lower your heels'),
    ('Hamstring Curls', 'Bend your knees and bring your heels towards your buttocks'),
    ('Hip Abduction', 'Move your legs away from your body while lying on your side'),
    ('Hip Adduction', 'Move your legs towards your body while lying on your side'),
    ('Step-ups', 'Step onto a platform with one foot and then step down'),
    ('Seated Row', 'Pull weights towards your body while seated'),
    ('Lat Pulldown', 'Pull weights towards your chest while seated');

