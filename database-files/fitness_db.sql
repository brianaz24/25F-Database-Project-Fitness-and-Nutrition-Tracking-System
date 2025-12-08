CREATE DATABASE IF NOT EXISTS fitness_app;
USE fitness_app;
SET FOREIGN_KEY_CHECKS = 0;
-----------------------------------------------------
-- Users
-----------------------------------------------------
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
-----------------------------------------------------
-- Coaches
-----------------------------------------------------
DROP TABLE IF EXISTS Coaches;
CREATE TABLE Coaches (
coach_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL UNIQUE,
specialization VARCHAR(100),
terminator VARCHAR(50),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-----------------------------------------------------
-- Dietitians
-----------------------------------------------------
DROP TABLE IF EXISTS Dietitians;
CREATE TABLE Dietitians (
dietitian_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL UNIQUE,
license_number VARCHAR(50),
specialization VARCHAR(100),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-----------------------------------------------------
-- SystemAdministrations
-----------------------------------------------------
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
-----------------------------------------------------
-- Goals
-----------------------------------------------------
DROP TABLE IF EXISTS Goals;
CREATE TABLE Goals (
goal_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
goal_type VARCHAR(50) NOT NULL,
start_time DATE NOT NULL,
end_time DATE,
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-----------------------------------------------------
-- Workouts
-----------------------------------------------------
DROP TABLE IF EXISTS Workouts;
CREATE TABLE Workouts (
workout_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
date_time DATETIME NOT NULL,
duration_min INT,
intensity VARCHAR(20),
kcal_burned INT,
notes TEXT,
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-----------------------------------------------------
-- MetricLogs
-----------------------------------------------------
DROP TABLE IF EXISTS MetricLogs;
CREATE TABLE MetricLogs (
metriclog_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
date_time DATETIME NOT NULL,
weight_kg DECIMAL(5,2),
body_fat_pct DECIMAL(5,2),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-----------------------------------------------------
-- Foods
-----------------------------------------------------
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
-----------------------------------------------------
-- MealLogs
-----------------------------------------------------
DROP TABLE IF EXISTS MealLogs;
CREATE TABLE MealLogs (
meal_id INT AUTO_INCREMENT PRIMARY KEY,
user_id INT NOT NULL,
meal_date DATE NOT NULL,
meal_type VARCHAR(20) NOT NULL,
notes TEXT,
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-----------------------------------------------------
-- MealItems
-----------------------------------------------------
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
-----------------------------------------------------
-- Nutrients
-----------------------------------------------------
DROP TABLE IF EXISTS Nutrients;
CREATE TABLE Nutrients (
meal_id INT PRIMARY KEY,
calories INT,
protein_grams DECIMAL(8,2),
carbs_grams DECIMAL(8,2),
fat_grams DECIMAL(8,2),
FOREIGN KEY (meal_id) REFERENCES MealLogs(meal_id)
);
-----------------------------------------------------
-- Plans
-----------------------------------------------------
DROP TABLE IF EXISTS Exercises;
CREATE TABLE Exercises (
exercise_id INT AUTO_INCREMENT PRIMARY KEY,
exercise_name VARCHAR(100) NOT NULL,
exercise_type VARCHAR(50),
video_url VARCHAR(255)
);
-----------------------------------------------------
-- WorkoutPlans
-----------------------------------------------------
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
-----------------------------------------------------
-- PlanExercises
-----------------------------------------------------
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
-----------------------------------------------------
-- WorkoutLogs
-----------------------------------------------------
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
-----------------------------------------------------
-- CalorieLogs
-----------------------------------------------------
DROP TABLE IF EXISTS CalorieLogs;
CREATE TABLE CalorieLogs (
cal_log_id INT AUTO_INCREMENT PRIMARY KEY,
client_id INT NOT NULL,
cal_log_date DATE NOT NULL,
num_cal INT,
meal_name VARCHAR(100),
FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);
-----------------------------------------------------
-- Comments
-----------------------------------------------------
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
-----------------------------------------------------
-- Notifications
-----------------------------------------------------
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
-----------------------------------------------------
-- Systemalerts
-----------------------------------------------------
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
-----------------------------------------------------
-- BackupRecords
-----------------------------------------------------
DROP TABLE IF EXISTS BackupRecords;
CREATE TABLE BackupRecords (
backup_id INT AUTO_INCREMENT PRIMARY KEY,
admin_id INT NOT NULL,
backup_time DATETIME NOT NULL,
backup_type VARCHAR(20),
status VARCHAR(20),
FOREIGN KEY (admin_id) REFERENCES SystemAdministrators(admin_id)
);
-----------------------------------------------------
-- AuditLog
-----------------------------------------------------
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

-----------------------------------------------------
-- Insert Sample Data
-----------------------------------------------------

insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Hastie', 'Sr', 'Lammerding', 'hlammerding0@engadget.com', 'M', '10/2/2025', '11/28/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Tracie', 'II', 'Artindale', 'tartindale1@about.me', 'M', '1/9/2025', '4/2/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Guillema', null, 'Morando', 'gmorando2@marriott.com', 'F', '5/19/2025', '7/26/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jacenta', 'Jr', 'Atlay', 'jatlay3@ameblo.jp', 'F', '3/16/2025', '11/11/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Aridatha', null, 'Raiston', 'araiston4@spotify.com', 'F', '6/14/2025', '9/20/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jase', 'III', 'Thyng', 'jthyng5@buzzfeed.com', 'M', '10/19/2025', '3/7/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Cammy', null, 'Mucklow', 'cmucklow6@squarespace.com', 'M', '12/27/2024', '6/27/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Terrence', null, 'Potebury', 'tpotebury7@craigslist.org', 'M', '1/8/2025', '12/24/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Ginevra', 'IV', 'Dominicacci', 'gdominicacci8@japanpost.jp', 'F', '2/20/2025', '1/3/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Carrol', null, 'Tutchings', 'ctutchings9@pbs.org', 'M', '2/23/2025', '4/23/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Hagan', null, 'Overlow', 'hoverlowa@alibaba.com', 'M', '12/25/2024', '8/5/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jessy', 'Sr', 'Mulheron', 'jmulheronb@springer.com', 'F', '4/3/2025', '9/5/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Alene', 'Jr', 'Tukely', 'atukelyc@addtoany.com', 'F', '12/16/2024', '4/16/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Minnie', 'II', 'Fludgate', 'mfludgated@samsung.com', 'F', '7/25/2025', '6/17/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Codie', 'II', 'Guinn', 'cguinne@freewebs.com', 'M', '7/13/2025', '1/21/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Pattie', null, 'Boscher', 'pboscherf@amazon.com', 'M', '4/5/2025', '4/19/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Frasier', 'Sr', 'Lechmere', 'flechmereg@economist.com', 'M', '4/25/2025', '2/14/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jeramey', null, 'Adhams', 'jadhamsh@squidoo.com', 'M', '8/21/2025', '2/3/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Verge', null, 'Bartaloni', 'vbartalonii@umich.edu', 'M', '3/30/2025', '1/17/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Theodora', null, 'Candlin', 'tcandlinj@usgs.gov', 'F', '10/23/2025', '10/16/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Yves', null, 'Notley', 'ynotleyk@yahoo.co.jp', 'M', '10/2/2025', '5/7/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Brock', null, 'Utting', 'buttingl@163.com', 'M', '11/21/2025', '12/12/2024', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Dniren', 'II', 'Brand', 'dbrandm@youku.com', 'F', '12/15/2024', '8/29/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Robby', null, 'Lethcoe', 'rlethcoen@bing.com', 'F', '6/24/2025', '8/14/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Carree', 'III', 'Swate', 'cswateo@google.ru', 'F', '11/20/2025', '11/12/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Garrick', 'Sr', 'Sparrowhawk', 'gsparrowhawkp@linkedin.com', 'M', '1/16/2025', '3/20/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Kristal', 'II', 'Sybbe', 'ksybbeq@geocities.jp', 'F', '10/31/2025', '2/28/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Astrix', 'Jr', 'Spittles', 'aspittlesr@discovery.com', 'F', '11/15/2025', '1/16/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Maiga', null, 'Mapledoram', 'mmapledorams@cbslocal.com', 'F', '10/27/2025', '11/22/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Raviv', null, 'Errichi', 'rerrichit@taobao.com', 'M', '11/28/2025', '5/8/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Albert', null, 'Twyford', 'atwyfordu@squidoo.com', 'M', '12/6/2024', '2/16/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Beatrice', 'III', 'Hasted', 'bhastedv@auda.org.au', 'F', '4/15/2025', '12/16/2024', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Janka', null, 'Syversen', 'jsyversenw@whitehouse.gov', 'F', '10/19/2025', '12/6/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Aurie', 'IV', 'Gilbey', 'agilbeyx@cisco.com', 'F', '1/11/2025', '8/30/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Antonino', 'Sr', 'Athey', 'aatheyy@noaa.gov', 'M', '9/15/2025', '1/9/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Walther', 'II', 'Doblin', 'wdoblinz@ihg.com', 'M', '2/8/2025', '1/9/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Chet', null, 'Wakeman', 'cwakeman10@yolasite.com', 'M', '1/29/2025', '8/19/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Vannie', 'Sr', 'Dillicate', 'vdillicate11@irs.gov', 'F', '8/4/2025', '2/14/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Hallie', 'III', 'Johannes', 'hjohannes12@epa.gov', 'F', '3/31/2025', '3/11/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Nikolos', null, 'Climar', 'nclimar13@marriott.com', 'M', '2/4/2025', '9/25/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Eddie', null, 'Sandal', 'esandal14@about.com', 'F', '12/12/2024', '1/3/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Noami', null, 'Gillino', 'ngillino15@uol.com.br', 'F', '3/19/2025', '12/15/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Henrietta', 'Jr', 'Shippey', 'hshippey16@arizona.edu', 'F', '10/16/2025', '2/5/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Stefan', null, 'Petschel', 'spetschel17@miitbeian.gov.cn', 'M', '12/22/2024', '8/9/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Konstantine', null, 'Legerton', 'klegerton18@nasa.gov', 'M', '12/11/2024', '2/12/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Viola', 'Sr', 'Fenby', 'vfenby19@house.gov', 'F', '11/27/2025', '5/23/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Joline', null, 'Calderwood', 'jcalderwood1a@dailymotion.com', 'F', '6/13/2025', '2/2/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Fayina', 'II', 'Simonson', 'fsimonson1b@netvibes.com', 'F', '5/14/2025', '12/26/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Stinky', null, 'Guenther', 'sguenther1c@flavors.me', 'M', '5/24/2025', '3/28/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Terra', 'Sr', 'Endicott', 'tendicott1d@jalbum.net', 'F', '4/23/2025', '10/26/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Gilles', null, 'Sulter', 'gsulter1e@forbes.com', 'M', '7/23/2025', '8/15/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Myrwyn', null, 'Boagey', 'mboagey1f@tiny.cc', 'M', '1/24/2025', '12/1/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Regan', 'III', 'McCart', 'rmccart1g@phpbb.com', 'F', '2/7/2025', '12/1/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Selma', 'IV', 'Dyment', 'sdyment1h@walmart.com', 'F', '9/28/2025', '2/15/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Osbourne', null, 'Di Francesco', 'odifrancesco1i@amazonaws.com', 'M', '6/28/2025', '5/27/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Hollyanne', null, 'Woodard', 'hwoodard1j@bloomberg.com', 'F', '8/14/2025', '5/6/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Whitaker', null, 'Shaddick', 'wshaddick1k@fastcompany.com', 'M', '9/18/2025', '8/5/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Isaac', 'Sr', 'Drife', 'idrife1l@home.pl', 'M', '5/22/2025', '7/5/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Glenna', 'Sr', 'Vernazza', 'gvernazza1m@ebay.com', 'F', '2/10/2025', '6/17/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Brose', 'IV', 'Spaight', 'bspaight1n@usatoday.com', 'M', '6/4/2025', '1/2/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jaquith', null, 'Odo', 'jodo1o@cdbaby.com', 'F', '5/4/2025', '8/19/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Taylor', null, 'Baggelley', 'tbaggelley1p@opensource.org', 'M', '11/23/2025', '5/11/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Harv', null, 'Djokic', 'hdjokic1q@dyndns.org', 'M', '1/4/2025', '6/25/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jo', 'III', 'Uglow', 'juglow1r@sourceforge.net', 'M', '10/22/2025', '8/28/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Hewitt', null, 'Massen', 'hmassen1s@prweb.com', 'M', '9/14/2025', '11/30/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Yolanda', 'IV', 'Buesnel', 'ybuesnel1t@twitter.com', 'F', '8/29/2025', '10/21/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Galvan', 'II', 'Treasure', 'gtreasure1u@ifeng.com', 'M', '8/20/2025', '2/27/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Charley', 'IV', 'Capoun', 'ccapoun1v@shutterfly.com', 'M', '3/22/2025', '1/12/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Farica', 'II', 'Mitchelson', 'fmitchelson1w@illinois.edu', 'F', '1/18/2025', '4/27/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Addie', null, 'Cheshire', 'acheshire1x@bbc.co.uk', 'M', '2/24/2025', '8/15/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Caresse', null, 'Lay', 'clay1y@latimes.com', 'F', '7/8/2025', '9/14/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Ozzy', 'Jr', 'Harrad', 'oharrad1z@independent.co.uk', 'M', '12/28/2024', '6/13/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Kaylee', null, 'Cobb', 'kcobb20@chron.com', 'F', '6/9/2025', '12/9/2024', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Paxon', 'Jr', 'Billanie', 'pbillanie21@w3.org', 'M', '3/22/2025', '8/6/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Bethina', null, 'Paddison', 'bpaddison22@bravesites.com', 'F', '10/6/2025', '3/12/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Susanna', 'Jr', 'Otton', 'sotton23@nasa.gov', 'F', '2/24/2025', '2/28/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Sonny', null, 'Chalkly', 'schalkly24@constantcontact.com', 'F', '5/14/2025', '5/3/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Madelle', null, 'Torresi', 'mtorresi25@yelp.com', 'F', '7/7/2025', '5/8/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Ethel', 'Jr', 'Gillbee', 'egillbee26@twitter.com', 'F', '1/2/2025', '4/24/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Bengt', 'Sr', 'Story', 'bstory27@skyrock.com', 'M', '10/25/2025', '11/8/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Paxon', 'IV', 'Gerckens', 'pgerckens28@ihg.com', 'M', '8/10/2025', '2/3/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Regine', 'III', 'Riggulsford', 'rriggulsford29@topsy.com', 'F', '12/28/2024', '8/9/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Chris', 'III', 'Blaisdale', 'cblaisdale2a@technorati.com', 'F', '4/23/2025', '10/2/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Ambrosi', 'Sr', 'Stokey', 'astokey2b@photobucket.com', 'M', '10/8/2025', '9/20/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Gareth', null, 'Jirick', 'gjirick2c@scientificamerican.com', 'M', '6/26/2025', '5/30/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Sunny', 'II', 'Leckenby', 'sleckenby2d@ovh.net', 'F', '10/30/2025', '2/4/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Edvard', null, 'Gear', 'egear2e@ted.com', 'M', '11/9/2025', '11/20/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Maurizio', null, 'Gildersleeve', 'mgildersleeve2f@istockphoto.com', 'M', '4/10/2025', '10/24/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Bradford', null, 'Tupp', 'btupp2g@who.int', 'M', '2/5/2025', '3/1/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lyn', 'IV', 'Timpany', 'ltimpany2h@slideshare.net', 'F', '4/7/2025', '4/6/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Arlyne', null, 'Airey', 'aairey2i@whitehouse.gov', 'F', '4/26/2025', '3/11/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Raleigh', null, 'Knagges', 'rknagges2j@umich.edu', 'M', '3/23/2025', '3/24/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Guthrey', 'Jr', 'Damrell', 'gdamrell2k@illinois.edu', 'M', '6/26/2025', '2/26/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Neill', 'II', 'Pinnijar', 'npinnijar2l@51.la', 'M', '11/12/2025', '8/28/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Cherianne', 'IV', 'Eymer', 'ceymer2m@icq.com', 'F', '4/15/2025', '4/22/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Arabele', 'Sr', 'Douche', 'adouche2n@craigslist.org', 'F', '12/31/2024', '10/15/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lisette', 'Jr', 'Gaitley', 'lgaitley2o@ibm.com', 'F', '4/29/2025', '2/28/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Teodoro', 'Jr', 'Vasechkin', 'tvasechkin2p@rambler.ru', 'M', '7/18/2025', '12/25/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Zsazsa', null, 'Silvers', 'zsilvers2q@cafepress.com', 'F', '11/22/2025', '11/22/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Stefano', 'II', 'Barnewall', 'sbarnewall2r@sitemeter.com', 'M', '2/16/2025', '1/11/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Tyrus', null, 'Holah', 'tholah2s@cyberchimps.com', 'M', '8/27/2025', '10/6/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Ives', null, 'Langer', 'ilanger2t@acquirethisname.com', 'M', '1/6/2025', '1/24/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Allyn', 'II', 'Childs', 'achilds2u@springer.com', 'M', '4/23/2025', '9/7/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Fergus', 'Jr', 'Trimble', 'ftrimble2v@telegraph.co.uk', 'M', '8/28/2025', '4/7/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Billy', null, 'Saltrese', 'bsaltrese2w@elegantthemes.com', 'F', '7/29/2025', '6/20/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Massimo', 'Sr', 'Alexander', 'malexander2x@is.gd', 'M', '6/1/2025', '8/18/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Derek', null, 'Della', 'ddella2y@goo.ne.jp', 'M', '10/8/2025', '6/3/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Ania', null, 'Stonall', 'astonall2z@harvard.edu', 'F', '1/29/2025', '4/22/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Erek', null, 'Hurdman', 'ehurdman30@google.de', 'M', '4/15/2025', '12/2/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Rudd', null, 'Waltering', 'rwaltering31@livejournal.com', 'M', '4/25/2025', '7/31/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Anthiathia', 'Jr', 'Putnam', 'aputnam32@bbc.co.uk', 'F', '7/30/2025', '9/25/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Gaby', 'II', 'Crossley', 'gcrossley33@cbc.ca', 'F', '3/11/2025', '9/17/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Peg', 'Jr', 'Hubbart', 'phubbart34@cargocollective.com', 'F', '12/5/2025', '10/10/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Engelbert', 'IV', 'Hector', 'ehector35@amazonaws.com', 'M', '6/17/2025', '12/31/2024', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lorry', 'IV', 'Varian', 'lvarian36@spiegel.de', 'M', '9/12/2025', '11/27/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Valenka', null, 'Kendrick', 'vkendrick37@newyorker.com', 'F', '7/25/2025', '4/21/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Collin', null, 'Paunton', 'cpaunton38@mail.ru', 'M', '3/29/2025', '12/15/2024', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jackie', 'Sr', 'Lafflin', 'jlafflin39@tuttocitta.it', 'F', '7/31/2025', '11/29/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Rutger', 'IV', 'Robjents', 'rrobjents3a@elpais.com', 'M', '2/23/2025', '11/26/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jereme', 'Jr', 'Skoyles', 'jskoyles3b@hubpages.com', 'M', '10/27/2025', '9/8/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lea', null, 'Domenc', 'ldomenc3c@irs.gov', 'F', '11/25/2025', '7/4/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Maddie', 'IV', 'Tyrer', 'mtyrer3d@cdc.gov', 'M', '9/7/2025', '2/17/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Laughton', 'III', 'Nairne', 'lnairne3e@blogs.com', 'M', '5/23/2025', '3/25/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Julio', null, 'Verna', 'jverna3f@google.es', 'M', '5/4/2025', '11/26/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lavena', null, 'Kohter', 'lkohter3g@merriam-webster.com', 'F', '9/16/2025', '10/29/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Rockwell', 'III', 'Kiefer', 'rkiefer3h@princeton.edu', 'M', '1/26/2025', '12/19/2024', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Bartholemy', 'IV', 'Tyzack', 'btyzack3i@illinois.edu', 'M', '1/23/2025', '12/24/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Kaitlin', 'Jr', 'Emsley', 'kemsley3j@time.com', 'F', '11/24/2025', '4/18/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lulita', null, 'Isaac', 'lisaac3k@godaddy.com', 'F', '9/13/2025', '6/4/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Pieter', 'Sr', 'Goward', 'pgoward3l@businesswire.com', 'M', '12/22/2024', '3/2/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Jeremie', null, 'Kettlewell', 'jkettlewell3m@adobe.com', 'M', '2/1/2025', '2/22/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Drusy', null, 'Skettles', 'dskettles3n@yahoo.co.jp', 'F', '4/18/2025', '10/20/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Clevie', 'IV', 'Dewfall', 'cdewfall3o@360.cn', 'M', '3/23/2025', '2/7/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Dehlia', null, 'Scurrah', 'dscurrah3p@wunderground.com', 'F', '7/18/2025', '5/31/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Kitty', null, 'Broscombe', 'kbroscombe3q@ucsd.edu', 'F', '2/15/2025', '10/24/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Mahalia', 'III', 'Pottell', 'mpottell3r@blog.com', 'F', '12/15/2024', '9/7/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Raeann', 'III', 'Steane', 'rsteane3s@bravesites.com', 'F', '6/17/2025', '6/30/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Nessi', 'Jr', 'Hambatch', 'nhambatch3t@chron.com', 'F', '9/22/2025', '3/10/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Vicky', 'Sr', 'Detoc', 'vdetoc3u@buzzfeed.com', 'F', '2/17/2025', '9/7/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Cheston', 'IV', 'Tregaskis', 'ctregaskis3v@weather.com', 'M', '6/11/2025', '12/18/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Brandise', 'III', 'Higbin', 'bhigbin3w@squidoo.com', 'F', '1/22/2025', '6/21/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Dinah', 'Jr', 'Tchir', 'dtchir3x@washington.edu', 'F', '8/18/2025', '11/17/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Clywd', 'Jr', 'Ginty', 'cginty3y@typepad.com', 'M', '7/26/2025', '3/24/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Malcolm', null, 'Pittway', 'mpittway3z@ifeng.com', 'M', '4/15/2025', '12/4/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lucinda', 'II', 'Jepperson', 'ljepperson40@qq.com', 'F', '6/8/2025', '9/6/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Hannis', null, 'Wisniewski', 'hwisniewski41@biglobe.ne.jp', 'F', '7/27/2025', '1/9/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Brig', 'Sr', 'Alphonso', 'balphonso42@addthis.com', 'M', '5/20/2025', '9/28/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Rouvin', null, 'Attlee', 'rattlee43@toplist.cz', 'M', '10/13/2025', '12/13/2024', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Fannie', null, 'Cumbridge', 'fcumbridge44@un.org', 'F', '2/1/2025', '2/25/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Florian', 'Sr', 'Frowde', 'ffrowde45@gnu.org', 'M', '2/7/2025', '8/20/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Web', 'IV', 'Mateuszczyk', 'wmateuszczyk46@unesco.org', 'M', '11/25/2025', '5/22/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Lindsy', null, 'Farrand', 'lfarrand47@diigo.com', 'F', '5/30/2025', '2/2/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Shantee', 'III', 'Griffith', 'sgriffith48@oracle.com', 'F', '3/22/2025', '1/6/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Chrisse', 'Sr', 'Paulsen', 'cpaulsen49@gnu.org', 'M', '8/18/2025', '7/26/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Georgena', 'IV', 'Grooby', 'ggrooby4a@businessinsider.com', 'F', '7/5/2025', '1/4/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Stanwood', null, 'Boarleyson', 'sboarleyson4b@mapquest.com', 'M', '9/6/2025', '5/12/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Esra', null, 'Romanski', 'eromanski4c@wunderground.com', 'M', '3/17/2025', '2/4/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Nanny', 'II', 'Slyvester', 'nslyvester4d@buzzfeed.com', 'F', '9/7/2025', '7/24/2025', 0);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Valdemar', null, 'Klas', 'vklas4e@domainmarket.com', 'M', '10/7/2025', '4/14/2025', 1);
insert into Users (fname, mname, lname, email, gender, birth_date, register_date, is_active) values ('Bert', 'IV', 'Gillean', 'bgillean4f@salon.com', 'M', '6/10/2025', '3/24/2025', 0);
insert into Coaches (user_id, specialization, terminator) values (1, 'Youth Fitness', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (2, 'Strength & Conditioning', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (3, null, 'active');
insert into Coaches (user_id, specialization, terminator) values (4, 'Weight Loss', 'active');
insert into Coaches (user_id, specialization, terminator) values (5, 'Strength & Conditioning', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (6, 'Group Fitness', null);
insert into Coaches (user_id, specialization, terminator) values (7, 'Corrective Exercise', 'active');
insert into Coaches (user_id, specialization, terminator) values (8, 'Strength & Conditioning', 'active');
insert into Coaches (user_id, specialization, terminator) values (9, 'Strength & Conditioning', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (10, 'Group Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (11, 'Sports Performance', 'active');
insert into Coaches (user_id, specialization, terminator) values (12, 'Weight Loss', 'active');
insert into Coaches (user_id, specialization, terminator) values (13, 'Sports Performance', 'active');
insert into Coaches (user_id, specialization, terminator) values (14, 'Sports Performance', 'active');
insert into Coaches (user_id, specialization, terminator) values (15, 'Nutrition Coaching', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (16, null, 'inactive');
insert into Coaches (user_id, specialization, terminator) values (17, 'Nutrition Coaching', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (18, 'Nutrition Coaching', 'active');
insert into Coaches (user_id, specialization, terminator) values (19, 'Weight Loss', 'active');
insert into Coaches (user_id, specialization, terminator) values (20, 'Senior Fitness', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (21, null, 'active');
insert into Coaches (user_id, specialization, terminator) values (22, 'Senior Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (23, 'Senior Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (24, 'Youth Fitness', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (25, 'Group Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (26, 'Senior Fitness', null);
insert into Coaches (user_id, specialization, terminator) values (27, 'Sports Performance', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (28, 'Senior Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (29, 'Senior Fitness', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (30, 'Strength & Conditioning', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (31, 'Group Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (32, 'Strength & Conditioning', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (33, 'Senior Fitness', 'active');
insert into Coaches (user_id, specialization, terminator) values (34, 'Group Fitness', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (35, 'Weight Loss', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (36, 'Weight Loss', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (37, 'Nutrition Coaching', 'active');
insert into Coaches (user_id, specialization, terminator) values (38, 'Strength & Conditioning', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (39, 'Weight Loss', 'inactive');
insert into Coaches (user_id, specialization, terminator) values (40, 'Nutrition Coaching', 'inactive');
insert into Dietitians (user_id, license_number, specialization) values (41, 'SM-13-DYH-928', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (42, 'SP-93-WIQ-560', 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (43, 'PA-35-LCH-284', 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (44, 'FL-88-QJN-012', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (45, 'GG-71-GFB-641', 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (46, null, 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (47, 'LH-51-VYI-838', 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (48, 'ME-96-VLM-627', 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (49, 'AQ-03-IPY-029', 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (50, 'KU-73-BCM-447', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (51, 'UO-86-GQH-818', 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (52, 'IW-09-NIR-201', 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (53, 'PE-66-EDM-323', 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (54, null, 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (55, 'VR-66-SXG-773', 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (56, null, 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (57, 'LD-02-ETM-432', 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (58, 'CM-76-SWP-096', 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (59, 'BG-12-SWW-353', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (60, 'ZU-89-EWU-463', 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (61, null, 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (62, 'CP-43-VED-673', null);
insert into Dietitians (user_id, license_number, specialization) values (63, 'JH-44-YGT-873', 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (64, 'IU-58-HKZ-554', null);
insert into Dietitians (user_id, license_number, specialization) values (65, 'CH-96-JZP-496', 'Sports Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (66, 'MT-50-FSV-012', 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (67, 'YJ-04-TWW-106', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (68, 'YQ-20-NIO-254', 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (69, null, 'Weight Management');
insert into Dietitians (user_id, license_number, specialization) values (70, null, 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (71, 'OT-67-KGQ-384', 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (72, null, 'Gerontological Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (73, 'YJ-42-QWU-469', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (74, 'JH-10-BWO-054', null);
insert into Dietitians (user_id, license_number, specialization) values (75, 'HL-31-NDZ-189', null);
insert into Dietitians (user_id, license_number, specialization) values (76, 'IE-55-DEY-368', null);
insert into Dietitians (user_id, license_number, specialization) values (77, null, 'Clinical Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (78, 'IG-74-FBF-448', null);
insert into Dietitians (user_id, license_number, specialization) values (79, 'BB-22-ZQT-518', 'Pediatric Nutrition');
insert into Dietitians (user_id, license_number, specialization) values (80, 'KC-88-NUX-662', 'Sports Nutrition');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (81, 1, '(988) 7215233', 'admin', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (82, 0, '(339) 8300175', 'admin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (83, 1, '(471) 1424441', 'superadmin', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (84, 0, '(354) 1162852', 'superadmin', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (85, 1, '(874) 7075294', 'moderator', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (86, 0, '(782) 7913819', 'admin', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (87, 1, null, 'staff', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (88, 0, '(922) 4262118', 'admin', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (89, 0, '(902) 6681683', 'staff', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (90, 1, '(755) 5973088', 'admin', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (91, 1, '(676) 6744978', 'moderator', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (92, 0, '(709) 8058820', 'user', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (93, 1, '(144) 8811794', 'admin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (94, 0, '(669) 1707008', 'admin', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (95, 0, '(591) 3460970', 'superadmin', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (96, 0, '(854) 7272939', 'superadmin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (97, 1, '(805) 8757171', 'admin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (98, 1, '(739) 5744782', 'admin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (99, 0, '(497) 4658199', 'user', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (100, 0, '(658) 5827205', 'moderator', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (101, 1, '(109) 5476150', 'admin', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (102, 0, '(731) 9793819', 'user', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (103, 0, '(913) 8380764', 'user', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (104, 0, '(935) 9786570', 'superadmin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (105, 0, '(407) 8476520', 'superadmin', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (106, 0, '(191) 8323131', 'admin', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (107, 0, '(762) 5036287', 'superadmin', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (108, 0, '(837) 8836788', 'staff', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (109, 1, '(809) 2733069', 'user', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (110, 1, '(351) 3180812', 'moderator', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (111, 0, '(244) 3448131', 'admin', 'write');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (112, 1, '(369) 9709237', 'user', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (113, 0, '(273) 2499985', 'user', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (114, 1, '(598) 5719322', 'staff', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (115, 1, '(638) 3419260', 'moderator', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (116, 0, '(818) 1055894', 'user', 'read');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (117, 1, '(717) 7061595', 'moderator', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (118, 1, '(535) 4501608', 'superadmin', 'admin');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (119, 1, '(635) 8529848', 'admin', 'execute');
insert into SystemAdministrators (user_id, can_receive_alerts, contact_method, admin_level, permissions) values (120, 1, '(637) 6883258', 'staff', 'write');
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (121, 'attend yoga classes', 'Lactose intolerant', 580.15, 783.24);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (122, null, 'No allergies', 693.45, 93.38);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (123, null, 'Gluten-free diet', 474.81, 865.61);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (124, 'increase muscle mass', 'No allergies', 476.34, 693.49);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (125, 'run a 5k', null, 483.68, 763.16);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (126, null, null, 521.13, 827.62);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (127, 'increase muscle mass', null, 994.59, 624.82);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (128, 'attend yoga classes', null, 638.97, null);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (129, null, null, 138.9, null);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (130, null, 'Peanut allergy', null, 933.22);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (131, null, 'Lactose intolerant', 336.36, 840.07);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (132, null, null, 297.66, 34.74);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (133, 'run a 5k', null, 599.4, 150.75);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (134, 'improve flexibility', null, 796.75, 435.64);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (135, 'increase muscle mass', null, 109.24, 263.62);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (136, 'run a 5k', 'Peanut allergy', 494.85, 366.29);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (137, null, null, null, 187.55);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (138, 'improve flexibility', 'Lactose intolerant', 544.33, 100.74);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (139, 'attend yoga classes', null, 805.93, 313.08);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (140, null, null, 541.72, 470.99);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (141, 'increase muscle mass', null, null, 729.45);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (142, null, null, 698.15, 549.26);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (143, null, null, 252.13, 130.36);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (144, 'increase muscle mass', 'Lactose intolerant', null, 327.52);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (145, 'improve flexibility', null, 303.28, 146.23);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (146, null, null, 886.31, 63.18);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (147, 'improve flexibility', null, null, 634.38);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (148, 'lose 10 pounds', null, 600.02, 529.39);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (149, 'run a 5k', 'No allergies', 323.33, 146.93);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (150, 'lose 10 pounds', 'Peanut allergy', null, 970.65);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (151, 'attend yoga classes', null, 780.3, 506.56);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (152, null, null, 332.87, null);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (153, null, null, null, 642.56);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (154, 'lose 10 pounds', null, 830.71, 909.27);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (155, 'increase muscle mass', null, 714.65, 901.97);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (156, null, null, 548.12, 654.52);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (157, 'improve flexibility', null, 764.54, 874.0);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (158, null, null, 342.08, 244.63);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (159, null, 'Vegan', 185.08, 364.2);
INSERT INTO Clients (user_id, goal, health_notes, height_cm, weight_kg) VALUES (160, null, null, 639.17, null);
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('pizza', 653, 9373.86, 4826.97, 234.43, '37g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('steak', 701, 527.38, 1340.13, 6848.0, '03g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 823, 8712.88, 466.39, null, '988g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('steak', 779, 2749.78, 3210.1, 8274.85, '91g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('steak', 971, null, 4323.61, 9903.26, '17g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 699, 8354.22, 2498.67, 971.97, '796g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sushi', 562, 7433.34, 8311.71, null, '827g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burrito', 681, 8580.42, 4926.07, null, '982g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sandwich', 509, 4088.18, 4942.58, 7942.44, '68g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sandwich', 724, 3135.72, 9261.1, null, '838g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 929, null, 4564.48, 7368.28, '400g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burrito', 1000, null, 9708.81, null, '317g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('steak', 226, 965.59, 125.94, null, '866g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burrito', 644, null, 4383.92, null, '91g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burrito', 737, null, 3301.3, null, '561g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('soup', 415, 383.95, null, 2619.3, '017g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('pizza', 569, 897.72, 6887.93, 1979.87, '95g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 70, 7151.12, 8770.26, null, '72g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burrito', 978, null, 273.03, 6332.69, '38g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burger', 868, 9774.85, 4268.61, 7003.84, '00g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burger', 351, null, 7775.02, 46.7, '994g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('pasta', 607, 5583.34, 5208.01, 4742.33, '866g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burger', 934, 3451.48, null, 5744.76, '20g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sandwich', 743, 1536.32, 880.49, 1251.04, '27g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 154, 6202.68, 5600.16, 6558.84, '855g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sandwich', 843, null, null, 8774.09, '94g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('soup', 702, 3613.09, 157.19, 4668.94, '147g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 92, 9471.29, 5406.71, 408.14, '71g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sandwich', 687, 4096.56, 9024.93, 3563.09, '29g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('pasta', 417, 9231.35, 1289.53, 3977.56, '45g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('pizza', 474, 7659.1, 3143.26, 1286.53, '75g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('burger', 593, 6515.97, 7306.25, null, '188g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('pizza', 152, 4219.7, 3094.53, null, '45g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('salad', 288, null, null, 2445.87, '74g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('soup', 251, 7048.65, null, 1237.21, '60g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('soup', 553, 7406.38, 2107.87, 8337.54, '65g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('steak', 450, 211.76, 933.1, 9552.71, '30g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('soup', 294, 6848.73, 1626.72, 7499.86, '545g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('sandwich', 146, 4682.51, 9621.16, 7488.7, '86g');
insert into Foods (name, kcal_per_unit, protein_g, carbs_g, fat_g, unit) values ('taco', 336, 3755.81, 9481.6, 6462.54, '51g');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'strength', 'https://twitpic.com/vitae/nisi/nam/ultrices/libero.js?id=eget&justo=congue&sit=eget&amet=semper&sapien=rutrum&dignissim=nulla&vestibulum=nunc&vestibulum=purus&ante=phasellus&ipsum=in&primis=felis&in=donec&faucibus=semper&orci=sapien&luctus=a&et=libero&ultrices=nam&posuere=dui&cubilia=proin&curae=leo&nulla=odio&dapibus=porttitor&dolor=id&vel=consequat&est=in&donec=consequat&odio=ut&justo=nulla&sollicitudin=sed&ut=accumsan&suscipit=felis&a=ut&feugiat=at&et=dolor&eros=quis&vestibulum=odio&ac=consequat&est=varius&lacinia=integer&nisi=ac&venenatis=leo&tristique=pellentesque&fusce=ultrices&congue=mattis&diam=odio&id=donec&ornare=vitae&imperdiet=nisi&sapien=nam&urna=ultrices&pretium=libero&nisl=non&ut=mattis&volutpat=pulvinar&sapien=nulla&arcu=pede&sed=ullamcorper&augue=augue&aliquam=a&erat=suscipit&volutpat=nulla&in=elit&congue=ac&etiam=nulla&justo=sed&etiam=vel&pretium=enim&iaculis=sit&justo=amet&in=nunc&hac=viverra&habitasse=dapibus&platea=nulla&dictumst=suscipit&etiam=ligula');
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'strength', 'http://fastcompany.com/lectus/suspendisse/potenti/in/eleifend/quam.xml?justo=penatibus&in=et&hac=magnis&habitasse=dis&platea=parturient&dictumst=montes&etiam=nascetur&faucibus=ridiculus&cursus=mus&urna=vivamus&ut=vestibulum&tellus=sagittis&nulla=sapien&ut=cum&erat=sociis&id=natoque&mauris=penatibus&vulputate=et&elementum=magnis&nullam=dis&varius=parturient&nulla=montes&facilisi=nascetur&cras=ridiculus&non=mus');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'cardio', 'https://gov.uk/tempor/turpis/nec/euismod/scelerisque/quam/turpis.jsp?vulputate=pede&elementum=justo&nullam=eu&varius=massa&nulla=donec&facilisi=dapibus&cras=duis&non=at&velit=velit&nec=eu&nisi=est&vulputate=congue&nonummy=elementum&maecenas=in&tincidunt=hac&lacus=habitasse&at=platea&velit=dictumst&vivamus=morbi&vel=vestibulum&nulla=velit&eget=id&eros=pretium&elementum=iaculis&pellentesque=diam&quisque=erat&porta=fermentum&volutpat=justo&erat=nec&quisque=condimentum&erat=neque&eros=sapien&viverra=placerat&eget=ante&congue=nulla');
insert into Exercises (exercise_name, exercise_type, video_url) values ('weightlifting', 'aerobic', 'http://npr.org/dapibus/at.xml?quis=et');
insert into Exercises (exercise_name, exercise_type, video_url) values ('swimming', 'cardio', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'strength', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('weightlifting', 'aerobic', 'https://youtube.com/blandit/non/interdum/in/ante/vestibulum.html?felis=primis&sed=in&interdum=faucibus&venenatis=orci&turpis=luctus&enim=et&blandit=ultrices&mi=posuere&in=cubilia&porttitor=curae&pede=mauris&justo=viverra&eu=diam&massa=vitae&donec=quam&dapibus=suspendisse&duis=potenti&at=nullam&velit=porttitor&eu=lacus&est=at&congue=turpis&elementum=donec&in=posuere&hac=metus&habitasse=vitae&platea=ipsum&dictumst=aliquam&morbi=non&vestibulum=mauris&velit=morbi&id=non&pretium=lectus&iaculis=aliquam&diam=sit&erat=amet&fermentum=diam&justo=in&nec=magna&condimentum=bibendum&neque=imperdiet&sapien=nullam&placerat=orci&ante=pede&nulla=venenatis&justo=non&aliquam=sodales&quis=sed&turpis=tincidunt&eget=eu&elit=felis&sodales=fusce&scelerisque=posuere&mauris=felis&sit=sed&amet=lacus&eros=morbi&suspendisse=sem&accumsan=mauris&tortor=laoreet&quis=ut&turpis=rhoncus&sed=aliquet&ante=pulvinar&vivamus=sed&tortor=nisl&duis=nunc&mattis=rhoncus&egestas=dui&metus=vel&aenean=sem&fermentum=sed&donec=sagittis&ut=nam&mauris=congue&eget=risus&massa=semper&tempor=porta&convallis=volutpat&nulla=quam&neque=pede&libero=lobortis&convallis=ligula&eget=sit');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'aerobic', 'https://microsoft.com/sit/amet/sapien/dignissim/vestibulum/vestibulum.json?nec=luctus&condimentum=et&neque=ultrices&sapien=posuere&placerat=cubilia&ante=curae&nulla=nulla&justo=dapibus&aliquam=dolor&quis=vel&turpis=est&eget=donec&elit=odio&sodales=justo&scelerisque=sollicitudin&mauris=ut&sit=suscipit&amet=a&eros=feugiat&suspendisse=et&accumsan=eros&tortor=vestibulum&quis=ac&turpis=est&sed=lacinia&ante=nisi&vivamus=venenatis&tortor=tristique&duis=fusce&mattis=congue&egestas=diam&metus=id&aenean=ornare&fermentum=imperdiet&donec=sapien&ut=urna&mauris=pretium&eget=nisl&massa=ut&tempor=volutpat&convallis=sapien&nulla=arcu&neque=sed&libero=augue&convallis=aliquam&eget=erat&eleifend=volutpat&luctus=in&ultricies=congue&eu=etiam&nibh=justo&quisque=etiam&id=pretium&justo=iaculis&sit=justo&amet=in&sapien=hac&dignissim=habitasse&vestibulum=platea&vestibulum=dictumst&ante=etiam&ipsum=faucibus&primis=cursus&in=urna');
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'aerobic', 'http://gizmodo.com/erat/tortor/sollicitudin/mi/sit/amet.jsp?arcu=dis&adipiscing=parturient&molestie=montes&hendrerit=nascetur&at=ridiculus&vulputate=mus&vitae=etiam&nisl=vel&aenean=augue&lectus=vestibulum&pellentesque=rutrum&eget=rutrum&nunc=neque&donec=aenean&quis=auctor&orci=gravida&eget=sem&orci=praesent&vehicula=id&condimentum=massa&curabitur=id&in=nisl&libero=venenatis&ut=lacinia&massa=aenean&volutpat=sit&convallis=amet&morbi=justo&odio=morbi&odio=ut');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'cardio', 'https://mozilla.org/et/magnis.json?vivamus=vestibulum&in=aliquet&felis=ultrices&eu=erat&sapien=tortor&cursus=sollicitudin&vestibulum=mi&proin=sit&eu=amet&mi=lobortis&nulla=sapien&ac=sapien&enim=non&in=mi&tempor=integer&turpis=ac&nec=neque&euismod=duis&scelerisque=bibendum&quam=morbi&turpis=non&adipiscing=quam&lorem=nec&vitae=dui&mattis=luctus&nibh=rutrum&ligula=nulla&nec=tellus&sem=in&duis=sagittis&aliquam=dui&convallis=vel&nunc=nisl&proin=duis&at=ac&turpis=nibh&a=fusce&pede=lacus&posuere=purus&nonummy=aliquet&integer=at&non=feugiat&velit=non&donec=pretium&diam=quis&neque=lectus');
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'aerobic', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'aerobic', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'https://marriott.com/libero.xml?dolor=quam&sit=suspendisse&amet=potenti&consectetuer=nullam&adipiscing=porttitor&elit=lacus&proin=at&interdum=turpis&mauris=donec&non=posuere&ligula=metus&pellentesque=vitae&ultrices=ipsum&phasellus=aliquam&id=non&sapien=mauris&in=morbi&sapien=non&iaculis=lectus&congue=aliquam&vivamus=sit&metus=amet&arcu=diam&adipiscing=in&molestie=magna&hendrerit=bibendum&at=imperdiet&vulputate=nullam&vitae=orci&nisl=pede&aenean=venenatis&lectus=non&pellentesque=sodales&eget=sed&nunc=tincidunt&donec=eu&quis=felis&orci=fusce&eget=posuere&orci=felis&vehicula=sed&condimentum=lacus&curabitur=morbi&in=sem&libero=mauris&ut=laoreet&massa=ut&volutpat=rhoncus&convallis=aliquet&morbi=pulvinar&odio=sed&odio=nisl&elementum=nunc&eu=rhoncus&interdum=dui&eu=vel&tincidunt=sem&in=sed&leo=sagittis&maecenas=nam');
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'cardio', 'https://marketwatch.com/diam/nam/tristique/tortor.png?nunc=etiam&vestibulum=justo&ante=etiam&ipsum=pretium&primis=iaculis&in=justo&faucibus=in&orci=hac&luctus=habitasse&et=platea&ultrices=dictumst&posuere=etiam&cubilia=faucibus&curae=cursus&mauris=urna&viverra=ut&diam=tellus&vitae=nulla&quam=ut&suspendisse=erat&potenti=id&nullam=mauris&porttitor=vulputate&lacus=elementum&at=nullam&turpis=varius&donec=nulla&posuere=facilisi&metus=cras&vitae=non&ipsum=velit&aliquam=nec&non=nisi&mauris=vulputate&morbi=nonummy&non=maecenas&lectus=tincidunt&aliquam=lacus&sit=at&amet=velit&diam=vivamus&in=vel&magna=nulla&bibendum=eget&imperdiet=eros&nullam=elementum&orci=pellentesque&pede=quisque&venenatis=porta&non=volutpat&sodales=erat&sed=quisque&tincidunt=erat&eu=eros&felis=viverra&fusce=eget&posuere=congue&felis=eget&sed=semper&lacus=rutrum&morbi=nulla&sem=nunc&mauris=purus');
insert into Exercises (exercise_name, exercise_type, video_url) values ('swimming', 'strength', 'https://4shared.com/eros/elementum/pellentesque/quisque/porta.jsp?tellus=sed&nulla=interdum&ut=venenatis&erat=turpis&id=enim&mauris=blandit&vulputate=mi&elementum=in&nullam=porttitor&varius=pede&nulla=justo&facilisi=eu&cras=massa&non=donec&velit=dapibus&nec=duis&nisi=at&vulputate=velit&nonummy=eu&maecenas=est&tincidunt=congue&lacus=elementum&at=in&velit=hac&vivamus=habitasse&vel=platea&nulla=dictumst&eget=morbi&eros=vestibulum&elementum=velit&pellentesque=id&quisque=pretium&porta=iaculis&volutpat=diam&erat=erat&quisque=fermentum&erat=justo&eros=nec&viverra=condimentum&eget=neque&congue=sapien&eget=placerat&semper=ante&rutrum=nulla&nulla=justo&nunc=aliquam&purus=quis&phasellus=turpis&in=eget&felis=elit&donec=sodales&semper=scelerisque&sapien=mauris&a=sit&libero=amet&nam=eros&dui=suspendisse&proin=accumsan&leo=tortor&odio=quis&porttitor=turpis&id=sed&consequat=ante&in=vivamus&consequat=tortor&ut=duis&nulla=mattis&sed=egestas&accumsan=metus&felis=aenean&ut=fermentum&at=donec&dolor=ut&quis=mauris&odio=eget&consequat=massa&varius=tempor&integer=convallis&ac=nulla&leo=neque&pellentesque=libero&ultrices=convallis&mattis=eget&odio=eleifend&donec=luctus&vitae=ultricies&nisi=eu&nam=nibh&ultrices=quisque&libero=id&non=justo&mattis=sit&pulvinar=amet&nulla=sapien&pede=dignissim&ullamcorper=vestibulum&augue=vestibulum');
insert into Exercises (exercise_name, exercise_type, video_url) values ('weightlifting', 'strength', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'aerobic', 'https://cnn.com/leo/pellentesque/ultrices/mattis.json?mi=dolor&in=quis&porttitor=odio&pede=consequat&justo=varius&eu=integer&massa=ac&donec=leo&dapibus=pellentesque&duis=ultrices&at=mattis&velit=odio&eu=donec&est=vitae&congue=nisi&elementum=nam&in=ultrices&hac=libero&habitasse=non&platea=mattis&dictumst=pulvinar&morbi=nulla&vestibulum=pede&velit=ullamcorper&id=augue&pretium=a&iaculis=suscipit&diam=nulla&erat=elit&fermentum=ac&justo=nulla&nec=sed&condimentum=vel&neque=enim&sapien=sit&placerat=amet&ante=nunc&nulla=viverra&justo=dapibus&aliquam=nulla&quis=suscipit&turpis=ligula&eget=in');
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'http://mozilla.com/lobortis/est.js?vel=nisi&est=at');
insert into Exercises (exercise_name, exercise_type, video_url) values ('cycling', 'cardio', 'https://slate.com/volutpat/dui/maecenas/tristique.xml?imperdiet=lectus&et=pellentesque&commodo=at&vulputate=nulla&justo=suspendisse&in=potenti&blandit=cras&ultrices=in&enim=purus&lorem=eu&ipsum=magna&dolor=vulputate&sit=luctus&amet=cum&consectetuer=sociis&adipiscing=natoque&elit=penatibus&proin=et&interdum=magnis&mauris=dis&non=parturient&ligula=montes&pellentesque=nascetur&ultrices=ridiculus&phasellus=mus&id=vivamus&sapien=vestibulum&in=sagittis&sapien=sapien&iaculis=cum&congue=sociis&vivamus=natoque&metus=penatibus&arcu=et&adipiscing=magnis&molestie=dis&hendrerit=parturient&at=montes&vulputate=nascetur&vitae=ridiculus&nisl=mus&aenean=etiam&lectus=vel&pellentesque=augue&eget=vestibulum&nunc=rutrum&donec=rutrum&quis=neque&orci=aenean&eget=auctor&orci=gravida&vehicula=sem&condimentum=praesent&curabitur=id&in=massa&libero=id&ut=nisl&massa=venenatis&volutpat=lacinia&convallis=aenean&morbi=sit&odio=amet&odio=justo&elementum=morbi&eu=ut&interdum=odio&eu=cras&tincidunt=mi&in=pede&leo=malesuada&maecenas=in&pulvinar=imperdiet&lobortis=et&est=commodo&phasellus=vulputate&sit=justo&amet=in');
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'cardio', 'https://posterous.com/a/feugiat.xml?iaculis=ac&justo=nibh&in=fusce&hac=lacus&habitasse=purus&platea=aliquet&dictumst=at&etiam=feugiat&faucibus=non&cursus=pretium&urna=quis&ut=lectus&tellus=suspendisse&nulla=potenti&ut=in&erat=eleifend&id=quam&mauris=a&vulputate=odio&elementum=in&nullam=hac&varius=habitasse&nulla=platea&facilisi=dictumst&cras=maecenas&non=ut&velit=massa&nec=quis&nisi=augue&vulputate=luctus&nonummy=tincidunt&maecenas=nulla&tincidunt=mollis&lacus=molestie&at=lorem&velit=quisque&vivamus=ut&vel=erat&nulla=curabitur&eget=gravida&eros=nisi&elementum=at&pellentesque=nibh&quisque=in&porta=hac&volutpat=habitasse&erat=platea&quisque=dictumst&erat=aliquam&eros=augue&viverra=quam&eget=sollicitudin&congue=vitae&eget=consectetuer&semper=eget&rutrum=rutrum&nulla=at&nunc=lorem&purus=integer&phasellus=tincidunt&in=ante&felis=vel&donec=ipsum&semper=praesent&sapien=blandit&a=lacinia&libero=erat&nam=vestibulum&dui=sed&proin=magna&leo=at&odio=nunc&porttitor=commodo&id=placerat&consequat=praesent&in=blandit&consequat=nam&ut=nulla&nulla=integer&sed=pede&accumsan=justo&felis=lacinia&ut=eget&at=tincidunt&dolor=eget&quis=tempus&odio=vel&consequat=pede&varius=morbi&integer=porttitor&ac=lorem');
insert into Exercises (exercise_name, exercise_type, video_url) values ('swimming', 'strength', 'http://livejournal.com/praesent/id/massa/id.js?venenatis=eget&lacinia=tempus&aenean=vel&sit=pede&amet=morbi&justo=porttitor&morbi=lorem&ut=id&odio=ligula&cras=suspendisse&mi=ornare&pede=consequat&malesuada=lectus&in=in&imperdiet=est&et=risus&commodo=auctor&vulputate=sed&justo=tristique&in=in&blandit=tempus&ultrices=sit&enim=amet&lorem=sem&ipsum=fusce&dolor=consequat&sit=nulla&amet=nisl&consectetuer=nunc&adipiscing=nisl&elit=duis&proin=bibendum&interdum=felis&mauris=sed&non=interdum&ligula=venenatis&pellentesque=turpis&ultrices=enim&phasellus=blandit&id=mi&sapien=in&in=porttitor&sapien=pede&iaculis=justo&congue=eu&vivamus=massa&metus=donec&arcu=dapibus&adipiscing=duis&molestie=at&hendrerit=velit&at=eu&vulputate=est&vitae=congue&nisl=elementum&aenean=in&lectus=hac&pellentesque=habitasse&eget=platea&nunc=dictumst&donec=morbi&quis=vestibulum&orci=velit&eget=id&orci=pretium&vehicula=iaculis&condimentum=diam&curabitur=erat&in=fermentum&libero=justo&ut=nec&massa=condimentum&volutpat=neque&convallis=sapien&morbi=placerat&odio=ante&odio=nulla&elementum=justo&eu=aliquam&interdum=quis&eu=turpis&tincidunt=eget&in=elit&leo=sodales&maecenas=scelerisque&pulvinar=mauris&lobortis=sit&est=amet&phasellus=eros&sit=suspendisse&amet=accumsan&erat=tortor&nulla=quis&tempus=turpis&vivamus=sed&in=ante&felis=vivamus&eu=tortor&sapien=duis&cursus=mattis');
insert into Exercises (exercise_name, exercise_type, video_url) values ('swimming', 'aerobic', 'https://weebly.com/in/est/risus/auctor/sed.aspx?quam=integer');
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'http://twitter.com/id/luctus/nec/molestie/sed/justo/pellentesque.json?nulla=aenean&dapibus=auctor&dolor=gravida&vel=sem&est=praesent&donec=id&odio=massa&justo=id&sollicitudin=nisl&ut=venenatis&suscipit=lacinia&a=aenean&feugiat=sit&et=amet&eros=justo&vestibulum=morbi&ac=ut&est=odio&lacinia=cras&nisi=mi&venenatis=pede&tristique=malesuada&fusce=in&congue=imperdiet&diam=et&id=commodo&ornare=vulputate&imperdiet=justo&sapien=in&urna=blandit&pretium=ultrices&nisl=enim&ut=lorem&volutpat=ipsum&sapien=dolor&arcu=sit&sed=amet&augue=consectetuer&aliquam=adipiscing&erat=elit&volutpat=proin&in=interdum&congue=mauris&etiam=non&justo=ligula&etiam=pellentesque&pretium=ultrices&iaculis=phasellus&justo=id&in=sapien&hac=in&habitasse=sapien&platea=iaculis&dictumst=congue&etiam=vivamus');
insert into Exercises (exercise_name, exercise_type, video_url) values ('weightlifting', 'strength', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'http://webeden.co.uk/dis/parturient/montes/nascetur/ridiculus/mus.aspx?sapien=nunc&placerat=proin&ante=at&nulla=turpis&justo=a&aliquam=pede&quis=posuere&turpis=nonummy&eget=integer&elit=non&sodales=velit&scelerisque=donec&mauris=diam&sit=neque&amet=vestibulum&eros=eget&suspendisse=vulputate&accumsan=ut&tortor=ultrices&quis=vel&turpis=augue&sed=vestibulum&ante=ante&vivamus=ipsum&tortor=primis&duis=in&mattis=faucibus&egestas=orci&metus=luctus&aenean=et&fermentum=ultrices&donec=posuere&ut=cubilia&mauris=curae&eget=donec&massa=pharetra&tempor=magna&convallis=vestibulum&nulla=aliquet&neque=ultrices&libero=erat&convallis=tortor&eget=sollicitudin&eleifend=mi&luctus=sit&ultricies=amet&eu=lobortis&nibh=sapien&quisque=sapien&id=non&justo=mi&sit=integer&amet=ac&sapien=neque&dignissim=duis&vestibulum=bibendum&vestibulum=morbi&ante=non&ipsum=quam&primis=nec&in=dui&faucibus=luctus&orci=rutrum&luctus=nulla&et=tellus&ultrices=in&posuere=sagittis&cubilia=dui&curae=vel&nulla=nisl&dapibus=duis&dolor=ac&vel=nibh&est=fusce&donec=lacus&odio=purus&justo=aliquet&sollicitudin=at&ut=feugiat&suscipit=non&a=pretium&feugiat=quis&et=lectus&eros=suspendisse&vestibulum=potenti');
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'strength', 'http://newsvine.com/non/velit.xml?potenti=vestibulum&cras=velit&in=id&purus=pretium&eu=iaculis&magna=diam&vulputate=erat&luctus=fermentum&cum=justo&sociis=nec&natoque=condimentum&penatibus=neque&et=sapien&magnis=placerat&dis=ante&parturient=nulla&montes=justo&nascetur=aliquam&ridiculus=quis&mus=turpis&vivamus=eget&vestibulum=elit&sagittis=sodales&sapien=scelerisque&cum=mauris&sociis=sit&natoque=amet&penatibus=eros');
insert into Exercises (exercise_name, exercise_type, video_url) values ('weightlifting', 'strength', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'aerobic', 'https://pagesperso-orange.fr/libero/non/mattis/pulvinar/nulla.aspx?vestibulum=justo&proin=morbi&eu=ut&mi=odio&nulla=cras&ac=mi&enim=pede&in=malesuada&tempor=in&turpis=imperdiet&nec=et&euismod=commodo&scelerisque=vulputate&quam=justo&turpis=in&adipiscing=blandit&lorem=ultrices&vitae=enim&mattis=lorem&nibh=ipsum&ligula=dolor&nec=sit&sem=amet&duis=consectetuer&aliquam=adipiscing&convallis=elit&nunc=proin&proin=interdum&at=mauris&turpis=non&a=ligula&pede=pellentesque');
insert into Exercises (exercise_name, exercise_type, video_url) values ('weightlifting', null, null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'https://toplist.cz/turpis/enim/blandit/mi/in/porttitor/pede.jpg?diam=eros&erat=vestibulum&fermentum=ac&justo=est&nec=lacinia&condimentum=nisi');
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'https://yahoo.co.jp/nulla/suscipit/ligula/in/lacus/curabitur/at.png?mauris=cubilia&laoreet=curae&ut=duis&rhoncus=faucibus&aliquet=accumsan&pulvinar=odio&sed=curabitur&nisl=convallis&nunc=duis&rhoncus=consequat&dui=dui&vel=nec&sem=nisi&sed=volutpat&sagittis=eleifend&nam=donec&congue=ut&risus=dolor&semper=morbi&porta=vel&volutpat=lectus&quam=in&pede=quam');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', null, null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('yoga', 'strength', 'https://a8.net/luctus/nec/molestie/sed/justo/pellentesque/viverra.png?id=blandit&lobortis=ultrices&convallis=enim&tortor=lorem&risus=ipsum&dapibus=dolor&augue=sit&vel=amet&accumsan=consectetuer&tellus=adipiscing&nisi=elit&eu=proin&orci=interdum&mauris=mauris&lacinia=non&sapien=ligula&quis=pellentesque&libero=ultrices&nullam=phasellus&sit=id&amet=sapien&turpis=in&elementum=sapien&ligula=iaculis&vehicula=congue&consequat=vivamus&morbi=metus&a=arcu&ipsum=adipiscing&integer=molestie&a=hendrerit&nibh=at&in=vulputate&quis=vitae&justo=nisl&maecenas=aenean&rhoncus=lectus&aliquam=pellentesque&lacus=eget&morbi=nunc&quis=donec&tortor=quis&id=orci&nulla=eget&ultrices=orci&aliquet=vehicula&maecenas=condimentum&leo=curabitur&odio=in&condimentum=libero&id=ut&luctus=massa&nec=volutpat&molestie=convallis&sed=morbi&justo=odio&pellentesque=odio&viverra=elementum&pede=eu&ac=interdum&diam=eu&cras=tincidunt&pellentesque=in&volutpat=leo&dui=maecenas&maecenas=pulvinar&tristique=lobortis&est=est&et=phasellus&tempus=sit&semper=amet&est=erat&quam=nulla&pharetra=tempus&magna=vivamus&ac=in&consequat=felis&metus=eu&sapien=sapien&ut=cursus&nunc=vestibulum&vestibulum=proin&ante=eu&ipsum=mi&primis=nulla&in=ac');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'cardio', 'http://bandcamp.com/convallis/nulla/neque/libero/convallis/eget.png?in=ornare&leo=imperdiet&maecenas=sapien&pulvinar=urna&lobortis=pretium&est=nisl&phasellus=ut&sit=volutpat&amet=sapien&erat=arcu&nulla=sed&tempus=augue&vivamus=aliquam&in=erat&felis=volutpat&eu=in&sapien=congue&cursus=etiam&vestibulum=justo&proin=etiam&eu=pretium&mi=iaculis&nulla=justo&ac=in&enim=hac&in=habitasse&tempor=platea&turpis=dictumst&nec=etiam');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'cardio', 'http://webs.com/quam/a/odio/in.png?sed=phasellus&interdum=in&venenatis=felis&turpis=donec&enim=semper&blandit=sapien&mi=a&in=libero&porttitor=nam&pede=dui&justo=proin&eu=leo&massa=odio&donec=porttitor&dapibus=id&duis=consequat&at=in&velit=consequat&eu=ut&est=nulla&congue=sed&elementum=accumsan&in=felis&hac=ut&habitasse=at&platea=dolor&dictumst=quis&morbi=odio&vestibulum=consequat&velit=varius&id=integer&pretium=ac&iaculis=leo&diam=pellentesque&erat=ultrices&fermentum=mattis&justo=odio&nec=donec&condimentum=vitae&neque=nisi&sapien=nam&placerat=ultrices&ante=libero&nulla=non&justo=mattis&aliquam=pulvinar&quis=nulla&turpis=pede&eget=ullamcorper&elit=augue&sodales=a&scelerisque=suscipit&mauris=nulla&sit=elit&amet=ac&eros=nulla&suspendisse=sed&accumsan=vel&tortor=enim&quis=sit&turpis=amet&sed=nunc&ante=viverra&vivamus=dapibus&tortor=nulla&duis=suscipit&mattis=ligula&egestas=in&metus=lacus&aenean=curabitur&fermentum=at&donec=ipsum');
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'aerobic', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('swimming', 'strength', 'https://yahoo.com/et/ultrices.jpg?nisl=volutpat&duis=erat&bibendum=quisque&felis=erat&sed=eros&interdum=viverra&venenatis=eget&turpis=congue&enim=eget&blandit=semper&mi=rutrum&in=nulla&porttitor=nunc&pede=purus&justo=phasellus&eu=in');
insert into Exercises (exercise_name, exercise_type, video_url) values ('running', 'strength', 'https://rambler.ru/lacinia/aenean/sit/amet/justo/morbi/ut.png?mauris=augue&eget=a&massa=suscipit&tempor=nulla&convallis=elit&nulla=ac&neque=nulla&libero=sed&convallis=vel&eget=enim&eleifend=sit&luctus=amet&ultricies=nunc&eu=viverra&nibh=dapibus&quisque=nulla&id=suscipit&justo=ligula&sit=in&amet=lacus&sapien=curabitur&dignissim=at&vestibulum=ipsum&vestibulum=ac&ante=tellus&ipsum=semper&primis=interdum&in=mauris&faucibus=ullamcorper&orci=purus&luctus=sit&et=amet&ultrices=nulla&posuere=quisque&cubilia=arcu&curae=libero&nulla=rutrum&dapibus=ac&dolor=lobortis&vel=vel&est=dapibus');
insert into Exercises (exercise_name, exercise_type, video_url) values ('pilates', 'cardio', null);
insert into Exercises (exercise_name, exercise_type, video_url) values ('swimming', 'cardio', 'http://gravatar.com/tincidunt/nulla/mollis/molestie/lorem.xml?quisque=iaculis&porta=justo&volutpat=in&erat=hac');
insert into Goals (user_id, goal_type, start_time, end_time) values (74, 'pilates', '12/29/2024', '4/4/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (28, 'cardio', '11/06/2025', '3/4/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (127, 'swimming', '04/21/2025', '9/23/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (141, 'pilates', '11/12/2025', '11/4/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (76, 'strength training', '11/30/2025', '8/4/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (56, 'pilates', '06/05/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (140, 'running', '02/12/2025', '4/16/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (60, 'cardio', '05/06/2025', '5/27/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (139, 'yoga', '12/26/2024', '2/21/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (96, 'running', '10/06/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (53, 'strength training', '07/28/2025', '5/26/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (89, 'cardio', '01/08/2025', '7/4/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (138, 'cardio', '03/23/2025', '11/25/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (75, 'yoga', '07/19/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (8, 'running', '09/11/2025', '5/5/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (50, 'pilates', '01/30/2025', '1/6/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (48, 'strength training', '09/13/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (23, 'yoga', '09/30/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (90, 'cardio', '02/02/2025', '12/24/2024');
insert into Goals (user_id, goal_type, start_time, end_time) values (68, 'cycling', '04/04/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (156, 'yoga', '10/15/2025', '12/30/2024');
insert into Goals (user_id, goal_type, start_time, end_time) values (111, 'strength training', '09/16/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (47, 'yoga', '10/28/2025', '8/27/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (135, 'swimming', '11/18/2025', '1/26/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (139, 'swimming', '09/10/2025', '4/12/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (76, 'running', '12/02/2025', '4/20/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (9, 'cardio', '06/07/2025', '11/23/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (129, 'strength training', '04/15/2025', '6/15/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (14, 'strength training', '09/02/2025', '4/3/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (156, 'cycling', '03/19/2025', '2/1/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (107, 'swimming', '05/22/2025', '1/19/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (47, 'cardio', '12/24/2024', '3/8/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (13, 'pilates', '05/24/2025', '7/16/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (120, 'cycling', '11/05/2025', '1/20/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (112, 'cycling', '09/18/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (59, 'running', '04/06/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (21, 'strength training', '02/13/2025', '3/12/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (6, 'running', '01/23/2025', '7/22/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (60, 'yoga', '01/03/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (3, 'pilates', '06/27/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (99, 'pilates', '09/15/2025', '6/20/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (60, 'strength training', '03/29/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (118, 'yoga', '11/30/2025', '3/5/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (69, 'yoga', '09/13/2025', '8/3/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (25, 'strength training', '03/18/2025', '7/18/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (42, 'strength training', '05/05/2025', '8/13/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (64, 'cardio', '11/18/2025', '12/20/2024');
insert into Goals (user_id, goal_type, start_time, end_time) values (72, 'running', '12/13/2024', '1/14/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (88, 'swimming', '01/18/2025', '10/9/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (136, 'yoga', '01/31/2025', '4/22/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (108, 'cardio', '07/11/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (59, 'yoga', '10/12/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (154, 'cycling', '12/03/2025', '4/15/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (39, 'pilates', '05/26/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (122, 'swimming', '06/17/2025', '2/10/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (80, 'swimming', '05/14/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (59, 'cardio', '07/24/2025', '10/24/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (120, 'running', '07/22/2025', '1/7/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (27, 'cycling', '10/30/2025', '7/25/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (34, 'cardio', '06/06/2025', '1/11/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (81, 'swimming', '04/17/2025', '3/24/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (52, 'running', '05/20/2025', '2/15/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (113, 'pilates', '09/13/2025', '9/15/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (100, 'swimming', '08/08/2025', '12/9/2024');
insert into Goals (user_id, goal_type, start_time, end_time) values (36, 'strength training', '01/03/2025', '8/6/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (153, 'swimming', '12/21/2024', '9/21/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (61, 'cardio', '10/02/2025', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (57, 'running', '03/24/2025', '5/27/2025');
insert into Goals (user_id, goal_type, start_time, end_time) values (80, 'cycling', '12/23/2024', null);
insert into Goals (user_id, goal_type, start_time, end_time) values (99, 'running', '07/27/2025', '5/13/2025');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (148, '07/22/2025', 97, 'low', null, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (92, '01/21/2025', 64, 'intense', 678, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (88, '04/25/2025', 249, 'high', 416, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (33, '11/07/2025', null, 'high', 685, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (33, '04/01/2025', 255, 'low', 428, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (59, '03/17/2025', null, null, 796, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (79, '08/03/2025', 107, 'intense', null, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (51, '09/27/2025', 254, 'medium', 577, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (5, '12/01/2025', 280, 'low', 725, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (133, '06/14/2025', null, 'low', null, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (59, '01/01/2025', 29, 'intense', 287, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (56, '08/14/2025', null, null, 505, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (75, '12/27/2024', null, null, 189, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (1, '06/04/2025', 297, 'medium', 867, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (151, '08/26/2025', 4, 'intense', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (60, '08/30/2025', 55, 'intense', 556, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (76, '03/19/2025', 293, 'low', 733, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (151, '07/29/2025', null, null, 845, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (91, '01/08/2025', null, 'low', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (86, '07/15/2025', null, 'intense', 261, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (136, '10/18/2025', 214, 'intense', 335, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (108, '11/27/2025', 154, 'medium', 178, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (73, '04/19/2025', null, 'intense', 79, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (59, '04/14/2025', 144, null, 81, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (53, '11/09/2025', null, null, 855, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (81, '11/21/2025', null, null, 92, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (27, '09/15/2025', 197, 'high', 942, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (134, '05/20/2025', 217, 'high', null, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (89, '11/28/2025', null, 'medium', 447, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (15, '09/18/2025', 74, 'medium', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (52, '09/16/2025', null, null, 764, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (39, '07/07/2025', 88, 'low', 519, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (31, '06/27/2025', 67, 'high', 987, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (152, '04/25/2025', null, 'high', 76, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (102, '01/23/2025', null, 'medium', 783, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (74, '01/20/2025', 151, null, null, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (87, '09/10/2025', 44, 'medium', 189, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (21, '04/21/2025', 210, 'intense', 500, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (136, '05/19/2025', null, null, 267, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (138, '09/12/2025', 10, 'high', 416, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (103, '02/09/2025', 50, null, 64, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (4, '05/17/2025', 268, 'high', 354, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (159, '02/17/2025', 270, 'high', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (74, '04/17/2025', 105, 'intense', 81, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (114, '10/16/2025', 220, 'medium', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (92, '10/31/2025', 165, 'low', 632, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (92, '08/28/2025', 29, 'high', 457, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (126, '08/13/2025', 266, 'high', null, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (22, '06/24/2025', 197, null, 688, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (64, '10/02/2025', 259, 'intense', 696, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (22, '11/18/2025', 216, 'high', 285, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (18, '12/08/2024', null, null, 33, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (76, '12/21/2024', 119, 'low', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (106, '05/28/2025', 263, 'low', 773, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (47, '09/09/2025', 171, 'high', 829, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (66, '09/01/2025', 35, 'high', 105, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (105, '11/23/2025', 209, 'medium', 549, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (87, '09/02/2025', null, 'high', 677, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (144, '02/20/2025', 137, 'high', 243, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (133, '05/12/2025', 128, 'intense', 422, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (17, '12/13/2024', 221, 'low', null, '10 reps of bench press');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (156, '03/29/2025', 247, null, 210, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (127, '09/16/2025', 33, 'low', 84, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (143, '09/02/2025', 38, 'low', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (70, '04/02/2025', 273, 'low', 806, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (76, '07/09/2025', 75, 'intense', 55, null);
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (151, '07/15/2025', 217, null, null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (53, '02/05/2025', 239, 'medium', 600, 'Circuit training');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (85, '07/27/2025', 68, 'medium', 752, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (103, '10/27/2025', null, 'intense', null, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (14, '12/20/2024', null, 'intense', 300, '20 minutes of cardio');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (34, '09/24/2025', 209, null, 822, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (1, '07/25/2025', 103, 'high', 177, 'Stretching routine');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (102, '07/26/2025', 149, 'medium', 154, '5 sets of squats');
insert into Workouts (user_id, date_time, duration_min, intensity, kcal_burned, notes) values (133, '03/15/2025', 154, 'high', null, 'Circuit training');
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (31, '2/11/2025', 127.82, 726.96);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (51, '1/8/2025', 790.24, 126.87);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (52, '8/28/2025', 979.19, 686.67);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (99, '6/23/2025', null, 837.93);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (69, '4/23/2025', null, 921.06);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (81, '9/24/2025', 157.34, 234.19);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (2, '7/25/2025', 38.75, 282.49);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (12, '8/28/2025', 928.89, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (46, '10/27/2025', 4.59, 314.44);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (79, '5/29/2025', 363.56, 311.31);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (96, '2/11/2025', 224.83, 124.77);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (66, '10/31/2025', 658.46, 209.3);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (115, '3/1/2025', 812.65, 899.17);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (117, '10/30/2025', 588.34, 91.8);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (38, '11/1/2025', 363.18, 296.41);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (27, '4/29/2025', null, 956.11);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (20, '7/21/2025', 941.39, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (120, '11/4/2025', null, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (152, '11/28/2025', 233.86, 701.67);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (146, '5/31/2025', 625.75, 565.18);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (51, '4/25/2025', 107.25, 169.1);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (45, '3/8/2025', null, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (156, '5/31/2025', null, 658.23);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (8, '8/24/2025', null, 394.45);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (6, '9/16/2025', 282.86, 35.18);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (13, '10/24/2025', 397.78, 112.92);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (152, '2/19/2025', 749.59, 648.38);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (74, '9/24/2025', null, 835.09);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (68, '8/6/2025', null, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (76, '11/3/2025', null, 45.77);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (89, '4/28/2025', 742.44, 265.32);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (70, '6/15/2025', 266.71, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (118, '12/3/2025', 722.91, 436.85);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (32, '2/26/2025', 100.03, 577.27);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (123, '2/12/2025', 648.31, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (84, '3/19/2025', 198.69, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (27, '11/1/2025', null, 759.06);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (76, '9/25/2025', 140.98, 583.87);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (142, '3/19/2025', 445.38, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (9, '9/24/2025', null, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (138, '11/29/2025', 361.67, 616.98);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (97, '1/21/2025', null, 607.91);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (24, '2/19/2025', 138.35, 19.04);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (120, '12/17/2024', 829.08, 888.86);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (145, '9/14/2025', 853.64, 128.09);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (5, '12/6/2024', 440.61, 884.5);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (147, '7/31/2025', 378.23, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (116, '6/2/2025', 815.74, 900.19);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (47, '1/16/2025', 868.83, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (71, '7/25/2025', 297.72, 646.48);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (57, '6/11/2025', null, 972.57);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (81, '10/17/2025', 465.99, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (145, '1/24/2025', 53.33, null);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (110, '3/13/2025', 116.67, 736.38);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (97, '4/13/2025', 529.35, 193.8);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (132, '6/18/2025', 823.45, 529.05);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (70, '8/28/2025', 958.6, 635.59);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (69, '2/25/2025', 639.09, 552.64);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (118, '1/6/2025', null, 60.21);
insert into MetricLogs (user_id, date_time, weight_kg, body_fat_pct) values (118, '4/27/2025', 236.48, null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (38, '02/01/2025', 'breakfast', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (8, '10/18/2025', 'lunch', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (62, '11/06/2025', 'lunch', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (157, '08/23/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (118, '10/12/2025', 'breakfast', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (49, '01/14/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (55, '08/16/2025', 'breakfast', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (111, '06/19/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (42, '05/31/2025', 'lunch', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (99, '04/10/2025', 'lunch', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (84, '09/07/2025', 'lunch', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (57, '07/12/2025', 'dinner', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (95, '03/08/2025', 'snack', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (83, '07/12/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (119, '05/03/2025', 'dinner', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (16, '07/11/2025', 'dinner', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (108, '06/13/2025', 'dinner', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (14, '09/13/2025', 'snack', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (61, '04/10/2025', 'lunch', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (147, '12/14/2024', 'dinner', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (157, '02/26/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (144, '05/28/2025', 'breakfast', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (28, '02/27/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (71, '03/15/2025', 'snack', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (24, '12/12/2024', 'snack', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (160, '02/02/2025', 'breakfast', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (151, '12/14/2024', 'breakfast', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (22, '02/28/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (71, '05/12/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (105, '05/23/2025', 'dinner', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (32, '04/17/2025', 'snack', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (34, '08/14/2025', 'dinner', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (133, '05/11/2025', 'breakfast', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (88, '02/16/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (105, '10/19/2025', 'breakfast', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (22, '01/07/2025', 'breakfast', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (120, '05/04/2025', 'breakfast', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (121, '11/27/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (132, '02/26/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (47, '09/23/2025', 'lunch', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (122, '08/05/2025', 'dinner', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (117, '01/12/2025', 'breakfast', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (86, '03/13/2025', 'breakfast', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (78, '09/04/2025', 'breakfast', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (120, '09/22/2025', 'breakfast', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (121, '01/26/2025', 'lunch', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (60, '11/15/2025', 'breakfast', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (78, '10/09/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (87, '03/20/2025', 'snack', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (64, '06/02/2025', 'lunch', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (7, '03/22/2025', 'breakfast', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (140, '09/02/2025', 'lunch', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (4, '05/18/2025', 'lunch', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (57, '05/21/2025', 'lunch', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (21, '03/11/2025', 'lunch', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (132, '04/29/2025', 'snack', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (71, '12/20/2024', 'lunch', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (160, '11/21/2025', 'dinner', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (36, '10/19/2025', 'dinner', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (114, '09/23/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (158, '05/11/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (100, '03/27/2025', 'dinner', 'Enjoyed a delicious salad for lunch');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (127, '10/23/2025', 'lunch', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (138, '10/20/2025', 'snack', 'Indulged in a decadent dessert after dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (90, '09/21/2025', 'dinner', 'Tried a new recipe for dinner');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (56, '08/01/2025', 'lunch', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (56, '08/06/2025', 'breakfast', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (103, '05/16/2025', 'breakfast', 'Snacked on some fresh fruit in the afternoon');
insert into MealLogs (user_id, meal_date, meal_type, notes) values (87, '05/09/2025', 'snack', null);
insert into MealLogs (user_id, meal_date, meal_type, notes) values (40, '12/31/2024', 'dinner', 'Tried a new recipe for dinner');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (66, 1, 19, 409473.11, '4881g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (18, 3, 34, 105834.25, '153g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (21, 1, 12, 505685.42, '5294g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (8, 3, 27, 110539.29, '329g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (54, 3, 37, 840467.78, '65g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (20, 1, 17, 291282.92, '8694g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (27, 8, 7, 428587.97, '536g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (55, 7, 19, 724453.49, '64g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (41, 10, 12, 606613.63, '25g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (42, 2, 28, 298954.98, '25g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (70, 6, 29, 466467.13, '7441g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (52, 4, 22, 322809.47, '5434g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (67, 1, 33, 732046.11, '45g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (49, 6, 21, 850447.73, '256g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (10, 4, 22, 928349.94, '121g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (34, 6, 25, 618847.37, '770g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (55, 3, 18, 78489.08, '112g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (9, 2, 4, 944056.1, '40g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (17, 9, 29, 86741.3, '729g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (70, 8, 22, 669679.02, '4188g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (44, 1, 2, 639479.18, '691g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (57, 10, 23, 126825.71, '9815g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (69, 2, 3, 949711.33, '126g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (59, 2, 23, 802112.09, '1286g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (7, 10, 21, 421165.55, '89g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (31, 9, 38, 478751.67, '12g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (3, 1, 33, 32515.34, '45g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (68, 2, 33, 942579.32, '426g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (13, 4, 22, 114313.92, '27g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (45, 9, 22, 943423.97, '30g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (3, 3, 10, 613048.47, '8519g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (32, 9, 3, 336592.37, '479g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (46, 7, 34, 449980.85, '030g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (65, 1, 22, 345384.9, '5135g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (14, 8, 1, 532813.2, '80g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (60, 4, 38, 529663.34, '7801g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (42, 5, 23, 464727.6, '951g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (67, 10, 4, 860907.89, '939g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (45, 2, 18, 73521.86, '98g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (34, 5, 12, 689865.1, '7403g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (34, 4, 33, 994714.39, '851g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (47, 10, 28, 760188.27, '196g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (61, 5, 21, 601284.54, '376g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (57, 9, 28, 753523.76, '9102g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (61, 7, 10, 721482.41, '17g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (70, 10, 11, 302068.08, '4019g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (53, 3, 23, 372957.6, '832g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (50, 4, 23, 920210.68, '014g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (53, 1, 14, 779460.96, '300g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (42, 8, 31, 524863.8, '6703g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (18, 6, 5, 209148.96, '04g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (11, 2, 37, 76310.97, '71g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (48, 4, 1, 127892.03, '5898g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (51, 4, 26, 682902.1, '0215g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (2, 7, 28, 400248.11, '1681g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (58, 4, 3, 17587.0, '14g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (21, 3, 5, 179980.69, '619g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (43, 5, 33, 977625.13, '298g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (37, 2, 38, 212218.65, '37g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (62, 8, 7, 775176.08, '0974g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (6, 9, 14, 455905.25, '321g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (61, 4, 1, 446918.35, '4702g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (33, 6, 36, 859179.58, '87g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (70, 8, 10, 873759.89, '386g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (47, 6, 22, 10888.44, '53g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (26, 6, 36, 164881.31, '30g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (35, 7, 21, 563175.88, '4691g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (69, 2, 23, 497258.03, '0993g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (16, 4, 23, 42898.06, '00g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (4, 9, 37, 781160.6, '625g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (4, 2, 1, 169594.38, '413g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (14, 3, 29, 981163.73, '8240g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (44, 2, 15, 961168.47, '78g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (68, 2, 23, 851533.91, '8737g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (15, 10, 27, 720770.63, '059g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (1, 4, 34, 554205.38, '33g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (9, 8, 7, 710074.25, '875g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (18, 9, 10, 705264.01, '60g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (28, 5, 26, 20414.64, '39g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (46, 6, 37, 794158.5, '9628g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (68, 5, 6, 641760.58, '7251g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (27, 8, 25, 56189.62, '12g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (63, 8, 7, 454750.56, '458g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (37, 3, 16, 398193.82, '3570g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (6, 10, 12, 560403.6, '765g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (70, 7, 6, 160825.22, '9136g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (28, 5, 25, 602669.4, '77g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (60, 9, 17, 634696.03, '80g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (21, 8, 23, 890984.62, '1477g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (29, 8, 36, 856081.51, '456g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (38, 9, 20, 699189.98, '2645g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (43, 3, 30, 542105.64, '26g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (43, 8, 23, 250094.01, '0785g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (31, 5, 22, 42581.11, '4658g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (13, 3, 12, 54312.98, '7336g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (24, 5, 18, 5443.42, '49g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (70, 8, 1, 682958.41, '1301g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (30, 6, 36, 99859.35, '4217g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (58, 2, 36, 303255.42, '31g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (58, 7, 4, 225048.13, '392g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (27, 4, 33, 253177.51, '480g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (55, 1, 18, 235855.82, '9934g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (36, 3, 29, 965254.98, '124g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (42, 1, 21, 91423.91, '93g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (62, 4, 20, 232560.46, '650g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (51, 7, 25, 995656.6, '54g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (25, 9, 22, 435934.22, '6299g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (44, 7, 25, 572993.0, '9587g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (9, 10, 32, 517619.39, '0760g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (39, 2, 27, 426568.99, '483g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (46, 2, 29, 903551.75, '2455g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (60, 8, 26, 95840.23, '12g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (59, 3, 33, 329894.03, '9949g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (36, 7, 23, 719672.99, '65g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (42, 9, 40, 273987.61, '71g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (61, 4, 31, 420976.51, '53g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (15, 1, 14, 326225.69, '570g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (37, 3, 8, 390163.11, '649g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (48, 5, 23, 51231.8, '3432g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (17, 9, 29, 128246.73, '718g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (69, 3, 12, 506528.95, '2394g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (56, 3, 6, 356762.35, '1423g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (19, 9, 29, 703487.31, '504g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (66, 3, 6, 843793.2, '607g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (5, 3, 8, 848199.29, '17g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (55, 2, 9, 298608.78, '7851g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (36, 9, 16, 49661.86, '71g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (53, 2, 5, 71318.9, '380g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (17, 8, 5, 231746.82, '5925g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (24, 8, 27, 498258.88, '61g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (43, 9, 21, 967370.05, '3737g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (27, 4, 1, 739405.83, '30g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (60, 10, 2, 223353.73, '3743g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (47, 10, 19, 501869.74, '962g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (57, 3, 32, 171059.09, '1266g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (16, 6, 27, 378970.71, '41g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (11, 9, 36, 842180.47, '724g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (18, 8, 30, 185620.85, '6047g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (46, 5, 3, 625617.91, '15g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (2, 3, 8, 576915.39, '7440g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (28, 3, 28, 273155.52, '0055g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (49, 4, 36, 617307.32, '8681g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (53, 4, 37, 951410.53, '3438g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (18, 5, 30, 174086.08, '16g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (55, 8, 8, 28776.84, '964g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (49, 8, 21, 706811.36, '094g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (21, 7, 21, 301117.21, '4276g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (38, 1, 32, 910510.63, '188g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (1, 8, 31, 958569.12, '63g');
insert into MealItems (meal_id, item_num, food_id, quantity, unit) values (15, 3, 19, 840764.03, '51g');
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (34, 59, null, 3.93, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (5, 694, 95.15, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (44, 836, 20.9, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (70, 34, 77.95, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (52, 400, 4.58, 69.59, 25.16);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (70, 363, 19.14, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (52, 111, 22.05, 26.38, 59.91);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (67, null, null, 37.04, 18.46);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (32, 815, 27.25, 36.97, 10.38);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (62, 453, null, 89.24, 91.85);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (59, 52, 86.08, 9.11, 5.26);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (38, 350, null, 77.32, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (24, 943, null, 53.43, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (22, 371, null, 30.33, 44.49);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (33, null, 68.89, 80.96, 37.09);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (66, 118, null, 2.74, 35.11);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (17, 258, null, 94.81, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (15, 898, null, 94.53, 55.17);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (43, 526, null, 86.94, 2.94);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (16, 950, 47.15, null, 99.02);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (69, 784, 99.64, 26.72, 4.3);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (29, 353, 59.68, 79.12, 33.07);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (53, 866, 24.75, 77.78, 10.79);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (31, null, 94.85, 61.28, 27.17);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (6, 574, 82.61, 64.15, 67.24);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (55, 391, null, 2.25, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (10, null, 20.71, 95.42, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (48, 738, 30.53, 19.14, 58.57);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (42, 515, null, 69.06, 46.65);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (40, 137, 7.7, 54.4, 5.6);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (42, 75, 5.77, null, 17.17);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (32, 547, 57.01, 31.08, 54.05);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (22, 674, 34.01, 37.09, 77.5);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (47, 448, 24.73, 93.46, 15.21);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (45, 703, null, 70.99, 35.35);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (54, 485, 54.64, null, 65.81);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (14, null, 49.1, null, 0.64);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (60, null, 21.06, 10.98, 67.39);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (5, 17, 77.25, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (23, 381, 85.2, 46.98, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (36, 192, 62.09, null, 31.2);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (52, null, 93.96, 33.59, 55.79);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (31, 245, 32.42, 90.64, 46.88);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (44, 788, null, null, 37.14);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (35, 543, 1.69, 76.12, 60.05);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (32, null, null, 48.92, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (3, 490, null, 3.79, 6.64);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (69, 790, 24.43, 11.68, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (3, null, 99.66, null, 24.94);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (58, 78, null, 31.7, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (38, null, 96.58, 26.32, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (46, 790, 95.18, 42.39, 84.05);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (38, null, 18.04, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (56, null, null, 67.3, 99.18);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (18, 602, null, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (31, 702, 98.14, 73.86, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (60, 759, null, 61.1, 59.0);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (8, null, null, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (2, 350, 73.55, 46.41, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (11, 947, 39.29, null, 12.91);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (51, 679, 13.83, null, 82.54);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (61, 155, 8.45, 13.44, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (17, 71, null, 71.75, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (15, 849, null, 23.15, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (58, 577, null, 93.0, 3.91);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (25, null, 62.87, 49.05, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (62, 864, 30.44, null, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (68, null, 40.28, null, 44.21);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (6, 724, 81.59, 92.3, 67.58);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (15, 162, 11.48, 19.17, 81.32);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (21, 982, 50.71, null, 83.39);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (6, 289, null, 30.65, 25.76);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (48, 621, 66.8, 86.02, 80.71);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (27, null, 10.46, 63.46, null);
insert into Nutrients (meal_id, calories, protein_grams, carbs_grams, fat_grams) values (11, 254, 49.45, 40.96, null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (32, 124, 'Yoga and Meditation Plan', '4/10/2025', 'Strength training program');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (32, 151, 'Muscle Gain Program', '7/4/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (8, 135, 'Cardio Workout Routine', '5/5/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (22, 128, 'Weight Loss Plan', '5/31/2025', 'Yoga and meditation plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (13, 160, 'Cardio Workout Routine', '8/13/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (39, 135, 'Muscle Gain Program', '1/31/2025', 'HIIT workout routine');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (25, 141, 'High Intensity Interval Training', '4/11/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (15, 126, 'Muscle Gain Program', '2/1/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (19, 143, 'Weight Loss Plan', '1/28/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (19, 150, 'Yoga and Meditation Plan', '8/11/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (21, 121, 'Cardio Workout Routine', '7/19/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (38, 144, 'Yoga and Meditation Plan', '4/9/2025', 'HIIT workout routine');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (29, 146, 'Cardio Workout Routine', '3/8/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (2, 128, 'Weight Loss Plan', '9/16/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (27, 155, 'Muscle Gain Program', '7/19/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (24, 148, 'Muscle Gain Program', '6/26/2025', 'CrossFit challenge');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (14, 125, 'Weight Loss Plan', '3/27/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (21, 158, 'Cardio Workout Routine', '1/27/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (33, 159, 'Muscle Gain Program', '6/11/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (26, 124, 'Cardio Workout Routine', '5/22/2025', 'Strength training program');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (11, 150, 'Cardio Workout Routine', '1/2/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (30, 132, 'Yoga and Meditation Plan', '1/26/2025', 'HIIT workout routine');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (14, 155, 'High Intensity Interval Training', '11/4/2025', 'CrossFit challenge');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (18, 159, 'Muscle Gain Program', '4/3/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (37, 143, 'Yoga and Meditation Plan', '6/30/2025', 'CrossFit challenge');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (7, 150, 'Cardio Workout Routine', '1/11/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (19, 137, 'Cardio Workout Routine', '8/23/2025', 'Strength training program');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (10, 139, 'Yoga and Meditation Plan', '8/27/2025', 'CrossFit challenge');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (34, 148, 'Yoga and Meditation Plan', '11/11/2025', 'Strength training program');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (26, 136, 'High Intensity Interval Training', '1/21/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (37, 143, 'Muscle Gain Program', '7/1/2025', 'Yoga and meditation plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (7, 138, 'High Intensity Interval Training', '4/6/2025', 'Strength training program');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (9, 129, 'Weight Loss Plan', '2/26/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (28, 155, 'Cardio Workout Routine', '8/26/2025', 'CrossFit challenge');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (17, 136, 'Muscle Gain Program', '8/13/2025', 'HIIT workout routine');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (4, 151, 'Weight Loss Plan', '6/3/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (31, 139, 'Cardio Workout Routine', '2/9/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (16, 155, 'Yoga and Meditation Plan', '5/6/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (31, 135, 'Muscle Gain Program', '12/31/2024', 'Strength training program');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (30, 152, 'Weight Loss Plan', '7/29/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (15, 144, 'Cardio Workout Routine', '12/17/2024', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (5, 125, 'Muscle Gain Program', '9/10/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (36, 122, 'High Intensity Interval Training', '2/17/2025', 'Yoga and meditation plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (13, 134, 'Muscle Gain Program', '3/26/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (40, 156, 'Cardio Workout Routine', '1/27/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (25, 141, 'Weight Loss Plan', '2/24/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (16, 127, 'Weight Loss Plan', '7/20/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (39, 159, 'Yoga and Meditation Plan', '1/25/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (10, 159, 'Cardio Workout Routine', '2/25/2025', 'Yoga and meditation plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (27, 124, 'Yoga and Meditation Plan', '12/29/2024', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (40, 160, 'Muscle Gain Program', '6/7/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (33, 148, 'Weight Loss Plan', '7/10/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (7, 152, 'Weight Loss Plan', '10/16/2025', 'CrossFit challenge');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (39, 157, 'High Intensity Interval Training', '5/14/2025', 'Yoga and meditation plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (14, 130, 'High Intensity Interval Training', '7/4/2025', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (19, 154, 'Muscle Gain Program', '7/5/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (2, 134, 'High Intensity Interval Training', '12/27/2024', null);
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (7, 133, 'Cardio Workout Routine', '12/6/2024', 'HIIT workout routine');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (23, 152, 'High Intensity Interval Training', '1/20/2025', 'Cardio-focused workout plan');
insert into WorkoutPlans (coach_id, client_id, plan_name, created_at, description) values (27, 142, 'Weight Loss Plan', '1/15/2025', 'Yoga and meditation plan');
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (40, 10, 'Saturday', 18, 1, 984);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (37, 23, 'Sunday', 2, null, 1246);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (36, 24, 'Tuesday', 20, null, 2288);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (29, 34, 'Thursday', 13, 17, 3115);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (29, 38, 'Sunday', 17, 1, 2495);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (9, 3, 'Tuesday', null, 19, 1843);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (21, 12, 'Sunday', 8, 12, 2242);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (21, 15, 'Thursday', null, 3, 3321);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (6, 26, 'Monday', 19, 9, 3005);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (21, 39, 'Wednesday', 9, 2, 3273);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (44, 38, 'Friday', 19, 14, 365);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (3, 35, 'Thursday', 12, 3, 1257);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (17, 5, 'Wednesday', 2, 14, 2891);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (16, 34, 'Saturday', 19, 13, 2012);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (50, 12, 'Sunday', 5, 5, 75);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (46, 4, 'Tuesday', null, null, 2952);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (39, 1, 'Monday', 8, null, 1502);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (13, 13, 'Friday', 2, 9, 3529);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (44, 10, 'Wednesday', 9, 8, 2350);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (41, 25, 'Sunday', 8, null, 2151);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (19, 17, 'Friday', 18, 17, 2239);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (24, 7, 'Sunday', 3, null, 704);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (18, 9, 'Wednesday', 2, 19, 913);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (49, 3, 'Tuesday', 19, 1, 627);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (5, 36, 'Saturday', 17, 5, 120);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (14, 17, 'Thursday', 13, null, 1683);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (47, 12, 'Monday', 8, 9, 2140);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (42, 37, 'Saturday', 14, 8, 1239);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (13, 40, 'Saturday', 5, 14, 2765);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (5, 20, 'Wednesday', 14, 12, 4);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (53, 32, 'Monday', 12, 1, 578);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (41, 2, 'Thursday', 11, 17, 2434);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (58, 36, 'Tuesday', 10, 6, 2006);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (34, 36, 'Monday', 13, 3, 3300);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (26, 9, 'Thursday', 14, 13, 240);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (12, 8, 'Friday', 12, 1, 1566);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (10, 8, 'Sunday', null, 2, 3356);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (14, 20, 'Wednesday', 2, 14, 475);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (20, 26, 'Sunday', 16, 11, 387);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (13, 25, 'Monday', 17, 1, 1498);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (16, 20, 'Monday', 19, 19, 1498);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (30, 38, 'Tuesday', 19, null, 1064);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (19, 17, 'Thursday', 6, 17, 2818);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (28, 14, 'Tuesday', 5, null, 2553);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (44, 31, 'Monday', 10, 2, 2137);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (23, 30, 'Saturday', 18, 7, 3008);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (13, 33, 'Saturday', 15, 14, 2487);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (50, 33, 'Thursday', 12, null, 3335);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (33, 4, 'Sunday', 5, 7, 3279);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (54, 37, 'Tuesday', 15, 13, 2936);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (53, 31, 'Sunday', 11, null, 2397);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (36, 15, 'Wednesday', 5, 17, 1424);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (34, 21, 'Thursday', null, 13, 2114);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (34, 8, 'Sunday', null, null, 31);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (36, 36, 'Saturday', 16, 2, 281);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (55, 11, 'Friday', 17, 16, 2046);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (37, 12, 'Monday', null, 1, 2945);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (47, 11, 'Tuesday', 6, 12, 566);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (12, 17, 'Thursday', 5, null, 435);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (37, 23, 'Friday', 18, 18, 3194);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (14, 15, 'Friday', null, 19, 1724);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (32, 20, 'Monday', 19, 12, 289);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (45, 38, 'Tuesday', 4, 3, 125);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (50, 37, 'Monday', 8, 2, 2368);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (27, 39, 'Saturday', null, 2, 2974);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (8, 22, 'Monday', 16, 12, 2814);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (19, 40, 'Wednesday', 14, null, 577);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (51, 31, 'Thursday', 20, 3, 757);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (18, 1, 'Tuesday', 11, 4, 3181);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (52, 29, 'Tuesday', null, 16, 2624);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (31, 38, 'Thursday', 3, 1, 1573);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (15, 35, 'Thursday', 20, 18, 1030);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (11, 22, 'Saturday', 1, null, 1532);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (15, 6, 'Friday', 8, 1, 1819);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (30, 14, 'Tuesday', 5, 8, 3371);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (47, 34, 'Thursday', null, 15, 251);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (23, 25, 'Tuesday', 16, 12, 348);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (31, 34, 'Thursday', 2, 13, 147);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (56, 26, 'Sunday', 19, 9, 3030);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (31, 5, 'Wednesday', 17, 17, 1468);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (43, 35, 'Saturday', 19, null, 1580);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (23, 1, 'Monday', 15, 19, 3371);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (23, 37, 'Wednesday', 7, 19, 402);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (36, 36, 'Thursday', 6, 18, 63);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (1, 17, 'Wednesday', 5, 6, 3069);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (20, 7, 'Thursday', null, 2, 1503);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (30, 36, 'Wednesday', 1, null, 1795);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (52, 27, 'Friday', 12, 3, 1677);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (22, 10, 'Friday', 14, 16, 3164);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (58, 4, 'Wednesday', 12, 1, 1822);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (26, 4, 'Thursday', 4, 10, 444);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (47, 20, 'Thursday', null, 6, 1266);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (19, 19, 'Monday', 1, 10, 2471);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (44, 35, 'Saturday', 11, 4, 2603);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (19, 34, 'Friday', 3, 11, 1549);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (36, 33, 'Wednesday', 15, 16, 905);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (51, 4, 'Monday', 9, 17, 794);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (24, 13, 'Tuesday', 9, 20, 3229);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (2, 25, 'Monday', 1, 3, 823);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (29, 36, 'Monday', 19, 20, 1490);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (60, 21, 'Friday', 19, null, 3344);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (29, 5, 'Friday', 18, null, 2449);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (37, 24, 'Tuesday', 9, 12, 2436);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (7, 26, 'Tuesday', 1, 2, 370);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (48, 37, 'Tuesday', 20, 16, 1613);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (49, 5, 'Monday', 15, 4, 904);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (46, 28, 'Thursday', 3, 5, 123);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (59, 10, 'Thursday', 8, 19, 3568);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (55, 28, 'Thursday', 17, null, 3244);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (58, 40, 'Thursday', 19, 17, 2281);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (58, 7, 'Friday', 3, null, 1132);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (59, 1, 'Tuesday', 15, 6, 2504);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (20, 31, 'Thursday', 4, 11, 3193);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (12, 38, 'Friday', 10, null, 1744);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (2, 23, 'Wednesday', null, 13, 1936);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (9, 26, 'Thursday', 20, 16, 427);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (25, 22, 'Monday', 3, 18, 2246);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (26, 1, 'Tuesday', 10, 1, 1057);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (23, 14, 'Saturday', 17, 2, 2284);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (53, 32, 'Friday', 2, null, 2209);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (33, 17, 'Monday', 10, null, 2025);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (60, 39, 'Thursday', 9, 2, 1022);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (4, 32, 'Saturday', 12, 16, 3100);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (49, 23, 'Wednesday', null, 5, 2644);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (21, 23, 'Monday', 3, 7, 2424);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (24, 36, 'Tuesday', null, 15, 2148);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (47, 6, 'Monday', 3, 4, 137);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (60, 40, 'Sunday', 10, null, 2032);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (54, 11, 'Wednesday', 3, 18, 3226);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (2, 31, 'Friday', 11, 6, 2787);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (32, 21, 'Sunday', 2, 16, 2166);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (56, 33, 'Tuesday', 18, 1, 2598);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (10, 30, 'Wednesday', 1, 9, 413);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (60, 22, 'Sunday', 11, null, 2568);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (4, 10, 'Sunday', 6, 15, 1994);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (41, 12, 'Wednesday', 13, 4, 1138);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (10, 39, 'Monday', 12, 11, 2973);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (39, 4, 'Sunday', 3, 3, 564);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (15, 6, 'Thursday', 4, null, 295);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (51, 38, 'Tuesday', 14, null, 3198);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (39, 23, 'Monday', 19, 8, 1037);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (55, 10, 'Sunday', 2, 7, 3553);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (45, 20, 'Monday', 2, 7, 3391);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (50, 37, 'Wednesday', 15, 1, 2589);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (21, 9, 'Sunday', 17, 4, 1595);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (20, 28, 'Tuesday', 18, 11, 422);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (56, 17, 'Tuesday', 14, 15, 183);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (56, 33, 'Saturday', 16, null, 3565);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (11, 22, 'Monday', 15, null, 3574);
insert into PlanExercises (plan_id, exercise_id, day_of_week, num_sets, num_reps, rest_seconds) values (9, 12, 'Friday', null, null, 3099);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (124, 2, '03/25/2025', '03/02/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (135, 42, '12/08/2024', '04/21/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (142, 26, '04/12/2025', '04/02/2025', 'Rest day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (129, 37, '04/23/2025', '11/11/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (154, 50, '05/13/2025', '12/26/2024', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (142, 35, '01/11/2025', '04/10/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (153, 30, '04/14/2025', '01/13/2025', 'Upper body workout');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (153, 18, '12/12/2024', '05/20/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (159, 38, '12/02/2025', '01/01/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (121, 11, '06/08/2025', '06/25/2025', 'Rest day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (151, 46, '03/30/2025', '01/12/2025', 'Upper body workout');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (157, 55, '12/28/2024', '08/05/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (134, 34, '12/03/2025', '12/11/2024', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (127, 1, '09/02/2025', '11/27/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (138, 28, '06/07/2025', '08/04/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (122, 54, '05/19/2025', '09/28/2025', 'Rest day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (154, 2, '01/31/2025', '05/14/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (123, 24, '05/28/2025', '05/24/2025', 'Rest day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (121, 8, '03/29/2025', '08/17/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (136, 27, '06/25/2025', '07/31/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (143, 38, '01/13/2025', '09/25/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (129, 55, '01/04/2025', '09/18/2025', 'Leg day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (133, 28, '09/17/2025', '05/27/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (144, 3, '02/23/2025', null, null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (146, 8, '06/19/2025', '02/07/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (137, 2, '09/07/2025', '08/14/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (131, 17, '05/11/2025', '06/16/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (138, 3, '12/02/2025', null, null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (128, 50, '09/04/2025', '01/04/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (160, 6, '10/10/2025', '03/24/2025', 'Rest day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (124, 18, '11/05/2025', '03/08/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (138, 42, '09/14/2025', '01/27/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (121, 30, '09/15/2025', '12/14/2024', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (124, 11, '01/30/2025', null, null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (149, 37, '12/25/2024', '09/19/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (156, 36, '05/16/2025', '03/13/2025', 'Upper body workout');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (125, 22, '07/18/2025', '04/07/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (135, 14, '09/03/2025', '07/17/2025', 'Upper body workout');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (130, 4, '01/04/2025', '08/04/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (153, 26, '12/25/2024', '06/23/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (159, 35, '12/15/2024', '03/09/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (151, 53, '08/07/2025', '06/01/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (126, 21, '03/27/2025', '03/14/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (141, 56, '12/21/2024', '12/19/2024', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (129, 10, '04/18/2025', '09/26/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (128, 24, '11/21/2025', '08/08/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (141, 27, '12/26/2024', '12/18/2024', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (152, 21, '01/02/2025', '01/24/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (139, 55, '10/17/2025', '08/11/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (157, 11, '04/25/2025', '10/04/2025', 'Leg day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (121, 32, '04/01/2025', '11/24/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (157, 45, '12/05/2025', '12/05/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (133, 45, '02/08/2025', '03/28/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (141, 30, '03/05/2025', '02/15/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (140, 51, '02/05/2025', '10/16/2025', 'HIIT training');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (145, 16, '01/28/2025', '10/25/2025', 'Leg day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (133, 40, '03/16/2025', '07/27/2025', 'Upper body workout');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (141, 57, '11/23/2025', '10/14/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (143, 58, '07/24/2025', '08/30/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (128, 14, '11/11/2025', '02/04/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (150, 16, '05/16/2025', '09/07/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (148, 59, '02/19/2025', '01/26/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (131, 38, '03/07/2025', '05/02/2025', 'Rest day');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (127, 44, '11/17/2025', '10/09/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (151, 54, '02/26/2025', '07/08/2025', 'Cardio session');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (127, 22, '06/19/2025', '01/05/2025', 'Upper body workout');
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (124, 37, '09/05/2025', '05/09/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (150, 52, '08/03/2025', '11/23/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (144, 39, '07/19/2025', '02/01/2025', null);
insert into WorkoutLogs (client_id, plan_id, log_date, complete_date, notes) values (131, 33, '01/21/2025', '06/10/2025', null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (143, '05/04/2025', 420, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (148, '09/25/2025', 143, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (152, '10/26/2025', 241, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (153, '12/06/2024', 104, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (157, '03/31/2025', 49, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (130, '12/07/2024', 380, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (144, '07/16/2025', 204, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (131, '07/10/2025', null, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (140, '05/24/2025', 112, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (152, '01/20/2025', null, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (154, '04/14/2025', 147, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (129, '02/24/2025', 138, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (133, '06/11/2025', 21, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (135, '08/29/2025', 344, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (129, '04/30/2025', 162, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (144, '06/24/2025', 399, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (152, '07/31/2025', 401, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (145, '07/07/2025', 35, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (156, '11/17/2025', 496, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (129, '12/13/2024', 93, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (153, '01/14/2025', 418, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (145, '06/21/2025', 182, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (129, '07/07/2025', 233, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (156, '10/04/2025', 112, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (133, '06/12/2025', null, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (141, '10/16/2025', null, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (141, '11/05/2025', null, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (159, '04/29/2025', null, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (123, '03/10/2025', 16, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (138, '04/18/2025', 366, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (144, '02/20/2025', 459, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (155, '11/10/2025', 227, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (140, '03/10/2025', 130, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (130, '06/13/2025', 157, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (154, '02/23/2025', 44, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (154, '03/06/2025', null, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (126, '09/15/2025', 414, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (140, '07/01/2025', 305, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (134, '06/17/2025', 389, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (121, '09/07/2025', null, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (127, '12/03/2025', 492, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (153, '10/13/2025', 333, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (148, '06/20/2025', null, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (133, '06/20/2025', 386, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (141, '02/05/2025', null, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (152, '10/14/2025', 331, 'Vegetable Curry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (138, '06/18/2025', 223, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (126, '05/30/2025', 362, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (155, '07/10/2025', 156, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (129, '05/11/2025', 139, 'Beef Stir Fry');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (123, '05/25/2025', 147, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (124, '12/14/2024', 426, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (144, '03/03/2025', null, 'Chicken Alfredo');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (130, '01/18/2025', 211, null);
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (159, '08/20/2025', 8, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (155, '03/22/2025', 409, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (152, '11/28/2025', 0, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (146, '01/14/2025', 40, 'Grilled Salmon');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (146, '04/01/2025', 484, 'Spaghetti Bolognese');
insert into CalorieLogs (client_id, cal_log_date, num_cal, meal_name) values (157, '01/18/2025', 330, 'Vegetable Curry');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (52, 53, '1/6/2025', 'Drink more water', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (63, 17, '8/18/2025', 'Reduce sugar consumption', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (67, 22, '5/14/2025', null, 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (46, 5, '7/11/2025', 'Drink more water', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (65, 19, '8/17/2025', 'Reduce sugar consumption', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (69, 31, '6/1/2025', 'Eat more fruits and vegetables', 'suggestion');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (65, 4, '9/24/2025', 'Eat more fruits and vegetables', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (44, 43, '2/20/2025', 'Eat more fruits and vegetables', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (60, 30, '11/2/2025', null, null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (68, 16, '4/17/2025', 'Eat more fruits and vegetables', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (67, 46, '4/13/2025', 'Reduce sugar consumption', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (76, 45, '7/22/2025', 'Reduce sugar consumption', 'suggestion');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (68, 45, '6/20/2025', 'Reduce sugar consumption', 'suggestion');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (58, 10, '2/10/2025', 'Eat more fruits and vegetables', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (74, 19, '1/11/2025', 'Increase fiber intake', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (62, 19, '8/31/2025', 'Increase fiber intake', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (54, 69, '5/14/2025', null, null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (73, 62, '2/2/2025', 'Reduce sugar consumption', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (49, 48, '10/23/2025', null, 'suggestion');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (79, 7, '12/10/2024', null, 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (71, 22, '2/16/2025', 'Reduce sugar consumption', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (70, 34, '9/27/2025', null, 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (49, 15, '10/7/2025', 'Eat more fruits and vegetables', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (55, 12, '6/14/2025', 'Limit processed foods', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (46, 14, '7/12/2025', 'Drink more water', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (54, 67, '2/7/2025', 'Increase fiber intake', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (48, 42, '7/15/2025', null, 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (72, 18, '10/18/2025', 'Drink more water', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (50, 20, '5/23/2025', 'Drink more water', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (76, 50, '11/26/2025', 'Increase fiber intake', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (46, 52, '4/24/2025', null, null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (64, 36, '2/23/2025', 'Reduce sugar consumption', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (74, 2, '5/8/2025', null, 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (61, 10, '12/2/2025', 'Eat more fruits and vegetables', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (42, 44, '9/13/2025', null, 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (51, 52, '4/25/2025', 'Eat more fruits and vegetables', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (72, 22, '9/15/2025', null, 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (44, 27, '9/9/2025', 'Reduce sugar consumption', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (51, 33, '3/12/2025', 'Drink more water', 'suggestion');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (80, 54, '8/27/2025', 'Eat more fruits and vegetables', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (76, 66, '2/15/2025', 'Drink more water', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (63, 59, '3/1/2025', 'Reduce sugar consumption', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (76, 27, '2/13/2025', 'Limit processed foods', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (62, 40, '11/2/2025', 'Reduce sugar consumption', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (71, 12, '8/19/2025', 'Eat more fruits and vegetables', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (67, 51, '2/4/2025', 'Limit processed foods', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (62, 23, '8/23/2025', null, 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (42, 48, '4/17/2025', 'Drink more water', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (72, 31, '10/25/2025', 'Increase fiber intake', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (57, 24, '9/25/2025', null, 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (42, 13, '2/13/2025', 'Reduce sugar consumption', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (79, 1, '3/23/2025', null, 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (64, 62, '10/26/2025', 'Eat more fruits and vegetables', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (56, 3, '9/28/2025', 'Reduce sugar consumption', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (72, 34, '8/23/2025', 'Reduce sugar consumption', 'requirement');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (69, 56, '6/27/2025', 'Reduce sugar consumption', 'positive');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (52, 12, '10/15/2025', 'Limit processed foods', 'suggestion');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (80, 12, '9/21/2025', 'Eat more fruits and vegetables', 'negative');
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (58, 34, '6/19/2025', 'Eat more fruits and vegetables', null);
insert into Comments (dietitian_id, meal_id, comment_time, comment_text, comment_type) values (46, 23, '7/11/2025', 'Reduce sugar consumption', 'positive');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (23, 156, '2025-11-12 07:28:25', 'message', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (4, 145, '2025-11-25 12:14:29', 'reminder', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (6, 144, '2025-02-16 22:41:47', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (29, 134, '2025-11-21 10:13:31', 'alert', 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (17, 133, '2025-11-24 09:44:34', 'alert', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (33, 141, '2025-11-14 21:11:39', null, 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (33, 129, '2025-05-25 12:24:51', 'alert', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (16, 154, '2025-04-28 22:14:51', 'alert', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (25, 142, '2025-09-12 11:41:25', 'reminder', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (19, 135, '2025-10-28 07:36:55', 'update', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (17, 157, '2024-12-09 15:35:41', null, 'incididunt ut labore et dolore magna aliqua');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (17, 137, '2025-06-18 01:06:33', 'alert', 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (32, 154, '2025-11-28 18:10:13', null, 'incididunt ut labore et dolore magna aliqua');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (10, 128, '2025-01-18 07:39:52', 'update', 'Ut enim ad minim veniam');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (17, 135, '2025-02-11 03:28:05', 'reminder', 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (38, 124, '2025-09-13 21:51:24', 'alert', 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (7, 160, '2025-01-30 19:03:32', null, 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (18, 145, '2025-10-31 21:03:19', 'message', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (40, 144, '2025-12-01 01:57:21', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (34, 145, '2025-02-26 00:22:35', null, 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (24, 148, '2025-04-21 23:49:40', null, 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (22, 124, '2025-03-12 00:41:58', 'notification', 'Ut enim ad minim veniam');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (27, 141, '2025-10-04 02:51:55', 'alert', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (19, 134, '2025-07-06 00:58:01', 'alert', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (39, 141, '2025-11-26 10:36:42', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (32, 151, '2025-05-30 12:38:57', 'reminder', 'Ut enim ad minim veniam');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (16, 151, '2025-11-15 01:27:31', 'update', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (16, 159, '2025-03-10 09:57:59', 'alert', 'Ut enim ad minim veniam');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (35, 158, '2025-04-13 11:02:53', 'reminder', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (10, 159, '2025-04-26 02:59:46', 'reminder', 'incididunt ut labore et dolore magna aliqua');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (35, 126, '2025-01-19 13:28:26', null, 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (31, 145, '2025-01-30 06:37:10', null, 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (3, 148, '2025-02-02 07:49:46', 'reminder', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (13, 147, '2025-09-11 13:20:48', 'update', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (1, 141, '2025-09-15 00:53:18', 'reminder', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (20, 125, '2025-04-15 03:05:19', 'notification', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (35, 148, '2025-10-30 11:01:27', 'update', 'incididunt ut labore et dolore magna aliqua');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (5, 142, '2025-09-16 10:53:47', null, 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (3, 151, '2025-01-05 10:40:26', 'notification', 'incididunt ut labore et dolore magna aliqua');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (24, 122, '2025-04-09 17:02:32', 'reminder', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (14, 158, '2025-06-09 11:31:11', 'message', 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (9, 149, '2025-05-18 05:40:21', 'reminder', 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (14, 121, '2025-12-03 07:50:48', 'notification', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (16, 143, '2025-07-26 20:19:30', 'notification', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (40, 122, '2025-06-24 23:32:38', 'alert', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (27, 158, '2025-10-14 01:46:21', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (35, 142, '2025-08-14 09:24:36', 'message', 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (21, 146, '2025-05-01 14:13:31', 'alert', 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (1, 152, '2025-07-03 14:37:21', 'update', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (24, 137, '2025-02-02 09:36:27', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (24, 139, '2025-06-29 01:10:58', null, 'Ut enim ad minim veniam');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (4, 145, '2025-12-04 00:07:52', 'update', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (6, 158, '2025-01-06 21:26:49', null, 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (37, 124, '2025-10-30 11:13:41', 'reminder', 'incididunt ut labore et dolore magna aliqua');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (26, 146, '2025-08-20 07:28:24', 'message', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (39, 135, '2024-12-19 21:33:33', 'message', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (7, 131, '2025-10-30 03:07:43', 'update', 'Ut enim ad minim veniam');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (22, 126, '2025-01-09 13:10:53', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (40, 136, '2025-07-26 21:12:58', 'notification', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (26, 150, '2025-01-06 19:10:51', 'update', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (21, 158, '2025-06-25 03:11:31', 'message', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (20, 137, '2025-04-25 13:22:29', 'notification', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (27, 129, '2025-08-22 13:08:21', 'alert', 'consectetur adipiscing elit');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (3, 131, '2024-12-11 00:12:36', 'notification', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (40, 133, '2025-04-07 06:37:27', 'message', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (35, 135, '2025-02-19 07:13:11', 'reminder', null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (13, 127, '2025-11-30 22:45:18', null, null);
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (14, 128, '2024-12-27 12:33:25', 'update', 'Sed do eiusmod tempor');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (33, 153, '2025-09-10 08:40:29', null, 'Lorem ipsum dolor sit amet');
insert into Notifications (coach_id, client_id, sent_date, notif_type, body_text) values (23, 144, '2025-12-05 16:22:31', 'reminder', null);
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (104, null, 'info', '8/31/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (117, 'high', 'debug', '2/4/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (102, 'critical', 'warning', '5/10/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (89, 'low', 'debug', '7/21/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (83, 'critical', 'critical', '12/26/2024', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (104, 'high', 'debug', '3/16/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (101, 'low', 'critical', '10/23/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (102, 'critical', 'info', '7/14/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (83, 'low', 'error', '11/30/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (92, 'medium', 'critical', '5/31/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (113, 'high', 'info', '2/24/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (104, 'low', 'debug', '4/1/2025', null);
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (96, 'low', 'info', '2/7/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (105, 'critical', 'error', '8/18/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (92, 'low', 'error', '10/21/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (89, 'high', null, '4/8/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (91, 'critical', null, '3/5/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (90, 'medium', 'critical', '3/15/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (114, 'high', 'info', '3/22/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (114, 'medium', 'debug', '8/1/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (101, 'medium', 'error', '6/6/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (119, 'low', 'info', '9/22/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (115, 'low', 'warning', '2/14/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (102, 'medium', 'error', '10/18/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (105, null, 'debug', '4/15/2025', null);
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (118, 'critical', 'info', '11/9/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (115, 'medium', null, '4/15/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (107, 'low', null, '6/12/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (104, 'low', 'debug', '6/9/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (92, 'medium', null, '11/3/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (116, 'critical', 'warning', '2/2/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (117, null, 'warning', '5/14/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (81, 'critical', 'warning', '6/5/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (98, 'medium', 'critical', '10/19/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (91, 'critical', 'warning', '7/22/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (117, null, 'critical', '9/26/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (83, 'critical', null, '4/15/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (110, 'medium', 'info', '9/13/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (81, 'high', null, '12/21/2024', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (120, 'critical', 'info', '9/5/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (105, 'critical', 'info', '2/9/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (101, 'medium', 'error', '9/1/2025', 'Information: System update available');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (85, 'medium', 'error', '12/17/2024', null);
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (103, 'low', 'critical', '3/25/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (115, 'medium', 'critical', '11/27/2025', null);
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (89, 'critical', 'debug', '12/13/2024', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (110, null, 'info', '11/21/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (88, 'low', 'debug', '3/20/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (97, 'high', 'critical', '3/6/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (105, 'low', 'error', '11/5/2025', 'Critical alert: Server down');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (103, 'medium', 'critical', '10/10/2025', null);
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (84, 'critical', 'error', '4/15/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (113, 'critical', 'critical', '11/1/2025', 'Error: Database connection lost');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (99, 'low', null, '1/11/2025', 'Warning: High CPU usage detected');
insert into SystemAlerts (admin_id, severity_level, notification_type, notification_time, message) values (111, 'high', 'critical', '4/10/2025', 'Information: System update available');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (104, '4/17/2025', 'mirror', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '9/22/2025', 'mirror', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (113, '10/24/2025', 'full', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (116, '1/19/2025', 'differential', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (89, '11/10/2025', 'differential', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (106, '3/5/2025', 'full', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (86, '11/8/2025', null, 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (81, '6/2/2025', 'differential', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (106, '4/24/2025', 'incremental', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (116, '9/6/2025', 'incremental', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '2/5/2025', 'incremental', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '5/18/2025', 'differential', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (89, '8/9/2025', 'differential', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (106, '10/1/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (106, '6/16/2025', 'differential', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (91, '8/14/2025', 'incremental', null);
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (109, '7/24/2025', 'incremental', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (93, '3/13/2025', 'full', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (103, '8/5/2025', 'differential', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (82, '9/6/2025', 'incremental', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (84, '9/12/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (107, '8/1/2025', 'incremental', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (81, '8/11/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '4/11/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (110, '6/14/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (119, '9/8/2025', 'incremental', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (90, '6/10/2025', null, 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (89, '10/15/2025', 'full', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (113, '9/16/2025', null, 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (85, '5/10/2025', 'full', null);
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '7/21/2025', 'incremental', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (111, '7/15/2025', 'mirror', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (91, '6/25/2025', 'incremental', null);
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '2/3/2025', 'full', null);
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (92, '1/30/2025', 'full', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (90, '1/9/2025', null, 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (106, '8/30/2025', 'mirror', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (93, '10/21/2025', 'incremental', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (102, '10/17/2025', 'full', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (110, '8/3/2025', null, 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (92, '11/8/2025', 'incremental', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (114, '8/11/2025', 'full', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (98, '6/28/2025', 'mirror', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (98, '11/21/2025', null, 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (86, '6/27/2025', 'differential', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (98, '3/28/2025', 'incremental', null);
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (100, '2/16/2025', 'mirror', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (96, '9/18/2025', 'incremental', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (102, '7/4/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (116, '9/14/2025', 'differential', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (113, '6/24/2025', 'mirror', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (84, '8/21/2025', 'differential', null);
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (114, '8/9/2025', 'full', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (81, '4/19/2025', 'mirror', 'active');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (82, '12/16/2024', 'mirror', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (109, '4/26/2025', 'mirror', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (117, '11/30/2025', 'differential', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (83, '5/15/2025', 'incremental', 'inactive');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (105, '10/28/2025', 'differential', 'pending');
insert into BackupRecords (admin_id, backup_time, backup_type, status) values (88, '12/28/2024', 'incremental', 'pending');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (84, 'Goals', 'create', '9/17/2025', 'historic', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (94, 'Notifications', 'delete', '1/5/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (95, 'WorkoutPlans', 'create', '5/24/2025', 'vintage', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (99, 'Workouts', 'delete', '6/6/2025', 'antique', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (108, 'WorkoutLogs', 'create', '10/29/2025', 'historic', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (90, 'Workouts', null, '11/5/2025', 'classic', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (96, 'Nutrients', 'delete', '5/9/2025', 'retro', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (117, 'WorkoutPlans', null, '3/15/2025', 'classic', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (120, 'Goals', 'view', '11/27/2025', 'retro', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (98, 'CalorieLogs', 'delete', '8/14/2025', 'antique', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (89, 'WorkoutLogs', 'create', '7/23/2025', 'vintage', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (115, 'CalorieLogs', 'update', '2/9/2025', 'retro', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (113, 'Nutrients', null, '6/26/2025', 'historic', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (118, 'WorkoutLogs', 'delete', '8/13/2025', 'antique', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (95, 'SystemAlerts', 'view', '11/15/2025', 'classic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (91, 'MealLogs', 'create', '7/14/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (98, 'Comments', 'view', '12/2/2025', 'historic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (108, 'Workouts', 'delete', '1/27/2025', 'antique', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (85, 'SystemAlerts', 'view', '8/26/2025', 'historic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (103, 'Notifications', null, '3/18/2025', 'antique', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (107, 'Nutrients', 'create', '4/8/2025', 'vintage', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (101, 'WorkoutPlans', 'delete', '9/13/2025', 'historic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (103, 'WorkoutPlans', 'delete', '2/5/2025', 'classic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (111, 'MealLogs', null, '6/6/2025', 'retro', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (94, 'Nutrients', 'delete', '6/3/2025', 'antique', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (115, 'WorkoutPlans', 'delete', '1/3/2025', 'vintage', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (113, 'CalorieLogs', 'delete', '5/11/2025', 'retro', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (87, 'Goals', 'create', '4/9/2025', 'historic', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (81, 'CalorieLogs', 'view', '12/7/2024', 'historic', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (111, 'CalorieLogs', 'update', '2/8/2025', 'historic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (118, 'Goals', 'view', '8/17/2025', 'historic', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (110, 'MealLogs', null, '9/9/2025', 'antique', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (112, 'Comments', 'create', '7/3/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (119, 'Notifications', 'view', '7/13/2025', 'classic', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (117, 'Nutrients', 'update', '5/21/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (83, 'MealLogs', 'update', '8/26/2025', 'vintage', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (98, 'Workouts', 'create', '5/11/2025', 'retro', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (95, 'WorkoutPlans', 'create', '9/6/2025', 'antique', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (100, 'Nutrients', 'delete', '11/12/2025', 'retro', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (84, 'CalorieLogs', 'delete', '1/12/2025', 'retro', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (112, 'SystemAlerts', 'view', '6/17/2025', 'retro', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (85, 'Notifications', 'view', '6/2/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (93, 'MealLogs', 'create', '2/20/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (82, 'Nutrients', 'create', '9/25/2025', 'classic', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (91, 'Notifications', 'update', '7/6/2025', 'antique', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (85, 'Comments', 'delete', '1/21/2025', 'retro', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (91, 'CalorieLogs', null, '6/14/2025', 'antique', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (92, 'MealLogs', 'view', '12/17/2024', 'classic', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (93, 'CalorieLogs', null, '9/5/2025', 'vintage', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (113, 'Workouts', 'update', '4/30/2025', 'historic', 'value');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (109, 'CalorieLogs', 'create', '1/1/2025', 'historic', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (84, 'SystemAlerts', 'create', '7/9/2025', 'vintage', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (90, 'SystemAlerts', 'view', '2/14/2025', 'retro', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (110, 'Comments', 'update', '9/23/2025', 'historic', 'new');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (82, 'Notifications', 'update', '11/7/2025', 'historic', 'text');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (112, 'CalorieLogs', 'create', '11/8/2025', 'vintage', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (88, 'Goals', 'create', '8/19/2025', 'historic', 'example');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (100, 'WorkoutPlans', null, '1/27/2025', 'antique', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (87, 'Goals', 'update', '7/2/2025', 'classic', 'fake');
insert into AuditLog (admin_id, table_name, action_type, change_date, old_value, new_value) values (100, 'SystemAlerts', 'create', '8/10/2025', 'retro', 'value');
