import logging
import streamlit as st
import requests
from datetime import datetime, date
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')
# Show appropriate sidebar links for the role of the currently logged in user
SideBarLinks()

st.title("Log a New Meal")

user_id = st.session_state.get('user_id', 1)
API_BASE = "http://web-api:4000"

with st.form("log_meal_form"):
    st.subheader("Meal Information")
    
    meal_name = st.text_input("Meal Name *", placeholder="e.g., Grilled Chicken Salad")
    calories = st.number_input("Calories *", min_value=0, step=1, value=0)
    meal_date = st.date_input("Date *", value=date.today())
    meal_time = st.time_input("Time *", value=datetime.now().time())
    
    submitted = st.form_submit_button("Log Meal", type='primary', use_container_width=True)
    
    if submitted:
        if not meal_name or calories == 0:
            st.error("Please fill in all required fields marked with *")
        else:
            meal_data = {
                "User_ID": user_id,
                "Meal_Name": meal_name,
                "Calories": calories,
                "Meal_Date": str(meal_date),
                "Meal_Time": str(meal_time)
            }
            
            try:
                response = requests.post(f"{API_BASE}/meals", json=meal_data)
                
                if response.status_code == 201:
                    result = response.json()
                    st.success(f"Meal '{meal_name}' logged successfully!")
                    st.balloons()
                    if st.button("Log Another Meal", use_container_width=True):
                        st.rerun()
                else:
                    error_msg = response.json().get('error', 'Unknown error')
                    st.error(f"Failed to log meal: {error_msg}")
            
            except requests.exceptions.RequestException as e:
                st.error(f"Error connecting to the API: {str(e)}")
                st.info("Please ensure the API server is running")

if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

