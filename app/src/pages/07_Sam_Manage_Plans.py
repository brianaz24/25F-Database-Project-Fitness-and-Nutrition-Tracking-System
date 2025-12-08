import logging
import streamlit as st
import requests
import pandas as pd
from datetime import date
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

API_BASE = "http://api:4000"

SideBarLinks()

st.title("Manage Workout Plans")
st.write("Create and edit personalized workout plans for your clients")

coach_id = st.session_state.get('user_id', 2)

mock_clients = [
    {"user_id": 1, "first_name": "Mark", "last_name": "Johnson"},
    {"user_id": 3, "first_name": "Sarah", "last_name": "Williams"},
    {"user_id": 4, "first_name": "John", "last_name": "Smith"},
]

clients = mock_clients

if not clients or len(clients) == 0:
    st.info("You don't have any clients yet. Clients will appear here once assigned to you.")
    if st.button("Back to Home", use_container_width=True):
        st.switch_page('pages/10_Sam_Home.py')
else:
    tab1, tab2 = st.tabs(["Create New Plan", "View & Edit Plans"])
    
    with tab1:
        st.subheader("Create a New Workout Plan")
        
        with st.form("create_plan_form"):
            client_options = {f"{c['first_name']} {c['last_name']}": c['user_id'] for c in clients}
            selected_client = st.selectbox(
                "Select Client *",
                options=list(client_options.keys())
            )
            
            plan_name = st.text_input(
                "Plan Name *",
                placeholder="e.g., Beginner Strength Training - Week 1"
            )
            
            plan_description = st.text_area(
                "Plan Description",
                placeholder="Describe the goals and focus of this workout plan..."
            )
            
            col1, col2 = st.columns(2)
            with col1:
                start_date = st.date_input("Start Date *", value=date.today())
            with col2:
                end_date = st.date_input("End Date *")
            
            submitted = st.form_submit_button(
                "Create Workout Plan",
                type='primary',
                use_container_width=True
            )
            
            if submitted:
                if not plan_name or not selected_client:
                    st.error("Please fill in all required fields marked with *")
                elif end_date <= start_date:
                    st.error("End date must be after start date")
                else:
                    plan_data = {
                        "Plan_Name": plan_name,
                        "Client_ID": client_options[selected_client],
                        "Start_Date": str(start_date),
                        "End_Date": str(end_date),
                        "Description": plan_description if plan_description else None
                    }
                    
                    try:
                        response = requests.post(
                            f"{API_BASE}/plans",
                            json=plan_data
                        )
                        
                        if response.status_code == 201:
                            result = response.json()
                            st.success(f"Workout plan '{plan_name}' created successfully for {selected_client}!")
                            st.info(f"Plan ID: {result.get('plan_id')}. Now you can add exercises to this plan in the 'View & Edit Plans' tab.")
                            st.balloons()
                        else:
                            error_msg = response.json().get('error', 'Unknown error')
                            st.error(f"Failed to create plan: {error_msg}")
                    
                    except requests.exceptions.RequestException as e:
                        st.error(f"Error connecting to the API: {str(e)}")
                        st.info("Please ensure the API server is running")
        
        st.write("---")
        st.write("### Add Exercises to Library")
        st.caption("Create exercises that can be added to any plan")
        
        with st.form("create_exercise_form"):
            col1, col2 = st.columns(2)
            
            with col1:
                exercise_name = st.text_input("Exercise Name *", placeholder="e.g., Bench Press")
                muscle_group = st.text_input("Muscle Group", placeholder="e.g., Chest")
            
            with col2:
                video_url = st.text_input("Video URL *", placeholder="https://youtube.com/...")
                description = st.text_area("Description", placeholder="How to perform this exercise...")
            
            create_ex_submitted = st.form_submit_button("Add to Exercise Library", use_container_width=True)
            
            if create_ex_submitted:
                if not exercise_name or not video_url:
                    st.error("Exercise name and video URL are required")
                else:
                    exercise_data = {
                        "Exercise_Name": exercise_name,
                        "Video_URL": video_url,
                        "Description": description if description else None,
                        "Muscle_Group": muscle_group if muscle_group else None
                    }
                    
                    try:
                        response = requests.post(
                            f"{API_BASE}/plans/exercises",
                            json=exercise_data
                        )
                        
                        if response.status_code == 201:
                            st.success(f"Exercise '{exercise_name}' added to library!")
                        else:
                            st.error("Failed to add exercise")
                    except Exception as e:
                        st.error(f"Error: {str(e)}")
    
    with tab2:
        st.subheader("View & Edit Existing Plans")
        
        try:
            plans_response = requests.get(f"{API_BASE}/plans")
            
            if plans_response.status_code == 200:
                plans = plans_response.json()
                
                if plans and len(plans) > 0:
                    client_filter = st.selectbox(
                        "Filter by Client",
                        options=["All Clients"] + list(client_options.keys()),
                        key="client_filter"
                    )
                    
                    for plan in plans:
                        client_id = plan.get('Client_ID')
                        client_name = "Unknown"
                        for name, cid in client_options.items():
                            if cid == client_id:
                                client_name = name
                                break
                        
                        if client_filter != "All Clients" and client_name != client_filter:
                            continue
                        
                        with st.expander(f"{plan.get('Plan_Name', 'Unnamed Plan')} - {client_name}"):
                            col1, col2 = st.columns([2, 1])
                            
                            with col1:
                                st.write(f"**Client:** {client_name}")
                                st.write(f"**Start Date:** {plan.get('Start_Date', 'N/A')}")
                                st.write(f"**End Date:** {plan.get('End_Date', 'N/A')}")
                                if plan.get('Description'):
                                    st.write(f"**Description:** {plan.get('Description')}")
                            
                            st.write("---")
                            st.write("**Exercises in this Plan:**")
                            
                            plan_id = plan.get('Plan_ID')
                            try:
                                exercises_response = requests.get(
                                    f"{API_BASE}/plans/{plan_id}/exercises"
                                )
                                
                                if exercises_response.status_code == 200:
                                    exercises = exercises_response.json()
                                    
                                    if exercises and len(exercises) > 0:
                                        for ex in exercises:
                                            st.write(f"- {ex.get('Exercise_Name', 'Unknown')}: {ex.get('Sets', 0)} sets × {ex.get('Reps', 0)} reps")
                                            if ex.get('Video_URL'):
                                                st.caption(f"Demo: {ex.get('Video_URL')}")
                                        
                                        st.write("")
                                        st.write("**Adjust Exercise Volume:**")
                                        
                                        ex_lib_response = requests.get(f"{API_BASE}/plans/exercises")
                                        if ex_lib_response.status_code == 200:
                                            all_exercises = ex_lib_response.json()
                                            
                                            with st.form(f"edit_plan_{plan_id}"):
                                                selected_ex = st.selectbox(
                                                    "Select Exercise to Update",
                                                    options=[e.get('Exercise_Name') for e in exercises],
                                                    key=f"ex_select_{plan_id}"
                                                )
                                                
                                                exercise_id = None
                                                for e in exercises:
                                                    if e.get('Exercise_Name') == selected_ex:
                                                        exercise_id = e.get('Exercise_ID')
                                                        break
                                                
                                                col1, col2 = st.columns(2)
                                                with col1:
                                                    new_sets = st.number_input("New Sets", min_value=1, value=3, key=f"sets_{plan_id}")
                                                with col2:
                                                    new_reps = st.number_input("New Reps", min_value=1, value=10, key=f"reps_{plan_id}")
                                                
                                                update_submitted = st.form_submit_button(
                                                    "Update Exercise",
                                                    use_container_width=True
                                                )
                                                
                                                if update_submitted and exercise_id:
                                                    update_data = {
                                                        "exercise_id": exercise_id,
                                                        "sets": new_sets,
                                                        "reps": new_reps
                                                    }
                                                    
                                                    try:
                                                        update_response = requests.put(
                                                            f"{API_BASE}/plans/{plan_id}/exercises",
                                                            json=update_data
                                                        )
                                                        
                                                        if update_response.status_code == 200:
                                                            st.success("Exercise updated successfully!")
                                                            st.rerun()
                                                        else:
                                                            st.error("Failed to update exercise")
                                                    except Exception as e:
                                                        st.error(f"Error: {str(e)}")
                                    else:
                                        st.info("No exercises added to this plan yet.")
                                else:
                                    st.info("Could not load exercises for this plan.")
                            
                            except Exception as e:
                                st.error(f"Error loading exercises: {str(e)}")
                else:
                    st.info("No workout plans created yet. Create your first plan in the 'Create New Plan' tab!")
            else:
                st.error("Unable to fetch workout plans")
        
        except Exception as e:
            st.error(f"Error loading plans: {str(e)}")
            logger.error(f"Error in view plans tab: {str(e)}")

st.write('')
if st.button("Back to Home", use_container_width=True):
    st.switch_page('pages/10_Sam_Home.py')