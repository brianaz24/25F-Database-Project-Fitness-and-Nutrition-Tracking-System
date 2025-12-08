CREATE DATABASE IF NOT EXISTS fitness_app;
USE fitness_app;
SET FOREIGN_KEY_CHECKS = 0;
-- -----------------------------------------------------
-- Users
-- -----------------------------------------------------
DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
user_id INT AUTO_INCREMENT PRIMARY KEY,
fname VARCHAR(50) NOT NULL,
mname VARCHAR(50),
lname VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
gender VARCHAR(10),
birth_date DATE,
register_date DATE NOT NULL,
is_active TINYINT(1) DEFAULT 1
);
-- -----------------------------------------------------
-- Coaches
-- -----------------------------------------------------
DROP TABLE IF EXISTS Coaches;
CREATE TABLE Coaches (
coach_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL UNIQUE,
specialization VARCHAR(100),
terminator VARCHAR(50),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- -----------------------------------------------------
-- Dietitians
-- -----------------------------------------------------
DROP TABLE IF EXISTS Dietitians;
CREATE TABLE Dietitians (
dietitian_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL UNIQUE,
license_number VARCHAR(50),
specialization VARCHAR(100),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- -----------------------------------------------------
-- SystemAdministrations
-- -----------------------------------------------------
DROP TABLE IF EXISTS SystemAdministrators;
CREATE TABLE SystemAdministrators (
admin_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL UNIQUE,
can_receive_alerts TINYINT(1) DEFAULT 1,
contact_method VARCHAR(50),
admin_level VARCHAR(50),
permissions VARCHAR(255),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
DROP TABLE IF EXISTS Clients;
CREATE TABLE Clients (
client_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL UNIQUE,
goal VARCHAR(255),
health_notes TEXT,
height_cm DECIMAL(5,2),
weight_kg DECIMAL(5,2),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- -----------------------------------------------------
-- Goals
-- -----------------------------------------------------
DROP TABLE IF EXISTS Goals;
CREATE TABLE Goals (
goal_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
goal_type VARCHAR(50) NOT NULL,
start_time DATE NOT NULL,
end_time DATE,
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- -----------------------------------------------------
-- MetricLogs
-- -----------------------------------------------------
DROP TABLE IF EXISTS MetricLogs;
CREATE TABLE MetricLogs (
metriclog_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
date_time DATETIME NOT NULL,
weight_kg DECIMAL(5,2),
body_fat_pct DECIMAL(5,2),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- -----------------------------------------------------
-- Foods
-- -----------------------------------------------------
DROP TABLE IF EXISTS Foods;
CREATE TABLE Foods (
food_id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
kcal_per_unit INT NOT NULL,
protein_g DECIMAL(6,2),
carbs_g DECIMAL(6,2),
fat_g DECIMAL(6,2),
unit VARCHAR(20) NOT NULL
);
-- -----------------------------------------------------
-- MealLogs
-- -----------------------------------------------------
DROP TABLE IF EXISTS MealLogs;
CREATE TABLE MealLogs (
meal_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
meal_date DATE NOT NULL,
meal_type VARCHAR(20) NOT NULL,
notes TEXT,
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- -----------------------------------------------------
-- MealItems
-- -----------------------------------------------------
DROP TABLE IF EXISTS MealItems;
CREATE TABLE MealItems (
meal_id INT NOT NULL,
item_num INT NOT NULL,
food_id INT NOT NULL,
quantity DECIMAL(8,2) NOT NULL,
unit VARCHAR(20) NOT NULL,
PRIMARY KEY (meal_id, item_num),
FOREIGN KEY (meal_id) REFERENCES MealLogs(meal_id),
FOREIGN KEY (food_id) REFERENCES Foods(food_id)
);

-- -----------------------------------------------------
-- Meals
-- -----------------------------------------------------
DROP TABLE IF EXISTS Meals;
CREATE TABLE IF NOT EXISTS Meals (
    Meal_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NOT NULL,
    Meal_Name VARCHAR(255) NOT NULL,
    Calories INT NOT NULL,
    Meal_Date DATE,
    Meal_Time TIME,
    Notes TEXT,
    FOREIGN KEY (User_ID) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Meal Commments
-- -----------------------------------------------------
DROP TABLE IF EXISTS Meal_Comments;
CREATE TABLE IF NOT EXISTS Meal_Comments (
    Comment_ID INT AUTO_INCREMENT PRIMARY KEY,
    Meal_ID INT NOT NULL,
    Dietitian_ID INT NOT NULL,
    Comment_Text TEXT NOT NULL,
    Comment_Date DATE,
    FOREIGN KEY (Meal_ID) REFERENCES Meals(Meal_ID) ON DELETE CASCADE,
    FOREIGN KEY (Dietitian_ID) REFERENCES Dietitians(dietitian_id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Workouts
-- -----------------------------------------------------
DROP TABLE IF EXISTS Workouts;
CREATE TABLE IF NOT EXISTS Workouts (
    Workout_ID INT AUTO_INCREMENT PRIMARY KEY,
    User_ID INT NOT NULL,
    Workout_Date DATE NOT NULL,
    Workout_Type VARCHAR(100),
    Duration_Minutes INT,
    Calories_Burned INT,
    Notes TEXT,
    FOREIGN KEY (User_ID) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Nutrients
-- -----------------------------------------------------
DROP TABLE IF EXISTS Nutrients;
CREATE TABLE Nutrients (
meal_id INT PRIMARY KEY,
calories INT,
protein_grams DECIMAL(8,2),
carbs_grams DECIMAL(8,2),
fat_grams DECIMAL(8,2),
FOREIGN KEY (meal_id) REFERENCES MealLogs(meal_id)
);
-- -----------------------------------------------------
-- Plans
-- -----------------------------------------------------
DROP TABLE IF EXISTS Exercises;
CREATE TABLE Exercises (
exercise_id INT AUTO_INCREMENT PRIMARY KEY,
exercise_name VARCHAR(100) NOT NULL,
exercise_type VARCHAR(50),
video_url TEXT
);
-- -----------------------------------------------------
-- WorkoutPlans
-- -----------------------------------------------------
DROP TABLE IF EXISTS WorkoutPlans;
CREATE TABLE WorkoutPlans (
plan_id INT AUTO_INCREMENT PRIMARY KEY,
coach_id INT NOT NULL,
client_id INT NOT NULL,
plan_name VARCHAR(100) NOT NULL,
created_at DATETIME NOT NULL,
description TEXT,
FOREIGN KEY (coach_id) REFERENCES Coaches(coach_id),
FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);
-- -----------------------------------------------------
-- PlanExercises
-- -----------------------------------------------------
DROP TABLE IF EXISTS PlanExercises;
CREATE TABLE PlanExercises (
plan_id INT NOT NULL,
exercise_id INT NOT NULL,
day_of_week VARCHAR(10),
num_sets INT,
num_reps INT,
rest_seconds INT,
PRIMARY KEY (plan_id, exercise_id),
FOREIGN KEY (plan_id) REFERENCES WorkoutPlans(plan_id),
FOREIGN KEY (exercise_id) REFERENCES Exercises(exercise_id)
);
-- -----------------------------------------------------
-- WorkoutLogs
-- -----------------------------------------------------
DROP TABLE IF EXISTS WorkoutLogs;
CREATE TABLE WorkoutLogs (
log_id INT AUTO_INCREMENT PRIMARY KEY,
client_id INT NOT NULL,
plan_id INT,
log_date DATE NOT NULL,
complete_date DATE,
notes TEXT,
FOREIGN KEY (client_id) REFERENCES Clients(client_id),
FOREIGN KEY (plan_id) REFERENCES WorkoutPlans(plan_id)
);
-- -----------------------------------------------------
-- CalorieLogs
-- -----------------------------------------------------
DROP TABLE IF EXISTS CalorieLogs;
CREATE TABLE CalorieLogs (
cal_log_id INT AUTO_INCREMENT PRIMARY KEY,
client_id INT NOT NULL,
cal_log_date DATE NOT NULL,
num_cal INT,
meal_name VARCHAR(100),
FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);
-- -----------------------------------------------------
-- Comments
-- -----------------------------------------------------
DROP TABLE IF EXISTS Comments;
CREATE TABLE Comments (
comment_id INT AUTO_INCREMENT PRIMARY KEY,
dietitian_id INT NOT NULL,
meal_id INT NOT NULL,
comment_time DATETIME NOT NULL,
comment_text TEXT,
comment_type VARCHAR(50),
FOREIGN KEY (dietitian_id) REFERENCES Dietitians(dietitian_id),
FOREIGN KEY (meal_id) REFERENCES MealLogs(meal_id)
);
-- -----------------------------------------------------
-- Notifications
-- -----------------------------------------------------
DROP TABLE IF EXISTS Notifications;
CREATE TABLE Notifications (
notif_id INT AUTO_INCREMENT PRIMARY KEY,
coach_id INT NOT NULL,
client_id INT NOT NULL,
sent_date DATETIME NOT NULL,
notif_type VARCHAR(50),
body_text TEXT,
FOREIGN KEY (coach_id) REFERENCES Coaches(coach_id),
FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);
-- -----------------------------------------------------
-- Systemalerts
-- -----------------------------------------------------
DROP TABLE IF EXISTS SystemAlerts;
CREATE TABLE SystemAlerts (
alert_id INT AUTO_INCREMENT PRIMARY KEY,
admin_id INT NOT NULL,
severity_level VARCHAR(20),
notification_type VARCHAR(50),
notification_time DATETIME NOT NULL,
message TEXT,
FOREIGN KEY (admin_id) REFERENCES SystemAdministrators(admin_id)
);
-- -----------------------------------------------------
-- BackupRecords
-- -----------------------------------------------------
DROP TABLE IF EXISTS BackupRecords;
CREATE TABLE BackupRecords (
backup_id INT AUTO_INCREMENT PRIMARY KEY,
admin_id INT NOT NULL,
backup_time DATETIME NOT NULL,
backup_type VARCHAR(20),
status VARCHAR(20),
FOREIGN KEY (admin_id) REFERENCES SystemAdministrators(admin_id)
);
-- -----------------------------------------------------
-- AuditLog
-- -----------------------------------------------------
DROP TABLE IF EXISTS AuditLog;
CREATE TABLE AuditLog (
log_id INT AUTO_INCREMENT PRIMARY KEY,
admin_id INT NOT NULL,
table_name VARCHAR(100),
action_type VARCHAR(20),
change_date DATETIME NOT NULL,
old_value TEXT,
new_value TEXT,
FOREIGN KEY (admin_id) REFERENCES SystemAdministrators(admin_id)
);
SET FOREIGN_KEY_CHECKS = 1;
