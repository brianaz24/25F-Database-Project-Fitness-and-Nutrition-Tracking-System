import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks
import requests
from datetime import date, timedelta

st.set_page_config(layout="wide")
SideBarLinks()

API_BASE = "http://web-api:4000"
user_id = st.session_state.get('user_id', 20)
first_name = st.session_state.get('first_name', 'James')

st.title("Meal Plan Recommendations")
st.write('')

st.write("Create personalized meal plans and nutrition recommendations for clients based on their data.")

# Tabs
tab1, tab2, tab3 = st.tabs(["View Client Meal Plans", "Create New Plan", "Nutrition Templates"])

# View Client Meal Plans Tab
with tab1:
    st.subheader("Client Meal Plans")
    
    client_id = st.number_input("Enter Client ID:", min_value=1, value=1, step=1)
    
    if st.button("Load Client Meal Plan", type='primary'):
        try:
            # Get client meals
            meals_response = requests.get(f"{API_BASE}/clients/{client_id}/meals")
            
            if meals_response.status_code == 200:
                meals = meals_response.json()
                
                if meals and len(meals) > 0:
                    # Calculate nutritional summary
                    total_meals = len(meals)
                    total_calories = sum(m.get('Calories', 0) for m in meals)
                    avg_calories = total_calories // total_meals if total_meals > 0 else 0
                    
                    st.write(f"### Current Intake Analysis for Client #{client_id}")
                    
                    col1, col2, col3 = st.columns(3)
                    
                    with col1:
                        st.metric("Total Meals Logged", total_meals)
                    with col2:
                        st.metric("Average Calories/Meal", avg_calories)
                    with col3:
                        # Calculate unique days
                        unique_dates = set(m.get('Meal_Date') for m in meals if m.get('Meal_Date'))
                        avg_daily = total_calories // len(unique_dates) if len(unique_dates) > 0 else 0
                        st.metric("Avg Daily Calories", f"{avg_daily:,}")
                    
                    st.write('')
                    
                    # Recommendations based on data
                    st.write("### Dietary Recommendations")
                    
                    if avg_daily < 1500:
                        st.warning("⚠️ **Low Caloric Intake Detected**")
                        st.write("**Recommendation:** Increase portion sizes or add healthy snacks")
                        st.write("- Add: Nuts, avocados, whole grain toast")
                        st.write("- Target: 1800-2000 calories/day")
                    elif avg_daily > 3000:
                        st.warning("⚠️ **High Caloric Intake Detected**")
                        st.write("**Recommendation:** Reduce portion sizes and focus on nutrient-dense foods")
                        st.write("- Reduce: Fried foods, sugary drinks")
                        st.write("- Target: 2000-2500 calories/day")
                    else:
                        st.success("✅ **Caloric Intake Appears Balanced**")
                        st.write("**Recommendation:** Maintain current eating patterns")
                        st.write("- Focus on: Consistent meal timing")
                        st.write("- Include: Variety of fruits and vegetables")
                    
                    st.write('')
                    
                    # Meal frequency analysis
                    avg_meals_per_day = total_meals / len(unique_dates) if len(unique_dates) > 0 else 0
                    st.write(f"**Meal Frequency:** {avg_meals_per_day:.1f} meals/day")
                    
                    if avg_meals_per_day < 2:
                        st.info("💡 Recommend: 3-4 smaller meals throughout the day")
                    elif avg_meals_per_day > 5:
                        st.info("💡 High meal frequency - ensure portion control")
                    
                    st.write('')
                    
                    # Create button to save recommendations
                    if st.button("📝 Save Recommendations to Client Profile", use_container_width=True):
                        st.success("Recommendations saved (feature to be implemented)")
                
                else:
                    st.info("No meal data available for this client")
            else:
                st.warning("Unable to load client meal data")
        
        except Exception as e:
            st.error(f"Error: {str(e)}")

# Create New Plan Tab
with tab2:
    st.subheader("Create Personalized Meal Plan")
    
    with st.form("create_meal_plan_form"):
        st.write("**Client Information:**")
        
        col1, col2 = st.columns(2)
        
        with col1:
            plan_client_id = st.number_input("Client ID *", min_value=1, value=1, step=1)
            plan_name = st.text_input("Plan Name *", placeholder="e.g., Weight Loss Plan - Week 1")
        
        with col2:
            start_date = st.date_input("Start Date *", value=date.today())
            duration_weeks = st.number_input("Duration (weeks) *", min_value=1, max_value=12, value=4)
        
        st.write('')
        st.write("**Nutritional Goals:**")
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            daily_calorie_target = st.number_input("Daily Calorie Target *", min_value=1000, max_value=5000, value=2000, step=100)
        
        with col2:
            protein_target = st.number_input("Protein (g/day)", min_value=0, max_value=300, value=150)
        
        with col3:
            meals_per_day = st.number_input("Meals per Day", min_value=2, max_value=6, value=3)
        
        st.write('')
        st.write("**Dietary Restrictions:**")
        
        restrictions = st.multiselect(
            "Select any restrictions:",
            ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Nut Allergies", "Low Sodium", "Low Sugar"]
        )
        
        st.write('')
        st.write("**Meal Plan Details:**")
        
        breakfast_suggestion = st.text_area("Breakfast Suggestions:", placeholder="e.g., Oatmeal with berries, Greek yogurt")
        lunch_suggestion = st.text_area("Lunch Suggestions:", placeholder="e.g., Grilled chicken salad, quinoa bowl")
        dinner_suggestion = st.text_area("Dinner Suggestions:", placeholder="e.g., Baked salmon with vegetables")
        
        notes = st.text_area("Additional Notes:", placeholder="Special instructions or considerations...")
        
        submitted = st.form_submit_button("Create Meal Plan", type='primary', use_container_width=True)
        
        if submitted:
            if not all([plan_client_id, plan_name, daily_calorie_target]):
                st.error("Please fill in all required fields (*)")
            else:
                plan_data = {
                    "Client_ID": plan_client_id,
                    "Dietitian_ID": user_id,
                    "Plan_Name": plan_name,
                    "Start_Date": str(start_date),
                    "Duration_Weeks": duration_weeks,
                    "Daily_Calorie_Target": daily_calorie_target,
                    "Protein_Target": protein_target,
                    "Meals_Per_Day": meals_per_day,
                    "Restrictions": restrictions,
                    "Breakfast": breakfast_suggestion,
                    "Lunch": lunch_suggestion,
                    "Dinner": dinner_suggestion,
                    "Notes": notes
                }
                
                try:
                    response = requests.post(f"{API_BASE}/meal-plans", json=plan_data)
                    if response.status_code == 201:
                        result = response.json()
                        st.success(f"✅ Meal plan '{plan_name}' created successfully!")
                        st.info(f"Plan ID: {result.get('plan_id', 'N/A')}")
                        st.balloons()
                    else:
                        st.info("Meal plan creation endpoint not yet implemented")
                        st.info(f"Would create plan: {plan_name} for Client #{plan_client_id}")
                except:
                    st.info(f"Would create meal plan: {plan_name}")
                    logger.info(f"Dietitian {user_id} creating meal plan: {plan_name}")

# Nutrition Templates Tab
with tab3:
    st.subheader("Quick Nutrition Templates")
    
    st.write("Select a pre-made template to quickly create a meal plan:")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("### Weight Loss Plans")
        
        if st.button("🔥 1500 Cal/Day Plan", use_container_width=True):
            st.info("""
            **1500 Calorie Weight Loss Plan:**
            - Breakfast: 350 cal (Oatmeal, fruit, coffee)
            - Lunch: 450 cal (Lean protein, vegetables)
            - Dinner: 500 cal (Fish/chicken, greens)
            - Snacks: 200 cal (Nuts, yogurt)
            """)
        
        if st.button("⚡ 1800 Cal/Day Plan", use_container_width=True):
            st.info("""
            **1800 Calorie Moderate Plan:**
            - Breakfast: 400 cal
            - Lunch: 550 cal
            - Dinner: 650 cal
            - Snacks: 200 cal
            """)
        
        st.write('')
        st.write("### High Protein Plans")
        
        if st.button("💪 Muscle Building Plan", use_container_width=True):
            st.info("""
            **High Protein (2500 cal):**
            - 200g protein/day
            - 5-6 meals throughout day
            - Focus: Lean meats, eggs, legumes
            """)
    
    with col2:
        st.write("### Special Dietary Plans")
        
        if st.button("🌱 Vegetarian Plan", use_container_width=True):
            st.info("""
            **Vegetarian Balanced Plan:**
            - Protein: Lentils, tofu, beans
            - Varied vegetables and fruits
            - Whole grains
            - 2000 calories/day
            """)
        
        if st.button("🥑 Mediterranean Diet", use_container_width=True):
            st.info("""
            **Mediterranean Plan:**
            - Olive oil, fish, vegetables
            - Whole grains, legumes
            - Limited red meat
            - 2200 calories/day
            """)
        
        st.write('')
        st.write("### Maintenance Plans")
        
        if st.button("⚖️ Balanced Maintenance", use_container_width=True):
            st.info("""
            **Maintenance (2000-2500 cal):**
            - Balanced macros
            - Variety of food groups
            - Sustainable long-term
            """)
    
    st.write('')
    st.divider()
    
    st.write("### Nutritional Guidelines")
    
    with st.expander("📚 Daily Caloric Needs by Activity Level"):
        st.write("""
        **Sedentary (little to no exercise):**
        - Women: 1600-2000 calories
        - Men: 2000-2400 calories
        
        **Moderately Active (moderate exercise 3-5 days/week):**
        - Women: 2000-2200 calories
        - Men: 2400-2800 calories
        
        **Very Active (hard exercise 6-7 days/week):**
        - Women: 2400+ calories
        - Men: 3000+ calories
        """)
    
    with st.expander("🍎 Macronutrient Recommendations"):
        st.write("""
        **Balanced Diet Macros:**
        - Carbohydrates: 45-65% of total calories
        - Protein: 10-35% of total calories
        - Fat: 20-35% of total calories
        
        **Weight Loss:**
        - Higher protein (30-35%)
        - Moderate carbs (30-40%)
        - Moderate fat (25-30%)
        
        **Athletic Performance:**
        - Higher carbs (50-60%)
        - Moderate protein (20-30%)
        - Lower fat (20-25%)
        """)

st.write('')
if st.button("← Back to Dietitian Home", use_container_width=True):
    st.switch_page('pages/09_James_Home.py')

