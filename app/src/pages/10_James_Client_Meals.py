import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks
import requests
from datetime import datetime, date, timedelta
from collections import defaultdict

st.set_page_config(layout="wide")
SideBarLinks()

API_BASE = "http://web-api:4000"
user_id = st.session_state.get('user_id', 20)
first_name = st.session_state.get('first_name', 'James')

st.title("Client Meal Analysis & Review")
st.write('')

# Client Selection
col1, col2 = st.columns([2, 3])

with col1:
    view_mode = st.radio("View Mode:", ["All Clients", "Specific Client", "Date Range"])

with col2:
    if view_mode == "Specific Client":
        client_id = st.number_input("Client ID:", min_value=1, value=1, step=1)
        if st.button("Load Client Meals", type='primary'):
            st.session_state['selected_client'] = client_id
    elif view_mode == "Date Range":
        col_a, col_b = st.columns(2)
        with col_a:
            start_date = st.date_input("From:", value=date.today() - timedelta(days=7))
        with col_b:
            end_date = st.date_input("To:", value=date.today())

st.write('')
st.divider()

# Tabs for different functions
tab1, tab2, tab3 = st.tabs(["View & Comment on Meals", "Correct Meal Entries", "Meal History"])

# View & Comment on Meals
with tab1:
    st.subheader("Client Meals - Leave Comments & Suggestions")
    
    try:
        # Get meals based on view mode
        if view_mode == "Specific Client" and 'selected_client' in st.session_state:
            response = requests.get(f"{API_BASE}/clients/{st.session_state['selected_client']}/meals")
        else:
            response = requests.get(f"{API_BASE}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            
            # Filter by date if in date range mode
            if view_mode == "Date Range":
                meals = [m for m in meals if start_date <= datetime.strptime(m.get('Meal_Date', ''), '%Y-%m-%d').date() <= end_date] if meals else []
            
            if meals and len(meals) > 0:
                st.write(f"**Found {len(meals)} meals**")
                
                # Group by client
                meals_by_client = defaultdict(list)
                for meal in meals:
                    client = meal.get('User_ID', 'Unknown')
                    meals_by_client[client].append(meal)
                
                for client_id_key, client_meals in meals_by_client.items():
                    st.write(f"### Client ID: {client_id_key} ({len(client_meals)} meals)")
                    
                    for meal in client_meals:
                        meal_id = meal.get('Meal_ID')
                        meal_name = meal.get('Meal_Name', 'Meal')
                        meal_date = meal.get('Meal_Date', 'N/A')
                        meal_time = meal.get('Meal_Time', 'N/A')
                        calories = meal.get('Calories', 0)
                        
                        with st.expander(f"🍽️ {meal_name} - {meal_date} {meal_time} - {calories} cal"):
                            col1, col2 = st.columns([2, 1])
                            
                            with col1:
                                st.write(f"**Meal Details:**")
                                st.write(f"- **Name:** {meal_name}")
                                st.write(f"- **Date:** {meal_date}")
                                st.write(f"- **Time:** {meal_time}")
                                st.write(f"- **Calories:** {calories}")
                                
                                # Nutritional analysis
                                if calories > 800:
                                    st.warning("⚠️ High calorie meal - may need portion adjustment advice")
                                elif calories < 200:
                                    st.info("ℹ️ Low calorie meal - ensure adequate nutrition")
                                else:
                                    st.success("✅ Calorie count within healthy range")
                            
                            with col2:
                                st.write(f"**Meal ID:** {meal_id}")
                                st.write(f"**Client ID:** {client_id_key}")
                            
                            # Comment form
                            st.write('')
                            with st.form(f"comment_form_{meal_id}"):
                                st.write("**Leave Dietitian Comment:**")
                                comment_text = st.text_area("Your feedback/suggestions:", key=f"comment_{meal_id}")
                                
                                col_btn1, col_btn2 = st.columns(2)
                                with col_btn1:
                                    submitted = st.form_submit_button("💬 Submit Comment", use_container_width=True)
                                
                                if submitted and comment_text:
                                    comment_data = {
                                        "Meal_ID": meal_id,
                                        "User_ID": client_id_key,
                                        "Dietitian_ID": user_id,
                                        "Comment_Text": comment_text,
                                        "Comment_Date": str(date.today())
                                    }
                                    
                                    try:
                                        comm_response = requests.post(f"{API_BASE}/meals/{meal_id}/comments", json=comment_data)
                                        if comm_response.status_code == 201:
                                            st.success("✅ Comment submitted!")
                                        else:
                                            st.info("Comments feature not yet implemented")
                                            logger.info(f"Dietitian {user_id} comment on meal {meal_id}: {comment_text[:50]}")
                                    except:
                                        st.info(f"Would submit comment: {comment_text[:50]}...")
            else:
                st.info("No meals found for the selected criteria")
        else:
            st.warning("Unable to load meals")
    
    except Exception as e:
        st.error(f"Error loading meals: {str(e)}")

# Correct Meal Entries
with tab2:
    st.subheader("Correct or Update Inaccurate Meal Entries")
    
    st.info("As a dietitian, you can correct meal entries to ensure accurate nutritional data")
    
    meal_id_to_edit = st.number_input("Enter Meal ID to edit:", min_value=1, value=1, step=1)
    
    if st.button("Load Meal for Editing", type='primary'):
        try:
            response = requests.get(f"{API_BASE}/meals/{meal_id_to_edit}")
            if response.status_code == 200:
                meal_data = response.json()
                st.session_state['meal_to_edit'] = meal_data
                st.success(f"Loaded meal: {meal_data.get('Meal_Name', 'N/A')}")
            else:
                st.error("Meal not found")
        except:
            st.warning("Unable to load meal")
    
    if 'meal_to_edit' in st.session_state:
        meal = st.session_state['meal_to_edit']
        
        st.write('')
        st.write("### Edit Meal Information")
        
        with st.form("edit_meal_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                new_meal_name = st.text_input("Meal Name:", value=meal.get('Meal_Name', ''))
                new_calories = st.number_input("Calories:", value=int(meal.get('Calories', 0)))
                new_date = st.date_input(
                    "Date:",
                    value=datetime.strptime(meal.get('Meal_Date', str(date.today())), '%Y-%m-%d').date()
                )
            
            with col2:
                new_time = st.time_input(
                    "Time:",
                    value=datetime.strptime(meal.get('Meal_Time', '12:00:00'), '%H:%M:%S').time()
                )
                correction_reason = st.text_input("Reason for correction:")
            
            submitted = st.form_submit_button("✅ Update Meal Entry", type='primary')
            
            if submitted:
                update_data = {
                    "Meal_Name": new_meal_name,
                    "Calories": new_calories,
                    "Meal_Date": str(new_date),
                    "Meal_Time": str(new_time),
                    "Corrected_By": user_id,
                    "Correction_Reason": correction_reason
                }
                
                try:
                    update_response = requests.put(f"{API_BASE}/meals/{meal_id_to_edit}", json=update_data)
                    if update_response.status_code == 200:
                        st.success("✅ Meal entry corrected successfully!")
                        del st.session_state['meal_to_edit']
                        st.balloons()
                    else:
                        st.error("Failed to update meal")
                except:
                    st.info(f"Would update meal {meal_id_to_edit} with new data")
                    logger.info(f"Dietitian {user_id} correcting meal {meal_id_to_edit}: {correction_reason}")

# Meal History
with tab3:
    st.subheader("Meal History & Patterns")
    
    history_client_id = st.number_input("Client ID for history:", min_value=1, value=1, step=1)
    
    if st.button("View Meal History", type='primary'):
        try:
            response = requests.get(f"{API_BASE}/clients/{history_client_id}/meals")
            
            if response.status_code == 200:
                meals = response.json()
                
                if meals and len(meals) > 0:
                    st.write(f"**Total meals logged: {len(meals)}**")
                    
                    # Group by date
                    meals_by_date = defaultdict(list)
                    for meal in meals:
                        meal_date = meal.get('Meal_Date', 'Unknown')
                        meals_by_date[meal_date].append(meal)
                    
                    # Display by date
                    for meal_date in sorted(meals_by_date.keys(), reverse=True):
                        day_meals = meals_by_date[meal_date]
                        day_total_calories = sum(m.get('Calories', 0) for m in day_meals)
                        
                        with st.expander(f"📅 {meal_date} - {len(day_meals)} meals - {day_total_calories} total calories"):
                            for meal in day_meals:
                                col1, col2, col3 = st.columns([3, 2, 1])
                                with col1:
                                    st.write(f"**{meal.get('Meal_Name', 'Meal')}**")
                                with col2:
                                    st.write(f"⏰ {meal.get('Meal_Time', 'N/A')}")
                                with col3:
                                    st.write(f"🔥 {meal.get('Calories', 0)} cal")
                    
                    # Nutrition Summary
                    st.write('')
                    st.write("### Nutrition Summary")
                    
                    total_cal = sum(m.get('Calories', 0) for m in meals)
                    avg_cal = total_cal // len(meals) if len(meals) > 0 else 0
                    
                    col1, col2, col3 = st.columns(3)
                    with col1:
                        st.metric("Total Calories", f"{total_cal:,}")
                    with col2:
                        st.metric("Average per Meal", f"{avg_cal}")
                    with col3:
                        days_tracked = len(meals_by_date)
                        avg_per_day = total_cal // days_tracked if days_tracked > 0 else 0
                        st.metric("Avg Calories/Day", f"{avg_per_day:,}")
                    
                    # Dietary recommendations
                    st.write('')
                    if avg_per_day < 1500:
                        st.warning("⚠️ Average daily intake is low. Client may need increased caloric intake.")
                    elif avg_per_day > 3000:
                        st.warning("⚠️ Average daily intake is high. May need portion control guidance.")
                    else:
                        st.success("✅ Caloric intake appears balanced.")
                
                else:
                    st.info("No meal history for this client")
            else:
                st.warning("Unable to load meal history")
        
        except Exception as e:
            st.error(f"Error: {str(e)}")

st.write('')
if st.button("← Back to Dietitian Home", use_container_width=True):
    st.switch_page('pages/09_James_Home.py')
