import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import date

st.set_page_config(layout='wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

user_id = st.session_state.get('user_id', 1)
first_name = st.session_state.get('first_name', 'Mark')
API_BASE = "http://web-api:4000"

st.title(f"Welcome, {first_name}!")
st.write('')
st.write("### Your Fitness & Nutrition Overview")

# Stats at the top
try:
    # Get goals
    goals_response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
    goals_count = 0
    if goals_response.status_code == 200:
        goals_data = goals_response.json()
        goals_count = len(goals_data) if isinstance(goals_data, list) else 0
    
    # Get workouts
    workouts_response = requests.get(f"{API_BASE}/clients/{user_id}/workouts")
    workouts_count = 0
    if workouts_response.status_code == 200:
        workouts_data = workouts_response.json()
        workouts_count = len(workouts_data) if isinstance(workouts_data, list) else 0
    
    # Get meals
    meals_response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
    meals_count = 0
    today_calories = 0
    today_date_str = date.today().strftime('%Y-%m-%d')
    if meals_response.status_code == 200:
        meals_data = meals_response.json()
        meals_count = len(meals_data) if isinstance(meals_data, list) else 0
        # Calculate only today's calories
        today_calories = sum(
            meal.get('Calories', 0) 
            for meal in meals_data 
            if meal.get('Meal_Date') == today_date_str
        )
    
    # Display metrics
    col1, col2, col3, col4 = st.columns(4)
    with col1:
        st.metric("Active Goals", goals_count)
    with col2:
        st.metric("Meals Logged", meals_count)
    with col3:
        st.metric("Workouts", workouts_count)
    with col4:
        st.metric("Today's Calories", f"{today_calories:,}")

except Exception as e:
    st.info("Stats will be available once you start logging data.")

st.write('')
st.divider()

# Quick Actions - Main Navigation
st.subheader("What would you like to do?")
st.write('')

col1, col2 = st.columns(2)

with col1:
    if st.button('🍽️ Log a New Meal', type='primary', use_container_width=True):
        st.switch_page('pages/01_Mark_Log_Meal.py')

    if st.button('💪 Record a Workout', type='primary', use_container_width=True):
        st.switch_page('pages/02_Mark_Log_Workout.py')

with col2:
    if st.button('📊 View My Progress', type='primary', use_container_width=True):
        st.switch_page('pages/03_Mark_View_Progress.py')
    
    if st.button('🎯 Manage My Goals', type='primary', use_container_width=True):
        st.switch_page('pages/04_Mark_Goals.py')

st.write('')
st.divider()

# Quick Summary
st.subheader("Today's Summary")

col1, col2 = st.columns(2)

with col1:
    st.write("**Recent Activity:**")
    try:
        # Show today's meals
        if meals_response.status_code == 200:
            today_meals = [m for m in meals_data if m.get('Meal_Date') == today_date_str]
            if today_meals:
                st.write(f"✓ Logged {len(today_meals)} meal(s) today")
            else:
                st.info("No meals logged today")
        
        # Show today's workouts  
        if workouts_response.status_code == 200:
            today_workouts = [w for w in workouts_data if w.get('Workout_Date') == today_date_str]
            if today_workouts:
                st.write(f"✓ Completed {len(today_workouts)} workout(s) today")
            else:
                st.info("No workouts logged today")
    except:
        st.info("Activity summary will appear here")

with col2:
    st.write("**Your Goals:**")
    try:
        if goals_count > 0:
            st.write(f"✓ You have {goals_count} active goal(s)")
            if st.button("View Goal Details"):
                st.switch_page('pages/04_Mark_Goals.py')
        else:
            st.info("No goals set yet")
            if st.button("Set Your First Goal"):
                st.switch_page('pages/04_Mark_Goals.py')
    except:
        st.info("Goals will appear here")

st.write('')
st.info("💡 **Tip:** Use the sidebar to quickly navigate between different sections!")

