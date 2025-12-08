# Pages Folder

This folder contains all the Streamlit pages that make up the Fitness & Nutrition Tracking System application. Each page represents a distinct feature or view accessible to users based on their role.

## Page Organization

Pages are organized by **role prefix** using numeric prefixes. This organization helps maintain clear separation between different user personas and their respective functionalities.

### Page Numbering System

Streamlit automatically orders pages alphabetically by filename. We use numeric prefixes to control the order:

- **00-04**: Everyday User (Mark) pages
- **05-08**: Fitness Coach (Sam) pages  
- **09-12**: Dietitian (James) pages
- **13-17**: System Administrator (Eva) pages
- **18+**: Shared/General pages (About, etc.)

### Page Ordering in Streamlit

Streamlit's multipage app feature automatically creates navigation based on:
1. **Alphabetical filename order** - Pages are sorted by filename
2. **Page title** - The first `st.title()` or `st.header()` in the file
3. **Icon** - Can be set via `st.set_page_config(icon="...")`

**Important**: The numeric prefix ensures pages appear in the correct order in Streamlit's sidebar navigation.

For more information, see: [Streamlit Multipage Apps Documentation](https://docs.streamlit.io/library/get-started/multipage-apps)

## Role-Based Pages

### Everyday User (Mark) - Pages 00-04

| File | Page Name | Description |
|------|-----------|-------------|
| `00_Mark_Home.py` | My Dashboard | Overview dashboard with metrics and quick actions |
| `01_Mark_Log_Meal.py` | Log Meal | Create new meal entries with calories and timing |
| `02_Mark_Log_Workout.py` | Log Workout | Record workout sessions with duration and calories burned |
| `03_Mark_View_Progress.py` | View Progress | Edit and delete meal/workout records |
| `04_Mark_Goals.py` | Manage Goals | Create, edit, and track fitness/nutrition goals |

**Features**: Full CRUD operations for personal data (meals, workouts, goals)

### Fitness Coach (Sam) - Pages 05-08

| File | Page Name | Description |
|------|-----------|-------------|
| `05_Sam_HomePage.py` | Coach Dashboard | Overview of plans, exercises, and client alerts |
| `06_Sam_Client_Progress.py` | Client Progress | Monitor client workouts, nutrition, and leave comments |
| `07_Sam_Manage_Plans.py` | Manage Plans | Create, view, and assign workout plans to clients |
| `08_Sam_View_Alert.py` | Notifications | View alerts, track missed workouts, send custom notifications |

**Features**: Client monitoring, plan management, notification system

### Dietitian (James) - Pages 09-12

| File | Page Name | Description |
|------|-----------|-------------|
| `09_James_Home.py` | Dietitian Dashboard | Overview of client meals and nutrition insights |
| `10_James_Client_Meals.py` | Client Meals | View meals, leave comments, correct inaccurate entries |
| `11_James_Analytics.py` | Analytics | Nutrition trends, meal patterns, client comparisons |
| `12_James_Meal_Plans.py` | Meal Plans | Create personalized meal plans and recommendations |

**Features**: Nutrition analysis, meal plan creation, data visualization

### System Administrator (Eva) - Pages 13-17

| File | Page Name | Description |
|------|-----------|-------------|
| `13_Eva_Home.py` | Admin Dashboard | System overview with metrics and activity feed |
| `14_Eva_Users.py` | User Management | View, add, and manage system users |
| `15_Eva_Audit.py` | Audit & Security | Review audit logs, monitor user activity, security events |
| `16_Eva_Database.py` | Database Management | Backup, restore, and cleanup operations |
| `17_ML_Model_Mgmt.py` | System Monitoring | API health checks, ML model management, system alerts |

**Features**: System administration, user management, database operations, security monitoring

### General Pages - 18+

| File | Page Name | Description |
|------|-----------|-------------|
| `18_About.py` | About | Application information and credits |

## Role-Based Access Control (RBAC)

Pages are protected by role-based access control implemented in `app/src/modules/nav.py`. The navigation sidebar dynamically displays only the pages relevant to the user's current role.

**How it works:**
1. User selects role on the home page (`Home.py`)
2. Role is stored in `st.session_state['role']`
3. `SideBarLinks()` function filters pages based on role
4. Only authorized pages appear in the sidebar

See `app/src/modules/nav.py` for implementation details.

## Creating New Pages

When adding new pages:

1. **Use appropriate prefix**: Follow the numbering system (00-04 for users, 05-08 for coaches, 09-12 for dietitians, 13-17 for admins, 18+ for general)
2. **Include navigation**: Add page link in `app/src/modules/nav.py`
3. **Set page config**: Include `st.set_page_config()` at the top
4. **Add SideBarLinks()**: Call `SideBarLinks()` to enable RBAC
5. **Follow naming convention**: Use descriptive names like `XX_Role_Feature.py`

**Example:**
```python
import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("My New Page")
# ... rest of page code
```

## Related Documentation

- **Streamlit Multipage Apps**: https://docs.streamlit.io/library/get-started/multipage-apps
- **Streamlit Navigation**: https://docs.streamlit.io/library/api-reference/navigation
- **Main README**: See `/README.md` for project overview and setup instructions
- **Navigation Module**: See `/app/src/modules/nav.py` for RBAC implementation

## Page Statistics

- **Total Pages**: 19 pages
- **Everyday User Pages**: 5 pages (including home)
- **Coach Pages**: 4 pages (including home)
- **Dietitian Pages**: 4 pages (including home)
- **Admin Pages**: 5 pages (including home)
- **General Pages**: 1 page

## HTTP Method Coverage

All pages collectively use the full range of HTTP methods:
- **GET**: Reading data (meals, workouts, goals, users, etc.)
- **POST**: Creating new records (meals, workouts, goals, plans, comments)
- **PUT**: Updating existing records (meals, goals)
- **DELETE**: Removing records (meals, workouts, goals, plans, users)

