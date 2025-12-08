import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import date

st.set_page_config(layout='wide')
SideBarLinks()

user_id = st.session_state.get('user_id', 20)
first_name = st.session_state.get('first_name', 'James')
API_BASE = "http://web-api:4000"

st.title(f"Welcome, Dietitian {first_name}!")
st.write('')

# Nutrition Dashboard
st.subheader("Nutrition Dashboard Overview")

try:
    # Get all meals for analysis
    meals_response = requests.get(f"{API_BASE}/meals")
    meals_data = []
    total_meals = 0
    total_calories = 0
    
    if meals_response.status_code == 200:
        meals_data = meals_response.json()
        if isinstance(meals_data, list):
            total_meals = len(meals_data)
            total_calories = sum(m.get('Calories', 0) for m in meals_data)
    
    # Get user count for client analysis
    users_response = requests.get(f"{API_BASE}/admin/users")
    client_count = 0
    if users_response.status_code == 200:
        users = users_response.json()
        client_count = len(users) if isinstance(users, list) else 0
    
    # Display metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        st.metric("Active Clients", client_count)
    
    with col2:
        st.metric("Total Meals Analyzed", total_meals)
    
    with col3:
        avg_calories = total_calories // total_meals if total_meals > 0 else 0
        st.metric("Avg Calories/Meal", f"{avg_calories}")
    
    with col4:
        # Count today's meals
        today_str = str(date.today())
        today_meals = sum(1 for m in meals_data if m.get('Meal_Date') == today_str) if meals_data else 0
        st.metric("Today's Meals Logged", today_meals)

except Exception as e:
    st.info("Loading nutrition data...")
    logger.error(f"Error fetching stats: {str(e)}")

st.write('')
st.divider()

# Quick Actions
st.subheader("Dietitian Actions")

col1, col2, col3 = st.columns(3)

with col1:
    if st.button('📊 View Client Meals', type='primary', use_container_width=True):
        st.switch_page('pages/10_James_Client_Meals.py')
    if st.button('📈 Nutrition Analytics', type='primary', use_container_width=True):
        st.switch_page('pages/11_James_Analytics.py')

with col2:
    if st.button('💬 Review Comments', use_container_width=True):
        st.info("Comments review feature coming soon")
    if st.button('🔍 Search Client Data', use_container_width=True):
        st.info("Advanced search coming soon")

with col3:
    if st.button('📝 Create Meal Plan', use_container_width=True):
        st.info("Meal plan creation feature coming soon")
    if st.button('⚙️ Analysis Settings', use_container_width=True):
        st.info("Settings coming soon")

st.write('')
st.divider()

# Recent Meals Review
st.subheader("Recent Meals Requiring Review")

try:
    meals_response = requests.get(f"{API_BASE}/meals")
    
    if meals_response.status_code == 200:
        meals = meals_response.json()
        
        if meals and isinstance(meals, list) and len(meals) > 0:
            st.write(f"**Showing last 10 meals:**")
            
            for meal in meals[-10:]:  # Show last 10 meals
                meal_name = meal.get('Meal_Name', 'Meal')
                meal_id = meal.get('Meal_ID')
                user_id_meal = meal.get('User_ID', 'N/A')
                meal_date = meal.get('Meal_Date', 'N/A')
                meal_time = meal.get('Meal_Time', 'N/A')
                calories = meal.get('Calories', 0)
                
                with st.container():
                    col1, col2, col3, col4 = st.columns([3, 2, 1, 1])
                    
                    with col1:
                        st.write(f"**{meal_name}**")
                        st.caption(f"Meal ID: {meal_id}")
                    
                    with col2:
                        st.write(f"Client ID: {user_id_meal}")
                        st.caption(f"{meal_date} {meal_time}")
                    
                    with col3:
                        st.write(f"**{calories} cal**")
                    
                    with col4:
                        if st.button("Review", key=f"review_{meal_id}"):
                            st.session_state['selected_meal_id'] = meal_id
                            st.switch_page('pages/10_James_Client_Meals.py')
                    
                    st.divider()
        else:
            st.info("No meals to review at this time")
    else:
        st.warning("Unable to load meals data")

except Exception as e:
    st.info("Meal review queue will appear here")
    logger.error(f"Error loading meals: {str(e)}")

st.write('')

# Nutrition Insights
st.subheader("Quick Nutrition Insights")

try:
    meals_response = requests.get(f"{API_BASE}/meals")
    
    if meals_response.status_code == 200:
        meals = meals_response.json()
        
        if meals and isinstance(meals, list) and len(meals) > 0:
            # Calculate some quick stats
            high_calorie_meals = sum(1 for m in meals if m.get('Calories', 0) > 800)
            low_calorie_meals = sum(1 for m in meals if m.get('Calories', 0) < 200)
            
            col1, col2 = st.columns(2)
            
            with col1:
                if high_calorie_meals > 0:
                    st.warning(f"⚠️ {high_calorie_meals} high-calorie meals (>800 cal) logged")
                else:
                    st.success("✅ No concerning high-calorie meals")
            
            with col2:
                if low_calorie_meals > len(meals) * 0.3:
                    st.info(f"ℹ️ {low_calorie_meals} low-calorie meals (<200 cal) - May need review")
                else:
                    st.success("✅ Calorie distribution looks balanced")

except Exception as e:
    st.info("Nutrition insights will appear here")
    logger.error(f"Error: {str(e)}")
