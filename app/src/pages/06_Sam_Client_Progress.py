import logging
import streamlit as st
import requests
import pandas as pd
from datetime import datetime, timedelta
from modules.nav import SideBarLinks

logger = logging.getLogger(__name__)
st.set_page_config(layout='wide')

API_BASE = "http://api:4000"

SideBarLinks()

st.title("Monitor Client Progress")
st.write("View your clients' daily workout logs and calorie intake summaries")

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
    client_names = [f"{client['first_name']} {client['last_name']}" for client in clients]
    client_ids = [client['user_id'] for client in clients]
    
    selected_client_name = st.selectbox(
        "Select a Client",
        options=client_names,
        index=0
    )
    
    selected_client_id = client_ids[client_names.index(selected_client_name)]
    
    st.write('')
    st.subheader(f"Progress for {selected_client_name}")
    
    col1, col2 = st.columns(2)
    with col1:
        start_date = st.date_input(
            "Start Date",
            value=datetime.now() - timedelta(days=7)
        )
    with col2:
        end_date = st.date_input(
            "End Date",
            value=datetime.now()
        )
    
    tab1, tab2, tab3 = st.tabs(["Overview", "Workout Logs", "Nutrition Logs"])
    
    with tab1:
        st.write("### Summary Statistics")
        
        try:
            workouts_response = requests.get(f"{API_BASE}/clients/{selected_client_id}/workouts")
            meals_response = requests.get(f"{API_BASE}/clients/{selected_client_id}/meals")
            
            total_workouts = 0
            total_duration = 0
            total_calories_burned = 0
            avg_daily_calories = 0
            
            if workouts_response.status_code == 200:
                workouts = workouts_response.json()
                if workouts:
                    total_workouts = len(workouts)
                    total_duration = sum([w.get('Duration_Minutes', 0) or 0 for w in workouts])
                    total_calories_burned = sum([w.get('Calories_Burned', 0) or 0 for w in workouts])
            
            if meals_response.status_code == 200:
                meals = meals_response.json()
                if meals:
                    total_calories = sum([m.get('Calories', 0) or 0 for m in meals])
                    days_diff = (end_date - start_date).days + 1
                    avg_daily_calories = total_calories / days_diff if days_diff > 0 else 0
            
            col1, col2, col3, col4 = st.columns(4)
            
            with col1:
                st.metric("Total Workouts", total_workouts)
            
            with col2:
                st.metric("Avg Calories/Day", f"{avg_daily_calories:.0f}")
            
            with col3:
                st.metric("Total Duration", f"{total_duration} min")
            
            with col4:
                st.metric("Calories Burned", f"{total_calories_burned:.0f}")
            
            st.write('')
            st.write("### Plan Adherence")
            
            workout_compliance = min(100, (total_workouts / 7) * 100) if total_workouts else 0
            nutrition_compliance = 85
            
            col1, col2 = st.columns(2)
            
            with col1:
                st.progress(workout_compliance / 100)
                st.write(f"Workout Plan: {workout_compliance:.0f}%")
            
            with col2:
                st.progress(nutrition_compliance / 100)
                st.write(f"Nutrition Goals: {nutrition_compliance}%")
        
        except Exception as e:
            st.error(f"Error loading summary: {str(e)}")
            logger.error(f"Error fetching client summary: {str(e)}")
    
    with tab2:
        st.write("### Workout History")
        
        try:
            workouts_response = requests.get(f"{API_BASE}/clients/{selected_client_id}/workouts")
            
            if workouts_response.status_code == 200:
                workouts = workouts_response.json()
                
                if workouts and len(workouts) > 0:
                    df_workouts = pd.DataFrame(workouts)
                    
                    display_columns = ['Workout_Date', 'Workout_Type', 'Duration_Minutes', 'Calories_Burned', 'Notes']
                    available_columns = [col for col in display_columns if col in df_workouts.columns]
                    
                    st.dataframe(
                        df_workouts[available_columns],
                        use_container_width=True,
                        hide_index=True
                    )
                    
                    st.write('')
                    st.write("#### Workout Details")
                    for idx, workout in enumerate(workouts[:5]):
                        with st.expander(f"Workout on {workout.get('Workout_Date', 'N/A')}"):
                            st.write(f"**Type:** {workout.get('Workout_Type', 'Not specified')}")
                            st.write(f"**Duration:** {workout.get('Duration_Minutes', 0)} minutes")
                            st.write(f"**Calories Burned:** {workout.get('Calories_Burned', 0)}")
                            if workout.get('Notes'):
                                st.write(f"**Notes:** {workout.get('Notes')}")
                else:
                    st.info("No workouts logged in this date range.")
            else:
                st.info("No workout data available.")
        
        except Exception as e:
            st.error(f"Error loading workouts: {str(e)}")
            logger.error(f"Error fetching client workouts: {str(e)}")
    
    with tab3:
        st.write("### Nutrition History")
        
        try:
            meals_response = requests.get(f"{API_BASE}/clients/{selected_client_id}/meals")
            
            if meals_response.status_code == 200:
                meals = meals_response.json()
                
                if meals and len(meals) > 0:
                    df_meals = pd.DataFrame(meals)
                    
                    if 'Meal_Date' in df_meals.columns and 'Calories' in df_meals.columns:
                        daily_calories = df_meals.groupby('Meal_Date')['Calories'].sum().reset_index()
                        daily_calories.columns = ['Date', 'Total Calories']
                        
                        st.write("#### Daily Calorie Intake")
                        st.dataframe(
                            daily_calories,
                            use_container_width=True,
                            hide_index=True
                        )
                    
                    st.write('')
                    st.write("#### All Meals")
                    
                    display_columns = ['Meal_Date', 'Meal_Name', 'Calories', 'Meal_Time']
                    available_columns = [col for col in display_columns if col in df_meals.columns]
                    
                    st.dataframe(
                        df_meals[available_columns],
                        use_container_width=True,
                        hide_index=True
                    )
                else:
                    st.info("No meals logged in this date range.")
            else:
                st.info("No nutrition data available.")
        
        except Exception as e:
            st.error(f"Error loading meals: {str(e)}")
            logger.error(f"Error fetching client meals: {str(e)}")

st.write('')
if st.button("Back to Home", use_container_width=True):
    st.switch_page('pages/10_Sam_Home.py')