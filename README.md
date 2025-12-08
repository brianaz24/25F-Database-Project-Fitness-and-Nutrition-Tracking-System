# Fitness & Nutrition Tracking System

A comprehensive web application for tracking fitness activities, nutrition intake, and health goals. The system supports multiple user roles including everyday users, fitness coaches, dietitians, and system administrators, each with role-specific features and dashboards.

## Project Overview

## Prerequisites

## Team Members

- **Minghui Zhong** 
- **Hanfu Yao** 
- **Vineel Bandla** 
- **Avaneesh Anil** 


## Architecture

The application follows a three-tier architecture:

- **Frontend**: Streamlit web application (`./app`)
- **Backend**: Flask REST API (`./api`)
- **Database**: MySQL database (`./database-files`)

All components run in Docker containers for easy deployment and development.

## Prerequisites

- A GitHub Account
- A terminal-based git client or GUI Git client such as GitHub Desktop or the Git plugin for VSCode.
- A distribution of Python running on your laptop. The distribution supported by the course is [Anaconda](https://www.anaconda.com/download) or [Miniconda](https://www.anaconda.com/docs/getting-started/miniconda/install).
  - Create a new Python 3.11 environment in `conda` named `db-proj` by running:  
     ```bash
     conda create -n db-proj python=3.11
     ```
  - Install the Python dependencies listed in `api/requirements.txt` and `app/src/requirements.txt` into your local Python environment. You can do this by running `pip install -r requirements.txt` in each respective directory.
     ```bash
     cd api
     pip install -r requirements.txt
     cd ../app
     pip install -r requirements.txt
     ```
     Note that the `..` means go to the parent folder of the folder you're currently in (which is `api/` after the first command)
- VSCode with the Python Plugin installed

## Quick Start

### 1. Clone the Repository

     ```bash
git clone <repository-url>
cd 25F-Database-Project-Fitness-and-Nutrition-Tracking-System
```

### 2. Set Up Environment Variables

The application requires a `.env` file in the `api` directory for database configuration.

**Create the `.env` file:**

     ```bash
     cd api
cp .env.template .env  
```

**Required environment variables in `api/.env`:**

```env
# Database Configuration
DB_USER=root
MYSQL_ROOT_PASSWORD=your_secure_password_here
DB_HOST=db
DB_PORT=3306
DB_NAME=fitness_app

# Flask Secret Key (generate a random string)
SECRET_KEY=your_secret_key_here
```

**Important Security Notes:**
- Use a **strong, unique password** for `MYSQL_ROOT_PASSWORD`
- Generate a **random secret key** for `SECRET_KEY` (you can use: `python -c "import secrets; print(secrets.token_hex(32))"`)
- **Never commit** the `.env` file to version control
- The `.env` file should already be in `.gitignore`

### 3. Start the Application

Start all containers in detached mode:

```bash
docker compose up -d
```

This will start three containers:
- **web-app** (Streamlit frontend) - Available at `http://localhost:8501`
- **web-api** (Flask backend) - Available at `http://localhost:4000`
- **mysql_db** (MySQL database) - Available at `localhost:3200`

### 4. Access the Application

Open your web browser and navigate to:
```
http://localhost:8501
```

You'll see the login page where you can select a role and user to begin using the application.

## Project Structure

```
.
├── app/                          # Streamlit frontend application
│   ├── src/
│   │   ├── Home.py              # Main entry point
│   │   ├── modules/
│   │   │   └── nav.py           # Navigation and RBAC
│   │   └── pages/                # Application pages
│   │       ├── 00_Mark_Home.py  # Everyday user pages (00-04)
│   │       ├── 10_Sam_HomePage.py # Coach pages (10-13)
│   │       ├── 14_James_Home.py  # Dietitian pages (14-17)
│   │       └── 20_Admin_Home.py   # Admin pages (20-24)
│   ├── Dockerfile
│   └── requirements.txt
│
├── api/                          # Flask REST API backend
│   ├── backend/
│   │   ├── rest_entry.py        # Flask app initialization
│   │   ├── meals/               # Meal routes
│   │   ├── workouts/            # Workout routes
│   │   ├── clients/            # Client routes
│   │   ├── plans/              # Workout plan routes
│   │   ├── admin/              # Admin routes
│   │   └── db_connection/      # Database connection
│   ├── backend_app.py          # API entry point
│   ├── .env                    # Environment variables (create this)
│   ├── Dockerfile
│   └── requirements.txt
│
├── database-files/              # SQL initialization scripts
│   ├── 00_fitness_db.sql       # Main database schema
│   └── backup_sql/             # Backup SQL files
│
├── docker-compose.yaml          # Docker Compose configuration
└── README.md                    # This file
```

## User Roles & Features

### Everyday User (Mark)
- **Log Meals**: Track daily calorie intake
- **Record Workouts**: Log exercise sessions with duration and calories burned
- **View Progress**: Edit and delete meal/workout records
- **Manage Goals**: Create, edit, and track fitness/nutrition goals

### Fitness Coach (Sam)
- **Client Progress**: Monitor client workouts and nutrition
- **Manage Plans**: Create and assign personalized workout plans
- **Notifications**: Send alerts and track missed workouts

### Dietitian (James)
- **Client Meals**: Review and comment on client meal logs
- **Analytics**: View nutrition trends and patterns
- **Meal Plans**: Create personalized meal plans with recommendations

### System Administrator (Eva)
- **User Management**: Add, view, and manage system users
- **System Monitoring**: Track API health and ML models
- **Database Management**: Backup, restore, and cleanup operations
- **Audit & Security**: Review audit logs and security events

## Role-Based Access Control (RBAC)

The application implements RBAC through Streamlit's session state:

1. **Login**: Users select their role and user profile on the home page
2. **Session State**: Role and user info stored in `st.session_state`
3. **Navigation**: Sidebar links dynamically generated based on role (`app/src/modules/nav.py`)
4. **Page Access**: Each page checks authentication before displaying content

## Database Schema

The database includes the following main tables:

- **Users**: User accounts and profiles
- **Meals**: Meal logs with calories and timestamps
- **Workouts**: Workout logs with type, duration, and calories burned
- **Goals**: User fitness and nutrition goals
- **WorkoutPlans**: Coach-created workout plans
- **PlanExercises**: Exercises within workout plans
- **Comments**: Coach and dietitian comments on client data
- **Notifications**: System alerts and coach notifications
- **AuditLog**: System audit trail

See `database-files/00_fitness_db.sql` for the complete schema.

## API Endpoints

### Meals
- `GET /meals` - Get all meals
- `GET /meals/<id>` - Get specific meal
- `POST /meals` - Create new meal
- `PUT /meals/<id>` - Update meal
- `DELETE /meals/<id>` - Delete meal
- `GET /clients/<user_id>/meals` - Get user's meals

### Workouts
- `GET /workouts` - Get all workouts
- `GET /workouts/<id>` - Get specific workout
- `POST /workouts` - Create new workout
- `PUT /workouts/<id>` - Update workout
- `DELETE /workouts/<id>` - Delete workout
- `GET /clients/<user_id>/workouts` - Get user's workouts

### Goals
- `GET /clients/goals?user_id=<id>` - Get user's goals
- `POST /clients/goals` - Create new goal
- `PUT /clients/goals/<id>` - Update goal
- `DELETE /clients/goals/<id>` - Delete goal

### Plans
- `GET /plans` - Get all workout plans
- `POST /plans` - Create new plan
- `DELETE /plans/<id>` - Delete plan

### Admin
- `GET /admin/users` - Get all users
- `POST /admin/users` - Create new user
- `DELETE /admin/users/<id>` - Delete user
- `GET /admin/audit-log` - Get audit logs

*See API code in `api/backend/` for complete endpoint documentation.*

## Troubleshooting

### Containers won't start
- Check Docker Desktop is running
- Verify `.env` file exists in `api/` directory
- Check logs: `docker compose logs`

### Database connection errors
- Verify `.env` file has correct database credentials
- Ensure database container is running: `docker compose ps`
- Check database logs: `docker compose logs db`

### SQL initialization errors
- Check database logs for SQL syntax errors
- Ensure SQL files in `database-files/` are valid
- Recreate database: `docker compose down db -v && docker compose up db -d`

### Frontend not updating
- Click "Always Rerun" in Streamlit browser tab
- Check if containers are running: `docker compose ps`
- View frontend logs: `docker compose logs app`

### API not responding
- Verify API container is running
- Check API logs: `docker compose logs api`
- Test API directly: `curl http://localhost:4000/`

## Development Notes

### Hot Reloading
- **Streamlit**: Changes to `.py` files automatically reload (click "Always Rerun" in browser)
- **Flask**: Changes to API code automatically reload
- **Database**: SQL changes require container recreation (see Database Management section)

### Code Organization
- **Frontend pages**: Organized by role prefix (00-04: User, 10-13: Coach, 14-17: Dietitian, 20-24: Admin)
- **API routes**: Organized by feature in `api/backend/` subdirectories
- **Database**: SQL files executed alphabetically on container creation

### Adding New Features
1. **New API endpoint**: Add route in appropriate `api/backend/` subdirectory
2. **New frontend page**: Create page in `app/src/pages/` with appropriate prefix
3. **Update navigation**: Add link in `app/src/modules/nav.py`
4. **Database changes**: Add SQL to `database-files/` and recreate container

