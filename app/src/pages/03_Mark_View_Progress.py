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
tab1, tab2 = st.tabs(["Edit Records", "Delete Records"])

# Edit Records
with tab1:
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
with tab2:
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
    
    st.write("---")
    st.info("💡 **Note:** To manage your goals, visit the 'Manage My Goals' page from the home screen.")

st.write('')
if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

