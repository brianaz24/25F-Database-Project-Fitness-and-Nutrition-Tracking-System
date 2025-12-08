##################################################
# This is the main/entry-point file for the 
# sample application for your project
##################################################

# Set up basic logging infrastructure
import logging
logging.basicConfig(format='%(filename)s:%(lineno)s:%(levelname)s -- %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# import the main streamlit library as well
# as SideBarLinks function from src/modules folder
import streamlit as st
from modules.nav import SideBarLinks

# streamlit supports reguarl and wide layout (how the controls
# are organized/displayed on the screen).
st.set_page_config(layout = 'wide')

# If a user is at this page, we assume they are not 
# authenticated.  So we change the 'authenticated' value
# in the streamlit session_state to false. 
st.session_state['authenticated'] = False

# Use the SideBarLinks function from src/modules/nav.py to control
# the links displayed on the left-side panel. 
# IMPORTANT: ensure src/.streamlit/config.toml sets
# showSidebarNavigation = false in the [client] section
SideBarLinks(show_home=True)

# ***************************************************
#    The major content of this page
# ***************************************************

# set the title of the page and provide a simple prompt. 
logger.info("Loading the Home page of the app")
st.title('Fitness & Nutrition Tracking System')
st.write('\n\n')
st.write('#### Welcome! Please select your role and user to log in.')

# Define mock users for each persona
everyday_users = {
    "Mark": {"first_name": "Mark", "user_id": 1},
    "Sarah": {"first_name": "Sarah", "user_id": 2},
    "Alex": {"first_name": "Alex", "user_id": 3}
}

fitness_coaches = {
    "Sam": {"first_name": "Sam", "user_id": 10},
    "Coach Mike": {"first_name": "Mike", "user_id": 11},
    "Trainer Lisa": {"first_name": "Lisa", "user_id": 12}
}

dietitians = {
    "Jame": {"first_name": "Jame", "user_id": 20},
    "Dr. Smith": {"first_name": "Smith", "user_id": 21},
    "Nutritionist Emma": {"first_name": "Emma", "user_id": 22}
}

system_admins = {
    "Eva": {"first_name": "Eva", "user_id": 30},
    "Admin John": {"first_name": "John", "user_id": 31},
    "IT Manager Maria": {"first_name": "Maria", "user_id": 32}
}

# Create select widgets for each persona
st.write("### Everyday User")
selected_everyday_user = st.selectbox(
    "Select an Everyday User:",
    ["-- Select User --"] + list(everyday_users.keys()),
    key="everyday_user_select"
)

st.write("### Fitness Coach")
selected_coach = st.selectbox(
    "Select a Fitness Coach:",
    ["-- Select User --"] + list(fitness_coaches.keys()),
    key="coach_select"
)

st.write("### Dietitian Data Analyst")
selected_dietitian = st.selectbox(
    "Select a Dietitian:",
    ["-- Select User --"] + list(dietitians.keys()),
    key="dietitian_select"
)

st.write("### System Administrator")
selected_admin = st.selectbox(
    "Select a System Administrator:",
    ["-- Select User --"] + list(system_admins.keys()),
    key="admin_select"
)

# Login button
st.write("---")
if st.button("Login", type='primary', use_container_width=True):
    # Check which persona was selected
    if selected_everyday_user != "-- Select User --":
        user_info = everyday_users[selected_everyday_user]
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'everyday_user'
        st.session_state['first_name'] = user_info['first_name']
        st.session_state['user_id'] = user_info['user_id']
        logger.info(f"Logging in as Everyday User: {user_info['first_name']}")
        st.switch_page('pages/00_Mark_Home.py')
    
    elif selected_coach != "-- Select User --":
        user_info = fitness_coaches[selected_coach]
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'fitness_coach'
        st.session_state['first_name'] = user_info['first_name']
        st.session_state['user_id'] = user_info['user_id']
        logger.info(f"Logging in as Fitness Coach: {user_info['first_name']}")
        st.switch_page('pages/10_Sam_Home.py')
    
    elif selected_dietitian != "-- Select User --":
        user_info = dietitians[selected_dietitian]
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'dietitian'
        st.session_state['first_name'] = user_info['first_name']
        st.session_state['user_id'] = user_info['user_id']
        logger.info(f"Logging in as Dietitian: {user_info['first_name']}")
        st.switch_page('pages/20_Jame_Home.py')
    
    elif selected_admin != "-- Select User --":
        user_info = system_admins[selected_admin]
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'administrator'
        st.session_state['first_name'] = user_info['first_name']
        st.session_state['user_id'] = user_info['user_id']
        logger.info(f"Logging in as System Administrator: {user_info['first_name']}")
        st.switch_page('pages/30_Eva_Home.py')
    
    else:
        st.error("Please select a user from one of the roles above.")



