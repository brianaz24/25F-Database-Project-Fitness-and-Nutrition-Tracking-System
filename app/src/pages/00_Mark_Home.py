import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import datetime, date, timedelta
from collections import defaultdict

st.set_page_config(layout='wide')

# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

user_id = st.session_state.get('user_id', 1)
first_name = st.session_state.get('first_name', 'Mark')
API_BASE = "http://web-api:4000"

st.title(f"Welcome, {first_name}!")
st.write('')

# Stats at the top
try:
    # Get goals
    goals_response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
    goals_data = []
    goals_count = 0
    if goals_response.status_code == 200:
        goals_data = goals_response.json()
        goals_count = len(goals_data) if isinstance(goals_data, list) else 0
    
    # Get workouts
    workouts_response = requests.get(f"{API_BASE}/clients/{user_id}/workouts")
    workouts_data = []
    workouts_count = 0
    if workouts_response.status_code == 200:
        workouts_data = workouts_response.json()
        workouts_count = len(workouts_data) if isinstance(workouts_data, list) else 0
    
    # Get meals
    meals_response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
    meals_data = []
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
        st.metric("🎯 Active Goals", goals_count)
    with col2:
        st.metric("🍽️ Meals Logged", meals_count)
    with col3:
        st.metric("💪 Workouts", workouts_count)
    with col4:
        st.metric("🔥 Today's Calories", f"{today_calories:,}")

except Exception as e:
    st.info("📊 Stats will be available once you start logging data.")

st.write('')
st.divider()

# Quick Actions
st.subheader("Quick Actions")
col1, col2, col3 = st.columns(3)
with col1:
    if st.button('Log a New Meal', type='primary', use_container_width=True):
        st.switch_page('pages/01_Mark_Log_Meal.py')
with col2:
    if st.button('Record a Workout', type='primary', use_container_width=True):
        st.switch_page('pages/02_Mark_Log_Workout.py')
with col3:
    if st.button('View My Progress', type='primary', use_container_width=True):
        st.switch_page('pages/03_Mark_View_Progress.py')

st.divider()

# Dashboard Sections
tab1, tab2, tab3 = st.tabs(["🎯 Active Goals", "🍽️ Recent Meals", "💪 Recent Workouts"])

# Goals Tab
with tab1:
    if goals_count > 0:
        st.write(f"### You have {goals_count} active goal(s)")
        for goal in goals_data:
            goal_type = goal.get('goal_type', 'Goal')
            start_time = goal.get('start_time', 'N/A')
            end_time = goal.get('end_time', 'N/A')
            goal_id = goal.get('goal_id')
            
            with st.container():
                st.markdown(f"""
                <div style='padding: 1rem; background-color: #f0f2f6; border-radius: 0.5rem; margin-bottom: 1rem;'>
                    <h4 style='margin: 0; color: #1f77b4;'>🎯 {goal_type}</h4>
                    <p style='margin: 0.5rem 0;'><strong>Start:</strong> {start_time} | <strong>Target End:</strong> {end_time if end_time != 'N/A' else 'Ongoing'}</p>
                    <p style='margin: 0; font-size: 0.9rem; color: #666;'>Goal ID: {goal_id}</p>
                </div>
                """, unsafe_allow_html=True)
    else:
        st.info("🎯 No active goals yet. Set a goal to start tracking your progress!")
        if st.button("➕ Set a New Goal", use_container_width=True):
            st.switch_page('pages/03_Mark_View_Progress.py')

# Meals Tab
with tab2:
    if meals_count > 0:
        # Group meals by date
        meals_by_date = defaultdict(list)
        for meal in meals_data:
            meal_date = meal.get('Meal_Date', 'Unknown')
            meals_by_date[meal_date].append(meal)
        
        st.write(f"### Recent Meals (Last 7 days)")
        
        # Show meals grouped by date
        for meal_date in sorted(meals_by_date.keys(), reverse=True)[:7]:
            day_meals = meals_by_date[meal_date]
            day_total_calories = sum(m.get('Calories', 0) for m in day_meals)
            
            # Parse date for better display
            try:
                date_obj = datetime.strptime(meal_date, '%Y-%m-%d')
                if date_obj.date() == date.today():
                    date_display = "Today"
                elif date_obj.date() == date.today() - timedelta(days=1):
                    date_display = "Yesterday"
                else:
                    date_display = date_obj.strftime('%A, %B %d')
            except:
                date_display = meal_date
            
            with st.expander(f"📅 {date_display} - {len(day_meals)} meal(s) - {day_total_calories} calories", expanded=(date_display == "Today")):
                for meal in day_meals:
                    meal_name = meal.get('Meal_Name', 'Meal')
                    meal_time = meal.get('Meal_Time', 'N/A')
                    calories = meal.get('Calories', 0)
                    meal_id = meal.get('Meal_ID')
                    
                    col_meal1, col_meal2, col_meal3 = st.columns([3, 2, 1])
                    with col_meal1:
                        st.write(f"**{meal_name}**")
                    with col_meal2:
                        st.write(f"🕐 {meal_time}")
                    with col_meal3:
                        st.write(f"🔥 {calories} cal")
    else:
        st.info("🍽️ No meals logged yet. Start tracking your nutrition!")
        if st.button("➕ Log Your First Meal", use_container_width=True):
            st.switch_page('pages/01_Mark_Log_Meal.py')

# Workouts Tab
with tab3:
    if workouts_count > 0:
        # Group workouts by date
        workouts_by_date = defaultdict(list)
        for workout in workouts_data:
            workout_date = workout.get('Workout_Date', 'Unknown')
            workouts_by_date[workout_date].append(workout)
        
        st.write(f"### Recent Workouts (Last 7 days)")
        
        # Show workouts grouped by date
        for workout_date in sorted(workouts_by_date.keys(), reverse=True)[:7]:
            day_workouts = workouts_by_date[workout_date]
            day_total_duration = sum(w.get('Duration_Minutes', 0) for w in day_workouts if w.get('Duration_Minutes'))
            day_total_calories = sum(w.get('Calories_Burned', 0) for w in day_workouts if w.get('Calories_Burned'))
            
            # Parse date for better display
            try:
                date_obj = datetime.strptime(workout_date, '%Y-%m-%d')
                if date_obj.date() == date.today():
                    date_display = "Today"
                elif date_obj.date() == date.today() - timedelta(days=1):
                    date_display = "Yesterday"
                else:
                    date_display = date_obj.strftime('%A, %B %d')
            except:
                date_display = workout_date
            
            with st.expander(f"📅 {date_display} - {len(day_workouts)} workout(s) - {day_total_duration} min - {day_total_calories} cal burned", expanded=(date_display == "Today")):
                for workout in day_workouts:
                    workout_type = workout.get('Workout_Type', 'Workout')
                    duration = workout.get('Duration_Minutes', 0)
                    calories = workout.get('Calories_Burned', 0)
                    workout_id = workout.get('Workout_ID')
                    notes = workout.get('Notes', '')
                    
                    col_w1, col_w2, col_w3 = st.columns([3, 2, 2])
                    with col_w1:
                        st.write(f"**{workout_type}**")
                        if notes:
                            st.caption(notes[:50] + "..." if len(notes) > 50 else notes)
                    with col_w2:
                        st.write(f"⏱️ {duration} minutes" if duration else "Duration not logged")
                    with col_w3:
                        st.write(f"🔥 {calories} cal" if calories else "Calories not logged")
    else:
        st.info("💪 No workouts logged yet. Start your fitness journey!")
        if st.button("➕ Record Your First Workout", use_container_width=True):
            st.switch_page('pages/02_Mark_Log_Workout.py')

