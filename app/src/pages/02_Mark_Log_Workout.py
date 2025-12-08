import logging
import streamlit as st
import requests
from datetime import datetime, date
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

SideBarLinks()

st.title("Record a Workout")

user_id = st.session_state.get('user_id', 1)

with st.form("log_workout_form"):
    st.subheader("Workout Information")
    
    workout_date = st.date_input("Workout Date *", value=date.today())
    workout_type = st.text_input("Workout Type", placeholder="e.g., Running, Weight Training, Yoga")
    duration_minutes = st.number_input("Duration (minutes)", min_value=0, step=1, value=0)
    calories_burned = st.number_input("Calories Burned", min_value=0, step=1, value=0)
    notes = st.text_area("Notes", placeholder="Any additional notes about your workout...")
    
    submitted = st.form_submit_button("Record Workout", type='primary', use_container_width=True)
    
    if submitted:
        if not workout_date:
            st.error("Please fill in the required field marked with *")
        else:
            workout_data = {
                "User_ID": user_id,
                "Workout_Date": str(workout_date),
                "Workout_Type": workout_type if workout_type else None,
                "Duration_Minutes": duration_minutes if duration_minutes > 0 else None,
                "Calories_Burned": calories_burned if calories_burned > 0 else None,
                "Notes": notes if notes else None
            }
            
            try:
                response = requests.post(f"{API_BASE}/workouts", json=workout_data)
                
                if response.status_code == 201:
                    result = response.json()
                    st.success(f"Workout recorded successfully!")
                    st.balloons()
                    if st.button("Record Another Workout", use_container_width=True):
                        st.rerun()
                else:
                    error_msg = response.json().get('error', 'Unknown error')
                    st.error(f"Failed to record workout: {error_msg}")
            
            except requests.exceptions.RequestException as e:
                st.error(f"Error connecting to the API: {str(e)}")
                st.info("Please ensure the API server is running")

if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

