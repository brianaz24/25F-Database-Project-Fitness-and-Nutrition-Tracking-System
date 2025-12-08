import logging
import streamlit as st
import requests
from datetime import datetime, date, timedelta
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

SideBarLinks()

st.title("My Goals")

user_id = st.session_state.get('user_id', 1)
API_BASE = "http://web-api:4000"

st.write('')

# Tabs for Goals Management
tab1, tab2 = st.tabs(["Active Goals", "Create New Goal"])

# Active Goals Tab
with tab1:
    st.subheader("My Active Goals")

    try:
        response = requests.get(f"{API_BASE}/clients/goals", params={"user_id": user_id})
        
        if response.status_code == 200:
            goals = response.json()
            if goals and len(goals) > 0:
                st.write(f"**You have {len(goals)} goal(s):**")
                
                for goal in goals:
                    goal_id = goal.get('goal_id')
                    goal_type = goal.get('goal_type', 'Goal')
                    start_time = goal.get('start_time', 'N/A')
                    end_time = goal.get('end_time', 'N/A')
                    
                    with st.expander(f"🎯 {goal_type} (Started: {start_time})"):
                        col1, col2 = st.columns(2)
                        with col1:
                            st.write(f"**Goal Type:** {goal_type}")
                            st.write(f"**Start Date:** {start_time}")
                        with col2:
                            st.write(f"**Target End:** {end_time if end_time != 'N/A' else 'Ongoing'}")
                            st.write(f"**Goal ID:** {goal_id}")
                        
                        st.write('')
                        
                        # Edit Goal Form
                        with st.form(f"edit_goal_{goal_id}"):
                            st.write("**Edit This Goal:**")
                            
                            new_goal_type = st.selectbox(
                                "Goal Type",
                                ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"],
                                index=["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"].index(goal_type) if goal_type in ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"] else 0,
                                key=f"goal_type_{goal_id}"
                            )
                            
                            col_edit1, col_edit2 = st.columns(2)
                            
                            with col_edit1:
                                new_start_time = st.date_input(
                                    "Start Date",
                                    value=datetime.strptime(start_time, '%Y-%m-%d').date() if start_time and start_time != 'N/A' and '-' in str(start_time) else date.today(),
                                    key=f"start_time_{goal_id}"
                                )
                            
                            with col_edit2:
                                new_end_time = st.date_input(
                                    "End Date",
                                    value=datetime.strptime(end_time, '%Y-%m-%d').date() if end_time and end_time != 'N/A' and '-' in str(end_time) else date.today() + timedelta(days=30),
                                    key=f"end_time_{goal_id}"
                                )
                            
                            col_btn1, col_btn2 = st.columns(2)
                            
                            with col_btn1:
                                if st.form_submit_button("✅ Update Goal", use_container_width=True):
                                    update_data = {
                                        "goal_type": new_goal_type,
                                        "start_time": str(new_start_time),
                                        "end_time": str(new_end_time)
                                    }
                                    
                                    try:
                                        update_response = requests.put(f"{API_BASE}/clients/goals/{goal_id}", json=update_data)
                                        if update_response.status_code == 200:
                                            st.success("Goal updated successfully!")
                                            st.rerun()
                                        else:
                                            st.error("Failed to update goal.")
                                    except Exception as e:
                                        st.error(f"Error: {str(e)}")
                        
                        # Delete Goal Button (outside the form)
                        if st.button("🗑️ Delete Goal", key=f"delete_goal_{goal_id}", type='secondary', use_container_width=True):
                            try:
                                del_response = requests.delete(f"{API_BASE}/clients/goals/{goal_id}")
                                if del_response.status_code == 200:
                                    st.success("Goal deleted successfully!")
                                    st.rerun()
                                else:
                                    st.error("Failed to delete goal.")
                            except Exception as e:
                                st.error(f"Error: {str(e)}")
            else:
                st.info("No goals set yet. Create your first goal in the 'Create New Goal' tab!")
        else:
            st.info("Unable to load goals.")
    except Exception as e:
        st.info(f"Unable to load goals: {str(e)}")

# Create New Goal Tab
with tab2:
    st.subheader("Set a New Goal")
    
    st.write("Define a new fitness or nutrition goal to track your progress:")
    
    with st.form("create_goal_form"):
        goal_type = st.selectbox(
            "Goal Type *", 
            ["Weight Loss", "Weight Gain", "Muscle Gain", "Calorie Target", "Workout Frequency", "Other"]
        )
        
        col1, col2 = st.columns(2)
        
        with col1:
            start_date = st.date_input("Start Date *", value=date.today())
        
        with col2:
            end_date = st.date_input("Target End Date *", value=date.today() + timedelta(days=30))
        
        st.write('')
        
        # Goal details based on type
        if goal_type == "Weight Loss" or goal_type == "Weight Gain":
            target_weight = st.number_input("Target Weight (lbs)", min_value=50, max_value=500, value=150)
            st.caption(f"Goal: Reach {target_weight} lbs by {end_date}")
        elif goal_type == "Calorie Target":
            target_calories = st.number_input("Daily Calorie Target", min_value=1000, max_value=5000, value=2000)
            st.caption(f"Goal: Maintain {target_calories} calories/day")
        elif goal_type == "Workout Frequency":
            workouts_per_week = st.number_input("Workouts per Week", min_value=1, max_value=14, value=3)
            st.caption(f"Goal: Complete {workouts_per_week} workouts per week")
        
        notes = st.text_area("Notes (optional)", placeholder="Add any additional details about your goal...")
        
        submitted = st.form_submit_button("✅ Create Goal", type='primary', use_container_width=True)
        
        if submitted:
            if not goal_type:
                st.error("Please select a goal type.")
            else:
                goal_data = {
                    "User_ID": user_id,
                    "goal_type": goal_type,
                    "start_time": str(start_date),
                    "end_time": str(end_date)
                }
                
                try:
                    response = requests.post(f"{API_BASE}/clients/goals", json=goal_data)
                    
                    if response.status_code == 201:
                        result = response.json()
                        st.success(f"✅ Goal '{goal_type}' created successfully!")
                        st.info(f"Goal ID: {result.get('goal_id', 'N/A')}")
                        st.balloons()
                        st.rerun()
                    else:
                        error_msg = response.json().get('error', 'Unknown error')
                        st.error(f"Failed to create goal: {error_msg}")
                
                except Exception as e:
                    st.error(f"Error: {str(e)}")

st.write('')
if st.button("← Back to Home", use_container_width=True):
    st.switch_page('pages/00_Mark_Home.py')

