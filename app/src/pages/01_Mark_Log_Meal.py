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

# Show persistent success message if meal was just logged
if st.session_state.get('meal_logged', False):
    last_meal_name = st.session_state.get('last_meal_name', 'meal')
    last_meal_id = st.session_state.get('last_meal_id', 'N/A')
    st.success(f"✅ **Meal '{last_meal_name}' logged successfully!** (ID: {last_meal_id})")
    st.balloons()

with st.form("log_meal_form"):
    st.subheader("Meal Information")
    
    # Clear form values if meal was just logged
    default_name = "" if st.session_state.get('meal_logged', False) else None
    default_calories = 0 if st.session_state.get('meal_logged', False) else 0
    
    meal_name = st.text_input("Meal Name *", placeholder="e.g., Grilled Chicken Salad", value=default_name if default_name == "" else None)
    calories = st.number_input("Calories *", min_value=0, step=1, value=default_calories)
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
                response = requests.post(f"{API_BASE}/meals", json=meal_data, timeout=5)
                
                if response.status_code == 201:
                    result = response.json()
                    meal_id = result.get('meal_id', 'N/A')
                    st.session_state['meal_logged'] = True
                    st.session_state['last_meal_id'] = meal_id
                    st.session_state['last_meal_name'] = meal_name
                    st.session_state['meal_submit_time'] = datetime.now().isoformat()
                    st.success(f"✅ Meal '{meal_name}' logged successfully! (ID: {meal_id})")
                    st.balloons()
                    # Don't rerun here - let the success message show and persist via session_state
                else:
                    try:
                        error_msg = response.json().get('error', f'HTTP {response.status_code}')
                    except:
                        error_msg = f'HTTP {response.status_code}: {response.text[:100]}'
                    st.error(f"Failed to log meal: {error_msg}")
            
            except requests.exceptions.Timeout:
                st.error("Request timed out. Please try again.")
            except requests.exceptions.ConnectionError:
                st.error("Cannot connect to the API server. Please ensure the API is running.")
            except requests.exceptions.RequestException as e:
                st.error(f"Error connecting to the API: {str(e)}")
                st.info("Please ensure the API server is running")

# Show action buttons after successful meal log
if st.session_state.get('meal_logged', False):
    last_meal_name = st.session_state.get('last_meal_name', 'meal')
    last_meal_id = st.session_state.get('last_meal_id', 'N/A')
    
    st.info(f"💾 **Last saved meal:** '{last_meal_name}' (ID: {last_meal_id})")
    
    col1, col2 = st.columns(2)
    with col1:
        if st.button("Log Another Meal", use_container_width=True):
            # Clear success state to allow new meal entry
            if 'meal_logged' in st.session_state:
                del st.session_state['meal_logged']
            if 'last_meal_id' in st.session_state:
                del st.session_state['last_meal_id']
            if 'last_meal_name' in st.session_state:
                del st.session_state['last_meal_name']
            st.rerun()
    with col2:
        if st.button("View My Meals", use_container_width=True):
            st.switch_page('pages/03_Mark_View_Progress.py')

if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

