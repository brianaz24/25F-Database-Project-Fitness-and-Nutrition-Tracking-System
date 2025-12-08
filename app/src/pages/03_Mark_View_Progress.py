import logging
import streamlit as st
import requests
from datetime import datetime, date, timedelta
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

SideBarLinks()

st.title("My Progress & Goals")

user_id = st.session_state.get('user_id', 1)
API_BASE = "http://web-api:4000"


# Tabs for different views
tab1, tab2, tab3 = st.tabs(["Goals", "Edit Records", "Delete Records"])

# Goals
with tab1:
    st.subheader("My Goals")

    try:
        response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
        
        if response.status_code == 200:
            goals = response.json()
            if goals and len(goals) > 0:
                st.write(f"**You have {len(goals)} goal(s):**")
                for goal in goals:
                    goal_id = goal.get('goal_id')
                    goal_type = goal.get('goal_type') or goal.get('Goal_Type', 'Goal')
                    start_time = goal.get('start_time', 'N/A')
                    end_time = goal.get('end_time', 'N/A')
                    
                    with st.expander(f"🎯 {goal_type} - Start: {start_time} - End: {end_time} (ID: {goal_id})"):
                        col1, col2 = st.columns(2)
                        with col1:
                            st.write(f"**Goal Type:** {goal_type}")
                            st.write(f"**Start Date:** {start_time}")
                        with col2:
                            st.write(f"**End Date:** {end_time if end_time != 'N/A' else 'Ongoing'}")
                        
                        # Edit Goal Form
                        with st.form(f"edit_goal_{goal_id}"):
                            st.write("**Edit Goal:**")
                            new_goal_type = st.selectbox(
                                "Goal Type",
                                ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"],
                                index=["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"].index(goal_type) if goal_type in ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"] else 0,
                                key=f"goal_type_{goal_id}"
                            )
                            new_start_time = st.date_input(
                                "Start Date",
                                value=datetime.strptime(start_time, '%Y-%m-%d').date() if start_time and start_time != 'N/A' and '-' in str(start_time) else date.today(),
                                key=f"start_time_{goal_id}"
                            )
                            new_end_time = st.date_input(
                                "End Date (Optional)",
                                value=datetime.strptime(end_time, '%Y-%m-%d').date() if end_time and end_time != 'N/A' and '-' in str(end_time) else None,
                                key=f"end_time_{goal_id}"
                            )
                            
                            if st.form_submit_button("Update Goal", use_container_width=True):
                                update_data = {
                                    "Goal_Type": new_goal_type,
                                    "start_time": str(new_start_time),
                                    "end_time": str(new_end_time) if new_end_time else None
                                }
                                
                                try:
                                    update_response = requests.put(f"{API_BASE}/clients/goals/{goal_id}", json=update_data)
                                    if update_response.status_code == 200:
                                        st.success("Goal updated successfully!")
                                        st.rerun()
                                    else:
                                        error_msg = update_response.json().get('error', 'Unknown error')
                                        st.error(f"Failed to update goal: {error_msg}")
                                except Exception as e:
                                    st.error(f"Error: {str(e)}")
                        
                        # Delete button outside the form
                        if st.button("🗑️ Delete Goal", key=f"delete_goal_{goal_id}", type='secondary', use_container_width=True):
                            try:
                                del_response = requests.delete(f"{API_BASE}/clients/goals/{goal_id}")
                                if del_response.status_code == 200:
                                    st.success("Goal deleted successfully!")
                                    st.rerun()
                                else:
                                    error_msg = del_response.json().get('error', 'Unknown error')
                                    st.error(f"Failed to delete goal: {error_msg}")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No goals set yet.")
        else:
            st.info("Unable to load goals.")
    except Exception as e:
        st.info(f"Unable to load goals: {str(e)}")
    
    st.write("---")
    st.subheader("Set a New Goal")
    
    with st.form("create_goal_form"):
        goal_type = st.selectbox("Goal Type *", ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"])
        start_date = st.date_input("Start Date *", value=date.today())
        end_date = st.date_input("End Date (Optional)", value=date.today() + timedelta(days=30))
        
        submitted = st.form_submit_button("Create Goal", type='primary')
        
        if submitted:
            if not goal_type:
                st.error("Please fill in all required fields.")
            else:
                goal_data = {
                    "User_ID": user_id,
                    "Goal_Type": goal_type,
                    "start_time": str(start_date),
                    "end_time": str(end_date) if end_date else None
                }
                
                try:
                    response = requests.post(f"{API_BASE}/clients/goals", json=goal_data)
                    
                    if response.status_code == 201:
                        st.success("Goal created successfully!")
                        st.rerun()
                    else:
                        error_msg = response.json().get('error', 'Unknown error')
                        st.error(f"Failed to create goal: {error_msg}")
                
                except Exception as e:
                    st.error(f"Error: {str(e)}")

# Edit Records
with tab2:
    st.subheader("Edit Meal Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            if meals and len(meals) > 0:
                st.write(f"**You have {len(meals)} meal record(s). Showing all meals:**")
                for meal in meals:
                    meal_id = meal.get('Meal_ID')
                    meal_name = meal.get('Meal_Name', 'Meal')
                    meal_date = meal.get('Meal_Date', '')
                    meal_time = meal.get('Meal_Time', '')
                    calories = meal.get('Calories', 0)
                    
                    with st.expander(f"🍽️ {meal_name} - {meal_date} {meal_time} - {calories} cal (ID: {meal_id})"):
                        with st.form(f"edit_meal_{meal_id}"):
                            new_name = st.text_input("Meal Name", value=meal_name, key=f"meal_name_{meal_id}")
                            new_calories = st.number_input("Calories", value=int(calories) if calories else 0, key=f"calories_{meal_id}")
                            new_date = st.date_input(
                                "Date",
                                value=datetime.strptime(meal_date, '%Y-%m-%d').date() if meal_date and '-' in str(meal_date) else date.today(),
                                key=f"date_{meal_id}"
                            )
                            new_time = st.time_input(
                                "Time",
                                value=datetime.strptime(meal_time, '%H:%M:%S').time() if meal_time and ':' in str(meal_time) else datetime.now().time(),
                                key=f"time_{meal_id}"
                            )
                            
                            if st.form_submit_button("Update Meal", use_container_width=True):
                                update_data = {
                                    "Meal_Name": new_name,
                                    "Calories": new_calories,
                                    "Meal_Date": str(new_date),
                                    "Meal_Time": str(new_time)
                                }
                                
                                try:
                                    update_response = requests.put(f"{API_BASE}/meals/{meal_id}", json=update_data)
                                    if update_response.status_code == 200:
                                        st.success("Meal updated successfully!")
                                        st.rerun()
                                    else:
                                        error_msg = update_response.json().get('error', 'Unknown error')
                                        st.error(f"Failed to update meal: {error_msg}")
                                except Exception as e:
                                    st.error(f"Error: {str(e)}")
            else:
                st.info("No meals to edit yet. Log some meals first!")
        else:
            st.info("Unable to load meals.")
    except Exception as e:
        st.info(f"Unable to load meals: {str(e)}")

# Delete Records
with tab3:
    st.subheader("Delete Meal Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            if meals and len(meals) > 0:
                st.write(f"**You have {len(meals)} meal record(s). Select meals to delete:**")
                for meal in meals:
                    col1, col2 = st.columns([4, 1])
                    with col1:
                        meal_name = meal.get('Meal_Name', 'Meal')
                        meal_date = meal.get('Meal_Date', '')
                        meal_time = meal.get('Meal_Time', '')
                        calories = meal.get('Calories', 0)
                        meal_id = meal.get('Meal_ID')
                        st.write(f"🍽️ **{meal_name}** - {meal_date} {meal_time} - {calories} cal (ID: {meal_id})")
                    with col2:
                        if st.button("🗑️ Delete", key=f"del_meal_{meal_id}", type='secondary', use_container_width=True):
                            try:
                                del_response = requests.delete(f"{API_BASE}/meals/{meal_id}")
                                if del_response.status_code == 200:
                                    st.success("Meal deleted successfully!")
                                    st.rerun()
                                else:
                                    error_msg = del_response.json().get('error', 'Unknown error')
                                    st.error(f"Failed to delete meal: {error_msg}")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No meals to delete yet. Log some meals first!")
        else:
            st.info("Unable to load meals.")
    except Exception as e:
        st.info(f"Unable to load meals: {str(e)}")
    
    st.write("---")
    st.subheader("Delete Goal Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
        
        if response.status_code == 200:
            goals = response.json()
            if goals and len(goals) > 0:
                st.write(f"**You have {len(goals)} goal(s). Select goals to delete:**")
                for goal in goals:
                    col1, col2 = st.columns([4, 1])
                    with col1:
                        goal_id = goal.get('goal_id')
                        goal_type = goal.get('goal_type') or goal.get('Goal_Type', 'Goal')
                        start_time = goal.get('start_time', 'N/A')
                        end_time = goal.get('end_time', 'N/A')
                        st.write(f"🎯 **{goal_type}** - Start: {start_time} - End: {end_time if end_time != 'N/A' else 'Ongoing'} (ID: {goal_id})")
                    with col2:
                        if st.button("🗑️ Delete", key=f"del_goal_{goal_id}", type='secondary', use_container_width=True):
                            try:
                                del_response = requests.delete(f"{API_BASE}/clients/goals/{goal_id}")
                                if del_response.status_code == 200:
                                    st.success("Goal deleted successfully!")
                                    st.rerun()
                                else:
                                    error_msg = del_response.json().get('error', 'Unknown error')
                                    st.error(f"Failed to delete goal: {error_msg}")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No goals to delete yet.")
        else:
            st.info("Unable to load goals.")
    except Exception as e:
        st.info(f"Unable to load goals: {str(e)}")
    
    st.write("---")
    st.subheader("Delete Workout Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/{user_id}/workouts")
        
        if response.status_code == 200:
            workouts = response.json()
            if workouts and len(workouts) > 0:
                st.write(f"**You have {len(workouts)} workout record(s). Select workouts to delete:**")
                for workout in workouts:
                    col1, col2 = st.columns([4, 1])
                    with col1:
                        workout_type = workout.get('Workout_Type', 'Workout')
                        workout_date = workout.get('Workout_Date', '')
                        workout_id = workout.get('Workout_ID')
                        duration = workout.get('Duration_Minutes', 0)
                        st.write(f"💪 **{workout_type}** - {workout_date} - {duration} min (ID: {workout_id})")
                    with col2:
                        if st.button("🗑️ Delete", key=f"del_workout_{workout_id}", type='secondary', use_container_width=True):
                            try:
                                del_response = requests.delete(f"{API_BASE}/workouts/{workout_id}")
                                if del_response.status_code == 200:
                                    st.success("Workout deleted successfully!")
                                    st.rerun()
                                else:
                                    error_msg = del_response.json().get('error', 'Unknown error')
                                    st.error(f"Failed to delete workout: {error_msg}")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No workouts to delete yet.")
        else:
            st.info("Unable to load workouts.")
    except Exception as e:
        st.info(f"Unable to load workouts: {str(e)}")

if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

