import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks
import requests
from datetime import datetime, date, timedelta
from collections import defaultdict, Counter

st.set_page_config(layout="wide")
SideBarLinks()

API_BASE = "http://web-api:4000"
user_id = st.session_state.get('user_id', 20)
first_name = st.session_state.get('first_name', 'James')

st.title("Nutrition Analytics Dashboard")
st.write('')

# Analytics Options
col1, col2, col3 = st.columns(3)

with col1:
    analysis_scope = st.selectbox("Analysis Scope:", ["All Clients", "Specific Client", "Date Range"])

with col2:
    if analysis_scope == "Specific Client":
        client_id = st.number_input("Client ID:", min_value=1, value=1, step=1)

with col3:
    time_period = st.selectbox("Time Period:", ["Last 7 Days", "Last 30 Days", "Last 90 Days", "All Time"])

# Calculate date range based on selection
if time_period == "Last 7 Days":
    days = 7
elif time_period == "Last 30 Days":
    days = 30
elif time_period == "Last 90 Days":
    days = 90
else:
    days = 365 * 10  # All time

start_date = date.today() - timedelta(days=days)

st.write('')
st.divider()

# Tabs for different analytics
tab1, tab2, tab3 = st.tabs(["Calorie Trends", "Meal Patterns", "Client Comparisons"])

# Calorie Trends
with tab1:
    st.subheader("Calorie Intake Trends")
    
    try:
        # Get meals data
        if analysis_scope == "Specific Client":
            response = requests.get(f"{API_BASE}/clients/{client_id}/meals")
        else:
            response = requests.get(f"{API_BASE}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            
            # Filter by date
            if meals and isinstance(meals, list):
                meals = [m for m in meals if datetime.strptime(m.get('Meal_Date', '2000-01-01'), '%Y-%m-%d').date() >= start_date]
            
            if meals and len(meals) > 0:
                # Group by date
                calories_by_date = defaultdict(int)
                meals_by_date = defaultdict(int)
                
                for meal in meals:
                    meal_date = meal.get('Meal_Date', 'Unknown')
                    calories_by_date[meal_date] += meal.get('Calories', 0)
                    meals_by_date[meal_date] += 1
                
                # Display metrics
                col1, col2, col3, col4 = st.columns(4)
                
                with col1:
                    total_meals = len(meals)
                    st.metric("Total Meals", total_meals)
                
                with col2:
                    total_calories = sum(calories_by_date.values())
                    st.metric("Total Calories", f"{total_calories:,}")
                
                with col3:
                    avg_per_meal = total_calories // total_meals if total_meals > 0 else 0
                    st.metric("Avg Calories/Meal", avg_per_meal)
                
                with col4:
                    days_tracked = len(calories_by_date)
                    avg_per_day = total_calories // days_tracked if days_tracked > 0 else 0
                    st.metric("Avg Calories/Day", f"{avg_per_day:,}")
                
                st.write('')
                
                # Create simple visualization using st.bar_chart
                st.write("### Daily Calorie Intake")
                
                # Prepare data for chart
                dates = sorted(calories_by_date.keys())
                calories = [calories_by_date[d] for d in dates]
                
                # Create a dictionary for the chart
                chart_data = {date_str: cal for date_str, cal in zip(dates, calories)}
                
                st.bar_chart(chart_data)
                
                st.write('')
                st.write("### Daily Breakdown")
                
                # Show detailed breakdown
                for meal_date in sorted(calories_by_date.keys(), reverse=True)[:14]:  # Last 14 days
                    col1, col2, col3 = st.columns([2, 1, 1])
                    
                    with col1:
                        # Format date nicely
                        try:
                            date_obj = datetime.strptime(meal_date, '%Y-%m-%d')
                            if date_obj.date() == date.today():
                                display_date = "Today"
                            elif date_obj.date() == date.today() - timedelta(days=1):
                                display_date = "Yesterday"
                            else:
                                display_date = date_obj.strftime('%A, %B %d')
                        except:
                            display_date = meal_date
                        
                        st.write(f"**{display_date}**")
                    
                    with col2:
                        st.write(f"{meals_by_date[meal_date]} meals")
                    
                    with col3:
                        day_cal = calories_by_date[meal_date]
                        st.write(f"**{day_cal} cal**")
                        
                        # Color code based on calories
                        if day_cal < 1200:
                            st.caption("🔵 Low")
                        elif day_cal > 2500:
                            st.caption("🔴 High")
                        else:
                            st.caption("🟢 Normal")
                
                st.write('')
                
                # Nutritional recommendations
                st.write("### Analysis & Recommendations")
                
                if avg_per_day < 1500:
                    st.warning("⚠️ **Low Average Intake:** Client may need to increase daily caloric intake for optimal health.")
                elif avg_per_day > 3000:
                    st.warning("⚠️ **High Average Intake:** Consider portion control and meal planning guidance.")
                else:
                    st.success("✅ **Healthy Range:** Caloric intake appears balanced and sustainable.")
                
                # Meal frequency analysis
                avg_meals_per_day = total_meals / days_tracked if days_tracked > 0 else 0
                st.info(f"📊 Average meals per day: {avg_meals_per_day:.1f}")
                
                if avg_meals_per_day < 2:
                    st.caption("Consider recommending more frequent, smaller meals")
                elif avg_meals_per_day > 5:
                    st.caption("High meal frequency - ensure portion sizes are appropriate")
            
            else:
                st.info("No meal data available for the selected period")
        else:
            st.warning("Unable to load meal data")
    
    except Exception as e:
        st.error(f"Error loading data: {str(e)}")
        logger.error(f"Error: {str(e)}")

# Meal Patterns
with tab2:
    st.subheader("Meal Pattern Analysis")
    
    try:
        # Get meals data
        if analysis_scope == "Specific Client":
            response = requests.get(f"{API_BASE}/clients/{client_id}/meals")
        else:
            response = requests.get(f"{API_BASE}/meals")
        
        if response.status_code == 200:
            meals = response.json()
            
            # Filter by date
            if meals and isinstance(meals, list):
                meals = [m for m in meals if datetime.strptime(m.get('Meal_Date', '2000-01-01'), '%Y-%m-%d').date() >= start_date]
            
            if meals and len(meals) > 0:
                # Analyze meal names/types
                meal_names = [m.get('Meal_Name', 'Unknown') for m in meals]
                meal_counter = Counter(meal_names)
                
                st.write("### Most Common Meals")
                
                for meal_name, count in meal_counter.most_common(10):
                    col1, col2 = st.columns([3, 1])
                    with col1:
                        st.write(f"**{meal_name}**")
                    with col2:
                        st.write(f"{count} times")
                
                st.write('')
                st.write("### Meal Time Distribution")
                
                # Analyze meal times
                meal_hours = []
                for meal in meals:
                    meal_time = meal.get('Meal_Time', '12:00:00')
                    try:
                        hour = int(meal_time.split(':')[0])
                        meal_hours.append(hour)
                    except:
                        pass
                
                if meal_hours:
                    hour_counter = Counter(meal_hours)
                    
                    # Group into meal periods
                    breakfast = sum(hour_counter.get(h, 0) for h in range(5, 11))
                    lunch = sum(hour_counter.get(h, 0) for h in range(11, 15))
                    dinner = sum(hour_counter.get(h, 0) for h in range(17, 22))
                    snacks = len(meal_hours) - breakfast - lunch - dinner
                    
                    col1, col2, col3, col4 = st.columns(4)
                    
                    with col1:
                        st.metric("🌅 Breakfast", f"{breakfast} meals")
                    with col2:
                        st.metric("☀️ Lunch", f"{lunch} meals")
                    with col3:
                        st.metric("🌙 Dinner", f"{dinner} meals")
                    with col4:
                        st.metric("🍎 Snacks", f"{snacks} meals")
                    
                    # Meal timing recommendations
                    st.write('')
                    if breakfast < lunch * 0.5:
                        st.info("💡 Low breakfast frequency detected. Consider encouraging regular breakfast.")
                    if dinner > lunch * 1.5:
                        st.info("💡 Dinner portions appear larger than lunch. Consider meal balance.")
                
                st.write('')
                st.write("### Calorie Distribution by Meal Size")
                
                # Categorize by calorie range
                very_low = sum(1 for m in meals if m.get('Calories', 0) < 200)
                low = sum(1 for m in meals if 200 <= m.get('Calories', 0) < 400)
                moderate = sum(1 for m in meals if 400 <= m.get('Calories', 0) < 700)
                high = sum(1 for m in meals if 700 <= m.get('Calories', 0) < 1000)
                very_high = sum(1 for m in meals if m.get('Calories', 0) >= 1000)
                
                col1, col2, col3, col4, col5 = st.columns(5)
                
                with col1:
                    st.metric("< 200 cal", very_low)
                    st.caption("Snacks")
                with col2:
                    st.metric("200-400", low)
                    st.caption("Light meals")
                with col3:
                    st.metric("400-700", moderate)
                    st.caption("Regular meals")
                with col4:
                    st.metric("700-1000", high)
                    st.caption("Large meals")
                with col5:
                    st.metric("> 1000 cal", very_high)
                    st.caption("Very large")
            
            else:
                st.info("No meal data available for analysis")
        else:
            st.warning("Unable to load meal data")
    
    except Exception as e:
        st.error(f"Error loading data: {str(e)}")

# Client Comparisons
with tab3:
    st.subheader("Client Comparison Analytics")
    
    if analysis_scope == "All Clients":
        try:
            response = requests.get(f"{API_BASE}/meals")
            
            if response.status_code == 200:
                meals = response.json()
                
                if meals and isinstance(meals, list):
                    # Filter by date
                    meals = [m for m in meals if datetime.strptime(m.get('Meal_Date', '2000-01-01'), '%Y-%m-%d').date() >= start_date]
                    
                    if len(meals) > 0:
                        # Group by client
                        meals_by_client = defaultdict(list)
                        for meal in meals:
                            client = meal.get('User_ID', 'Unknown')
                            meals_by_client[client].append(meal)
                        
                        st.write(f"### Client Overview ({len(meals_by_client)} clients)")
                        
                        # Create comparison table
                        client_stats = []
                        
                        for client_id_key, client_meals in meals_by_client.items():
                            total_cal = sum(m.get('Calories', 0) for m in client_meals)
                            avg_cal = total_cal // len(client_meals) if len(client_meals) > 0 else 0
                            
                            # Get unique dates
                            dates = set(m.get('Meal_Date') for m in client_meals)
                            days_active = len(dates)
                            
                            avg_per_day = total_cal // days_active if days_active > 0 else 0
                            
                            client_stats.append({
                                "Client ID": client_id_key,
                                "Total Meals": len(client_meals),
                                "Days Active": days_active,
                                "Avg Cal/Day": avg_per_day,
                                "Avg Cal/Meal": avg_cal
                            })
                        
                        # Sort by total meals
                        client_stats.sort(key=lambda x: x["Total Meals"], reverse=True)
                        
                        # Display top clients
                        for stats in client_stats[:10]:  # Top 10 clients
                            with st.expander(f"Client #{stats['Client ID']} - {stats['Total Meals']} meals logged"):
                                col1, col2, col3, col4 = st.columns(4)
                                
                                with col1:
                                    st.metric("Total Meals", stats['Total Meals'])
                                with col2:
                                    st.metric("Days Active", stats['Days Active'])
                                with col3:
                                    st.metric("Avg Cal/Day", f"{stats['Avg Cal/Day']:,}")
                                with col4:
                                    st.metric("Avg Cal/Meal", stats['Avg Cal/Meal'])
                                
                                # Recommendations
                                if stats['Avg Cal/Day'] < 1500:
                                    st.warning("⚠️ Low daily intake - may need nutritional guidance")
                                elif stats['Avg Cal/Day'] > 3000:
                                    st.warning("⚠️ High daily intake - consider portion control advice")
                                else:
                                    st.success("✅ Intake within healthy range")
                        
                        st.write('')
                        st.write("### Overall Statistics")
                        
                        # Overall stats
                        total_tracked_meals = len(meals)
                        total_tracked_calories = sum(m.get('Calories', 0) for m in meals)
                        overall_avg = total_tracked_calories // total_tracked_meals if total_tracked_meals > 0 else 0
                        
                        col1, col2, col3 = st.columns(3)
                        
                        with col1:
                            st.metric("Total Clients Tracked", len(meals_by_client))
                        with col2:
                            st.metric("Total Meals Analyzed", total_tracked_meals)
                        with col3:
                            st.metric("Overall Avg Cal/Meal", overall_avg)
                    
                    else:
                        st.info("No meal data available for the selected period")
                else:
                    st.info("No meal data available")
            else:
                st.warning("Unable to load meal data")
        
        except Exception as e:
            st.error(f"Error loading data: {str(e)}")
    else:
        st.info("Client comparison is only available when 'All Clients' scope is selected")

st.write('')
if st.button("← Back to Dietitian Home", use_container_width=True):
    st.switch_page('pages/09_James_Home.py')
