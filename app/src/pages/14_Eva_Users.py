import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import datetime, date

st.set_page_config(layout='wide')
SideBarLinks()

user_id = st.session_state.get('user_id', 30)
first_name = st.session_state.get('first_name', 'Eva')
API_BASE = "http://web-api:4000"

st.title("User Management")
st.write('')

# Tabs for different user management functions
tab1, tab2, tab3 = st.tabs(["View All Users", "Add New User", "User Activity"])

# View All Users
with tab1:
    st.subheader("All System Users")
    
    try:
        response = requests.get(f"{API_BASE}/admin/users")
        
        if response.status_code == 200:
            users = response.json()
            if users and len(users) > 0:
                st.write(f"**Total Users: {len(users)}**")
                
                # Filter options
                col1, col2 = st.columns(2)
                with col1:
                    search_term = st.text_input("Search by name or email:")
                with col2:
                    user_type_filter = st.selectbox("Filter by role:", ["All", "Client", "Coach", "Dietitian", "Admin"])
                
                # Display users
                for user in users:
                    user_name = user.get('First_Name', '') + ' ' + user.get('Last_Name', '')
                    user_email = user.get('Email', 'N/A')
                    user_id_val = user.get('user_id', 'N/A')
                    registration_date = user.get('Registration_Date', 'N/A')
                    
                    # Apply search filter
                    if search_term and search_term.lower() not in user_name.lower() and search_term.lower() not in str(user_email).lower():
                        continue
                    
                    with st.expander(f"👤 {user_name} (ID: {user_id_val})"):
                        col1, col2 = st.columns(2)
                        with col1:
                            st.write(f"**Email:** {user_email}")
                            st.write(f"**User ID:** {user_id_val}")
                        with col2:
                            st.write(f"**Registered:** {registration_date}")
                        
                        # Admin actions
                        col_a1, col_a2, col_a3 = st.columns(3)
                        with col_a1:
                            if st.button("View Activity", key=f"view_{user_id_val}", use_container_width=True):
                                st.session_state['selected_user_id'] = user_id_val
                                st.info(f"Viewing activity for {user_name}")
                        
                        with col_a2:
                            if st.button("Reset Password", key=f"reset_{user_id_val}", use_container_width=True):
                                st.info(f"Password reset email sent to {user_email}")
                        
                        with col_a3:
                            if st.button("🗑️ Delete User", key=f"delete_{user_id_val}", type='secondary', use_container_width=True):
                                try:
                                    del_response = requests.delete(f"{API_BASE}/admin/users/{user_id_val}")
                                    if del_response.status_code == 200:
                                        st.success(f"User {user_name} deleted successfully")
                                        st.rerun()
                                    else:
                                        st.error("Failed to delete user")
                                except:
                                    st.error("Error deleting user")
            else:
                st.info("No users found in the system")
        else:
            st.warning("Unable to load users. Using demo data.")
            st.info("API endpoint not yet implemented")
    except Exception as e:
        st.warning(f"Unable to connect to user database")
        logger.error(f"Error fetching users: {str(e)}")

# Add New User
with tab2:
    st.subheader("Register New User")
    
    with st.form("add_user_form"):
        col1, col2 = st.columns(2)
        
        with col1:
            new_first_name = st.text_input("First Name *")
            new_last_name = st.text_input("Last Name *")
            new_email = st.text_input("Email *")
        
        with col2:
            new_phone = st.text_input("Phone Number")
            new_birthdate = st.date_input("Birthdate", value=date(2000, 1, 1))
            new_gender = st.selectbox("Gender", ["Male", "Female", "Other", "Prefer not to say"])
        
        submitted = st.form_submit_button("Create User Account", type='primary')
        
        if submitted:
            if not all([new_first_name, new_last_name, new_email]):
                st.error("Please fill in all required fields (*)")
            else:
                user_data = {
                    "First_Name": new_first_name,
                    "Last_Name": new_last_name,
                    "Email": new_email,
                    "Phone": new_phone,
                    "Birthdate": str(new_birthdate),
                    "Gender": new_gender,
                    "Registration_Date": str(date.today())
                }
                
                try:
                    response = requests.post(f"{API_BASE}/admin/users", json=user_data)
                    if response.status_code == 201:
                        result = response.json()
                        st.success(f"✅ User {new_first_name} {new_last_name} created successfully!")
                        st.info(f"User ID: {result.get('user_id', 'N/A')}")
                        st.balloons()
                    else:
                        error_msg = response.json().get('error', 'Unknown error')
                        st.error(f"Failed to create user: {error_msg}")
                except Exception as e:
                    st.error(f"Error creating user: {str(e)}")
                    st.info("Note: API endpoint may not be implemented yet")

# User Activity
with tab3:
    st.subheader("User Activity Monitor")
    
    selected_user_id = st.session_state.get('selected_user_id', 1)
    user_id_input = st.number_input("Enter User ID to monitor:", min_value=1, value=int(selected_user_id), step=1)
    
    if st.button("Load User Activity", type='primary'):
        try:
            # Get user's meals
            meals_response = requests.get(f"{API_BASE}/clients/{user_id_input}/meals")
            if meals_response.status_code == 200:
                meals = meals_response.json()
                st.write(f"**Meals Logged: {len(meals) if isinstance(meals, list) else 0}**")
                if meals and len(meals) > 0:
                    for meal in meals[:10]:  # Show last 10
                        col1, col2, col3 = st.columns([3, 2, 1])
                        with col1:
                            st.write(f"🍽️ {meal.get('Meal_Name', 'Meal')}")
                        with col2:
                            st.caption(f"{meal.get('Meal_Date', '')} {meal.get('Meal_Time', '')}")
                        with col3:
                            st.caption(f"{meal.get('Calories', 0)} cal")
            
            st.write('')
            
            # Get user's workouts
            workouts_response = requests.get(f"{API_BASE}/clients/{user_id_input}/workouts")
            if workouts_response.status_code == 200:
                workouts = workouts_response.json()
                st.write(f"**Workouts Logged: {len(workouts) if isinstance(workouts, list) else 0}**")
                if workouts and len(workouts) > 0:
                    for workout in workouts[:10]:  # Show last 10
                        col1, col2, col3 = st.columns([3, 2, 1])
                        with col1:
                            st.write(f"💪 {workout.get('Workout_Type', 'Workout')}")
                        with col2:
                            st.caption(f"{workout.get('Workout_Date', '')}")
                        with col3:
                            st.caption(f"{workout.get('Duration_Minutes', 0)} min")
            
            st.write('')
            
            # Get user's goals
            goals_response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id_input})
            if goals_response.status_code == 200:
                goals = goals_response.json()
                st.write(f"**Active Goals: {len(goals) if isinstance(goals, list) else 0}**")
                if goals and len(goals) > 0:
                    for goal in goals:
                        st.write(f"🎯 {goal.get('goal_type', 'Goal')} - {goal.get('start_time', '')} to {goal.get('end_time', 'Ongoing')}")
        
        except Exception as e:
            st.error(f"Error loading user activity: {str(e)}")
            logger.error(f"Error: {str(e)}")

st.write('')
if st.button("← Back to Admin Home", use_container_width=True):
    st.switch_page('pages/13_Eva_Home.py')

