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

st.title("Client Alerts & Notifications")
st.write("Stay informed about clients who may need extra attention")

coach_id = st.session_state.get('user_id', 2)

mock_clients = [
    {"user_id": 1, "first_name": "Mark", "last_name": "Johnson"},
    {"user_id": 3, "first_name": "Sarah", "last_name": "Williams"},
    {"user_id": 4, "first_name": "John", "last_name": "Smith"},
]

tab1, tab2, tab3 = st.tabs(["Missed Workouts", "Nutrition Alerts", "Recent Activity"])

with tab1:
    st.subheader("Clients with Missed Workouts")
    st.caption("Clients who may need follow-up on their workout schedule")
    
    try:
        notifications_response = requests.get(
            f"{API_BASE}/clients/coaches/{coach_id}/notifications"
        )
        
        if notifications_response.status_code == 200:
            notifications = notifications_response.json()
            
            if notifications and len(notifications) > 0:
                for notif in notifications:
                    client_id = notif.get('User_ID')
                    client_name = "Unknown Client"
                    for client in mock_clients:
                        if client['user_id'] == client_id:
                            client_name = f"{client['first_name']} {client['last_name']}"
                            break
                    
                    with st.container():
                        col1, col2, col3 = st.columns([2, 1, 1])
                        
                        with col1:
                            st.write(f"### {client_name}")
                            st.write(f"**Notification:** {notif.get('Notification_Type', 'Alert')}")
                            st.write(f"**Date:** {notif.get('Notification_Date', 'N/A')}")
                            if notif.get('Message'):
                                st.caption(notif.get('Message'))
                        
                        with col2:
                            if st.button(
                                "View Profile",
                                key=f"view_missed_{notif.get('Notification_ID')}",
                                use_container_width=True
                            ):
                                st.session_state['selected_client_id'] = client_id
                                st.switch_page('pages/06_Sam_Client_Progress.py')
                        
                        with col3:
                            if st.button(
                                "Follow Up",
                                key=f"msg_missed_{notif.get('Notification_ID')}",
                                type="primary",
                                use_container_width=True
                            ):
                                st.success("Follow-up message sent!")
                        
                        st.write("---")
            else:
                st.success("All clients are keeping up with their workout schedules!")
        else:
            st.info("No missed workout alerts at this time.")
    
    except Exception as e:
        st.info("Alerts will appear here when clients miss workouts.")
        logger.error(f"Error fetching missed workout alerts: {str(e)}")

with tab2:
    st.subheader("Nutrition Tracking Alerts")
    st.caption("Monitor clients' nutrition logging and adherence")
    
    try:
        nutrition_alerts = []
        
        for client in mock_clients:
            try:
                meals_response = requests.get(f"{API_BASE}/clients/{client['user_id']}/meals")
                
                if meals_response.status_code == 200:
                    meals = meals_response.json()
                    
                    if not meals or len(meals) == 0:
                        nutrition_alerts.append({
                            "user_id": client['user_id'],
                            "client_name": f"{client['first_name']} {client['last_name']}",
                            "alert_type": "no_logs",
                            "days_without_logs": "3+"
                        })
                    else:
                        if meals:
                            last_meal_date = meals[0].get('Meal_Date')
            except:
                pass
        
        if nutrition_alerts:
            for alert in nutrition_alerts:
                with st.container():
                    col1, col2 = st.columns([3, 1])
                    
                    with col1:
                        st.write(f"### {alert['client_name']}")
                        st.warning(f"No meal logs for {alert.get('days_without_logs', '3+')} days")
                    
                    with col2:
                        if st.button(
                            "View Details",
                            key=f"view_nutrition_{alert['user_id']}",
                            use_container_width=True
                        ):
                            st.session_state['selected_client_id'] = alert['user_id']
                            st.switch_page('pages/06_Sam_Client_Progress.py')
                    
                    st.write("---")
        else:
            st.success("All clients are tracking their nutrition consistently!")
    
    except Exception as e:
        st.info("Nutrition alerts will appear here when clients need follow-up.")
        logger.error(f"Error checking nutrition alerts: {str(e)}")

with tab3:
    st.subheader("Recent Client Activity")
    st.caption("Overview of all client activities and engagement")
    
    col1, col2 = st.columns(2)
    with col1:
        days_back = st.selectbox(
            "Show activity from last:",
            options=[7, 14, 30],
            format_func=lambda x: f"{x} days",
            index=0
        )
    
    with col2:
        activity_filter = st.multiselect(
            "Filter by activity type:",
            options=["Workouts", "Meals"],
            default=["Workouts", "Meals"]
        )
    
    try:
        all_activities = []
        
        for client in mock_clients:
            client_name = f"{client['first_name']} {client['last_name']}"
            
            if "Workouts" in activity_filter:
                try:
                    workouts_response = requests.get(f"{API_BASE}/clients/{client['user_id']}/workouts")
                    if workouts_response.status_code == 200:
                        workouts = workouts_response.json()
                        for workout in workouts[:5]:
                            all_activities.append({
                                "client_name": client_name,
                                "user_id": client['user_id'],
                                "activity_type": "workout",
                                "date": workout.get('Workout_Date', 'N/A'),
                                "workout_type": workout.get('Workout_Type', 'General'),
                                "duration_minutes": workout.get('Duration_Minutes', 0),
                                "details": f"{workout.get('Workout_Type', 'Workout')} - {workout.get('Duration_Minutes', 0)} min"
                            })
                except:
                    pass
            
            if "Meals" in activity_filter:
                try:
                    meals_response = requests.get(f"{API_BASE}/clients/{client['user_id']}/meals")
                    if meals_response.status_code == 200:
                        meals = meals_response.json()
                        for meal in meals[:5]:
                            all_activities.append({
                                "client_name": client_name,
                                "user_id": client['user_id'],
                                "activity_type": "meal",
                                "date": meal.get('Meal_Date', 'N/A'),
                                "meal_name": meal.get('Meal_Name', 'Meal'),
                                "calories": meal.get('Calories', 0),
                                "details": f"{meal.get('Meal_Name', 'Meal')} - {meal.get('Calories', 0)} cal"
                            })
                except:
                    pass
        
        if all_activities:
            all_activities.sort(key=lambda x: x.get('date', ''), reverse=True)
            
            st.write("#### Summary")
            col1, col2, col3, col4 = st.columns(4)
            
            active_clients = len(set([a['user_id'] for a in all_activities]))
            total_workouts = len([a for a in all_activities if a['activity_type'] == 'workout'])
            total_meals = len([a for a in all_activities if a['activity_type'] == 'meal'])
            
            with col1:
                st.metric("Active Clients", active_clients)
            
            with col2:
                st.metric("Total Workouts", total_workouts)
            
            with col3:
                st.metric("Meals Logged", total_meals)
            
            with col4:
                avg_engagement = len(all_activities) / days_back if days_back > 0 else 0
                st.metric("Avg Daily Activities", f"{avg_engagement:.1f}")
            
            st.write("---")
            st.write("#### Activity Timeline")
            
            for idx, activity in enumerate(all_activities[:20]):
                with st.container():
                    col1, col2, col3 = st.columns([2, 3, 1])
                    
                    with col1:
                        st.write(f"**{activity['client_name']}**")
                        st.caption(activity.get('date', 'N/A'))
                    
                    with col2:
                        if activity['activity_type'] == 'workout':
                            st.write(f"Workout: {activity.get('details', 'Workout')}")
                        elif activity['activity_type'] == 'meal':
                            st.write(f"Meal: {activity.get('details', 'Meal')}")
                    
                    with col3:
                        if st.button(
                            "View",
                            key=f"view_activity_{idx}_{activity['user_id']}"
                        ):
                            st.session_state['selected_client_id'] = activity['user_id']
                            st.switch_page('pages/06_Sam_Client_Progress.py')
                    
                    st.write("")
        else:
            st.info("No client activity in the selected time period.")
    
    except Exception as e:
        st.error(f"Error loading activity: {str(e)}")
        logger.error(f"Error fetching client activity: {str(e)}")

st.write('')
st.write('---')
col1, col2 = st.columns(2)

with col1:
    if st.button("View Client Progress", use_container_width=True):
        st.switch_page('pages/06_Sam_Client_Progress.py')

with col2:
    if st.button("Back to Home", use_container_width=True):
        st.switch_page('pages/10_Sam_Home.py')