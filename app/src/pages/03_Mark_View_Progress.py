import logging
import streamlit as st
import requests
import pandas as pd
from datetime import datetime, date, timedelta
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

SideBarLinks()

st.title("My Progress & Goals")

user_id = st.session_state.get('user_id', 1)
API_BASE = "http://web-api:4000"


# Tabs for different views
tab1, tab2, tab3, tab4 = st.tabs(["Weight Trends", "Goals", "Edit Records", "Delete Records"])

# Weight Trends
with tab1:
    st.subheader("Weight Trend Visualization")
    
    try:
        response = requests.get(f"{API_BASE}/workouts/metrics/weight", params={"user_id": user_id})
        
        if response.status_code == 200:
            weight_data = response.json()
            if weight_data and len(weight_data) > 0:
                df = pd.DataFrame(weight_data)
                if 'Weight_Date' in df.columns and 'Weight' in df.columns:
                    df['Weight_Date'] = pd.to_datetime(df['Weight_Date'])
                    df = df.sort_values('Weight_Date')
                    st.line_chart(df.set_index('Weight_Date')['Weight'])
                    st.dataframe(df, use_container_width=True)
                else:
                    st.info("Weight data available but columns may differ. Displaying raw data:")
                    st.dataframe(df, use_container_width=True)
            else:
                st.info("No weight data available yet. Start tracking your weight to see trends here.")
        else:
            st.info("Weight tracking feature coming soon!")
    
    except Exception as e:
        st.info("Weight tracking feature coming soon!")

# Goals
with tab2:
    st.subheader("My Goals")

    try:
        response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
        
        if response.status_code == 200:
            goals = response.json()
            if goals and len(goals) > 0:
                st.write("**Current Goals:**")
                for goal in goals:
                    with st.expander(f"{goal.get('Goal_Type', 'Goal')} - Target: {goal.get('Target_Value', 'N/A')}"):
                        st.write(f"**Description:** {goal.get('Description', 'No description')}")
                        if goal.get('Target_Date'):
                            st.write(f"**Target Date:** {goal.get('Target_Date')}")
            else:
                st.info("No goals set yet.")
        else:
            st.info("Unable to load goals.")
    except Exception as e:
        st.info("Unable to load goals.")
    
    st.write("---")
    st.subheader("Set a New Goal")
    
    with st.form("create_goal_form"):
        goal_type = st.selectbox("Goal Type *", ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"])
        target_value = st.number_input("Target Value *", min_value=0.0, step=0.1)
        target_date = st.date_input("Target Date", value=date.today() + timedelta(days=30))
        description = st.text_area("Description", placeholder="Describe your goal...")
        
        submitted = st.form_submit_button("Create Goal", type='primary')
        
        if submitted:
            if not goal_type or target_value == 0:
                st.error("Please fill in all required fields.")
            else:
                goal_data = {
                    "User_ID": user_id,
                    "Goal_Type": goal_type,
                    "Target_Value": target_value,
                    "Target_Date": str(target_date),
                    "Description": description if description else None
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
with tab3:
    st.subheader("Edit Meal Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            if meals and len(meals) > 0:
                for meal in meals[:10]:  
                    with st.expander(f"{meal.get('Meal_Name', 'Meal')} - {meal.get('Meal_Date', '')} - {meal.get('Calories', 0)} cal"):
                        meal_id = meal.get('Meal_ID')
                        
                        with st.form(f"edit_meal_{meal_id}"):
                            new_name = st.text_input("Meal Name", value=meal.get('Meal_Name', ''))
                            new_calories = st.number_input("Calories", value=int(meal.get('Calories', 0)) if meal.get('Calories') else 0)
                            new_date = st.date_input("Date", value=datetime.strptime(meal.get('Meal_Date', str(date.today())), '%Y-%m-%d').date() if meal.get('Meal_Date') else date.today())
                            
                            if st.form_submit_button("Update Meal"):
                                update_data = {
                                    "Meal_Name": new_name,
                                    "Calories": new_calories,
                                    "Meal_Date": str(new_date)
                                }
                                
                                try:
                                    update_response = requests.put(f"{API_BASE}/meals/{meal_id}", json=update_data)
                                    if update_response.status_code == 200:
                                        st.success("Meal updated successfully!")
                                        st.rerun()
                                    else:
                                        st.error("Failed to update meal.")
                                except Exception as e:
                                    st.error(f"Error: {str(e)}")
            else:
                st.info("No meals to edit yet.")
        else:
            st.info("Unable to load meals.")
    except Exception as e:
        st.info("Unable to load meals.")

# Delete Records
with tab4:
    st.subheader("Delete Meal Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/{user_id}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            if meals and len(meals) > 0:
                for meal in meals[:10]:
                    col1, col2 = st.columns([3, 1])
                    with col1:
                        st.write(f"**{meal.get('Meal_Name', 'Meal')}** - {meal.get('Meal_Date', '')} - {meal.get('Calories', 0)} cal")
                    with col2:
                        meal_id = meal.get('Meal_ID')
                        if st.button("Delete", key=f"del_meal_{meal_id}", type='secondary'):
                            try:
                                del_response = requests.delete(f"{API_BASE}/meals/{meal_id}")
                                if del_response.status_code == 200:
                                    st.success("Meal deleted successfully!")
                                    st.rerun()
                                else:
                                    st.error("Failed to delete meal.")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No meals to delete yet.")
        else:
            st.info("Unable to load meals.")
    except Exception as e:
        st.info("Unable to load meals.")
    
    st.write("---")
    st.subheader("Delete Workout Records")
    
    try:
        response = requests.get(f"{API_BASE}/clients/{user_id}/workouts")
        
        if response.status_code == 200:
            workouts = response.json()
            if workouts and len(workouts) > 0:
                for workout in workouts[:10]:
                    col1, col2 = st.columns([3, 1])
                    with col1:
                        st.write(f"**{workout.get('Workout_Type', 'Workout')}** - {workout.get('Workout_Date', '')}")
                    with col2:
                        workout_id = workout.get('Workout_ID')
                        if st.button("Delete", key=f"del_workout_{workout_id}", type='secondary'):
                            try:
                                del_response = requests.delete(f"{API_BASE}/workouts/{workout_id}")
                                if del_response.status_code == 200:
                                    st.success("Workout deleted successfully!")
                                    st.rerun()
                                else:
                                    st.error("Failed to delete workout.")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No workouts to delete yet.")
        else:
            st.info("Unable to load workouts.")
    except Exception as e:
        st.info("Unable to load workouts.")

if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

