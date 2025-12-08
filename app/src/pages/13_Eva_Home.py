import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import date

st.set_page_config(layout='wide')
SideBarLinks()

user_id = st.session_state.get('user_id', 30)
first_name = st.session_state.get('first_name', 'Eva')
API_BASE = "http://web-api:4000"

st.title(f"Welcome, Admin {first_name}!")
st.write('')

# System Metrics Dashboard
st.subheader("System Overview")

try:
    # Get user counts
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        try:
            users_response = requests.get(f"{API_BASE}/admin/users")
            user_count = 0
            if users_response.status_code == 200:
                users = users_response.json()
                user_count = len(users) if isinstance(users, list) else 0
            st.metric("Total Users", user_count)
        except:
            st.metric("Total Users", "N/A")
    
    with col2:
        try:
            meals_response = requests.get(f"{API_BASE}/meals")
            meal_count = 0
            if meals_response.status_code == 200:
                meals = meals_response.json()
                meal_count = len(meals) if isinstance(meals, list) else 0
            st.metric("Total Meals Logged", meal_count)
        except:
            st.metric("Total Meals Logged", "N/A")
    
    with col3:
        try:
            workouts_response = requests.get(f"{API_BASE}/workouts")
            workout_count = 0
            if workouts_response.status_code == 200:
                workouts = workouts_response.json()
                workout_count = len(workouts) if isinstance(workouts, list) else 0
            st.metric("Total Workouts", workout_count)
        except:
            st.metric("Total Workouts", "N/A")
    
    with col4:
        try:
            plans_response = requests.get(f"{API_BASE}/plans")
            plan_count = 0
            if plans_response.status_code == 200:
                plans = plans_response.json()
                plan_count = len(plans) if isinstance(plans, list) else 0
            st.metric("Active Plans", plan_count)
        except:
            st.metric("Active Plans", "N/A")

except Exception as e:
    st.info("Loading system metrics...")
    logger.error(f"Error fetching system stats: {str(e)}")

st.write('')
st.divider()

# Quick Actions
st.subheader("Admin Actions")

col1, col2, col3 = st.columns(3)

with col1:
    if st.button('👥 Manage Users', type='primary', use_container_width=True):
        st.switch_page('pages/14_Eva_Users.py')
    if st.button('📊 System Monitoring', use_container_width=True):
        st.switch_page('pages/17_ML_Model_Mgmt.py')

with col2:
    if st.button('💾 Database Management', type='primary', use_container_width=True):
        st.switch_page('pages/16_Eva_Database.py')
    if st.button('📈 View Analytics', use_container_width=True):
        st.info("System analytics dashboard coming soon")

with col3:
    if st.button('🔔 System Alerts', type='primary', use_container_width=True):
        try:
            alerts_response = requests.get(f"{API_BASE}/admin/alerts")
            if alerts_response.status_code == 200:
                alerts = alerts_response.json()
                if alerts and len(alerts) > 0:
                    st.warning(f"{len(alerts)} system alerts require attention")
                else:
                    st.success("No active alerts")
            else:
                st.info("No alerts at this time")
        except:
            st.info("Checking system alerts...")
    
    if st.button('⚙️ System Settings', use_container_width=True):
        st.info("System settings coming soon")

st.write('')
st.divider()

# Recent Activity Feed
st.subheader("Recent System Activity")

try:
    # Display recent meals
    meals_response = requests.get(f"{API_BASE}/meals")
    if meals_response.status_code == 200:
        meals = meals_response.json()
        if meals and isinstance(meals, list) and len(meals) > 0:
            st.write("**Recent Meal Logs:**")
            for meal in meals[-5:]:  # Last 5 meals
                col1, col2, col3 = st.columns([2, 2, 1])
                with col1:
                    st.write(f"🍽️ {meal.get('Meal_Name', 'Meal')}")
                with col2:
                    st.caption(f"User ID: {meal.get('User_ID')} | {meal.get('Meal_Date', 'N/A')}")
                with col3:
                    st.caption(f"{meal.get('Calories', 0)} cal")
        else:
            st.info("No recent meal logs")
    
    st.write('')
    
    # Display recent workouts
    workouts_response = requests.get(f"{API_BASE}/workouts")
    if workouts_response.status_code == 200:
        workouts = workouts_response.json()
        if workouts and isinstance(workouts, list) and len(workouts) > 0:
            st.write("**Recent Workout Logs:**")
            for workout in workouts[-5:]:  # Last 5 workouts
                col1, col2, col3 = st.columns([2, 2, 1])
                with col1:
                    st.write(f"💪 {workout.get('Workout_Type', 'Workout')}")
                with col2:
                    st.caption(f"User ID: {workout.get('User_ID')} | {workout.get('Workout_Date', 'N/A')}")
                with col3:
                    st.caption(f"{workout.get('Duration_Minutes', 0)} min")
        else:
            st.info("No recent workout logs")

except Exception as e:
    st.info("Loading recent activity...")
    logger.error(f"Error fetching recent activity: {str(e)}")

