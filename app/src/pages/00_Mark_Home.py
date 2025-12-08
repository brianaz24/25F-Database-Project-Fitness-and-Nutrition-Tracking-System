import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout = 'wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

user_id = st.session_state.get('user_id', 1)
first_name = st.session_state.get('first_name', 'Mark')
API_BASE = "http://web-api:4000"

st.title(f"Welcome, {st.session_state['first_name']}!")
st.write('')
st.write('')
st.write('### Your Fitness & Nutrition Dashboard')

# if st.button('View World Bank Data Visualization', 
#              type='primary',
#              use_container_width=True):
#   st.switch_page('pages/01_World_Bank_Viz.py')

# if st.button('View World Map Demo', 
#              type='primary',
#              use_container_width=True):
#   st.switch_page('pages/02_Map_Demo.py')

# Fetch quick stats
col1, col2, col3 = st.columns(3)

try:
    # Get goals
    goals_response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
    goals_count = 0
    if goals_response.status_code == 200:
        goals = goals_response.json()
        goals_count = len(goals) if isinstance(goals, list) else 0
    
    # Get workouts
    workouts_response = requests.get(f"{API_BASE}/clients/{user_id}/workouts")
    workouts_count = 0
    if workouts_response.status_code == 200:
        workouts = workouts_response.json()
        workouts_count = len(workouts) if isinstance(workouts, list) else 0
    
    # Get meals
    meals_response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
    meals_count = 0
    if meals_response.status_code == 200:
        meals = meals_response.json()
        meals_count = len(meals) if isinstance(meals, list) else 0
    
    with col1:
        st.metric("Active Goals", goals_count)
    
    with col2:
        st.metric("Total Workouts", workouts_count)
    
    with col3:
        st.metric("Meals Logged", meals_count)

except Exception as e:
    st.info("Stats will be available once you start logging data.")

st.write('')
st.write('')
st.write('### What would you like to do today?')

if st.button('Log a New Meal', type='primary', use_container_width=True):
    st.switch_page('pages/01_Mark_Log_Meal.py')

if st.button('Record a Workout', type='primary', use_container_width=True):
    st.switch_page('pages/02_Mark_Log_Workout.py')

if st.button('View My Progress', type='primary', use_container_width=True):
    st.switch_page('pages/03_Mark_View_Progress.py')

