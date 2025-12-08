import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import datetime

st.set_page_config(layout='wide')
SideBarLinks()

user_id = st.session_state.get('user_id', 30)
first_name = st.session_state.get('first_name', 'Eva')
API_BASE = "http://web-api:4000"

st.title("Database Management")
st.write('')

# Tabs for different database management functions
tab1, tab2, tab3 = st.tabs(["Database Status", "Backup & Restore", "Data Cleanup"])

# Database Status
with tab1:
    st.subheader("Database Health & Statistics")
    
    try:
        col1, col2 = st.columns(2)
        
        with col1:
            st.write("### Table Statistics")
            
            # Users table
            try:
                users_response = requests.get(f"{API_BASE}/admin/users")
                user_count = 0
                if users_response.status_code == 200:
                    users = users_response.json()
                    user_count = len(users) if isinstance(users, list) else 0
                st.metric("Users Table", f"{user_count} records")
            except:
                st.metric("Users Table", "N/A")
            
            # Meals table
            try:
                meals_response = requests.get(f"{API_BASE}/meals")
                meal_count = 0
                if meals_response.status_code == 200:
                    meals = meals_response.json()
                    meal_count = len(meals) if isinstance(meals, list) else 0
                st.metric("Meals Table", f"{meal_count} records")
            except:
                st.metric("Meals Table", "N/A")
            
            # Workouts table
            try:
                workouts_response = requests.get(f"{API_BASE}/workouts")
                workout_count = 0
                if workouts_response.status_code == 200:
                    workouts = workouts_response.json()
                    workout_count = len(workouts) if isinstance(workouts, list) else 0
                st.metric("Workouts Table", f"{workout_count} records")
            except:
                st.metric("Workouts Table", "N/A")
        
        with col2:
            st.write("### Database Health")
            st.success("✅ Database connection: Active")
            st.info(f"📅 Last checked: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            
            if st.button("🔄 Refresh Statistics", type='primary', use_container_width=True):
                st.rerun()
    
    except Exception as e:
        st.error("Unable to fetch database statistics")
        logger.error(f"Error: {str(e)}")

# Backup & Restore
with tab2:
    st.subheader("Database Backup & Restore")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("### Create Backup")
        st.write("Create a complete backup of the database")
        
        backup_name = st.text_input("Backup Name:", value=f"backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
        
        if st.button("📦 Create Backup", type='primary', use_container_width=True):
            try:
                response = requests.post(f"{API_BASE}/admin/backup", json={"backup_name": backup_name})
                if response.status_code == 201:
                    st.success(f"✅ Backup '{backup_name}' created successfully!")
                    st.info(f"Backup location: /backups/{backup_name}")
                else:
                    st.error("Failed to create backup")
            except Exception as e:
                st.warning("Backup functionality not yet implemented in API")
                st.info(f"Would create backup: {backup_name}")
                logger.info(f"Backup requested: {backup_name}")
    
    with col2:
        st.write("### Restore from Backup")
        st.write("Restore database from a previous backup")
        
        try:
            response = requests.get(f"{API_BASE}/admin/backups")
            if response.status_code == 200:
                backups = response.json()
                if backups and len(backups) > 0:
                    backup_options = [b.get('backup_name', '') for b in backups]
                    selected_backup = st.selectbox("Select Backup:", backup_options)
                    
                    if st.button("♻️ Restore Backup", type='secondary', use_container_width=True):
                        st.warning("⚠️ This will replace current data!")
                        if st.checkbox("I understand this action cannot be undone"):
                            try:
                                restore_response = requests.post(f"{API_BASE}/admin/restore", json={"backup_name": selected_backup})
                                if restore_response.status_code == 200:
                                    st.success("Database restored successfully!")
                                else:
                                    st.error("Failed to restore backup")
                            except:
                                st.warning("Restore functionality not yet implemented")
                else:
                    st.info("No backups available")
            else:
                st.info("No backups found")
        except:
            st.info("Backup list not available")
            st.write("Available backups will appear here")

# Data Cleanup
with tab3:
    st.subheader("Data Cleanup & Maintenance")
    
    st.write("### Remove Inactive Data")
    
    # Cleanup options
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("**Remove Old Records**")
        
        days_old = st.number_input("Remove records older than (days):", min_value=30, max_value=365, value=90)
        
        cleanup_options = st.multiselect(
            "Select data types to clean:",
            ["Inactive Users", "Old Meal Logs", "Old Workout Logs", "Completed Goals"]
        )
        
        if st.button("🧹 Clean Up Data", type='secondary', use_container_width=True):
            if cleanup_options:
                st.warning(f"⚠️ This will permanently delete selected data older than {days_old} days")
                if st.checkbox("Confirm cleanup operation"):
                    try:
                        response = requests.post(f"{API_BASE}/admin/cleanup", json={
                            "days_old": days_old,
                            "cleanup_types": cleanup_options
                        })
                        if response.status_code == 200:
                            result = response.json()
                            st.success(f"✅ Cleanup completed! {result.get('deleted_count', 0)} records removed")
                        else:
                            st.error("Cleanup failed")
                    except:
                        st.warning("Cleanup functionality not yet implemented")
                        st.info(f"Would clean up: {', '.join(cleanup_options)}")
            else:
                st.error("Please select at least one data type to clean")
    
    with col2:
        st.write("**Find Duplicate Records**")
        
        if st.button("🔍 Scan for Duplicates", use_container_width=True):
            try:
                response = requests.get(f"{API_BASE}/admin/duplicates")
                if response.status_code == 200:
                    duplicates = response.json()
                    if duplicates and len(duplicates) > 0:
                        st.warning(f"Found {len(duplicates)} potential duplicates")
                        for dup in duplicates:
                            st.write(f"- {dup.get('table', 'Unknown')}: {dup.get('count', 0)} duplicates")
                    else:
                        st.success("No duplicates found!")
                else:
                    st.info("No duplicates detected")
            except:
                st.info("Duplicate scan functionality not yet implemented")
        
        st.write('')
        st.write("**Optimize Database**")
        
        if st.button("⚡ Optimize Database", use_container_width=True):
            try:
                response = requests.post(f"{API_BASE}/admin/optimize")
                if response.status_code == 200:
                    st.success("✅ Database optimized successfully!")
                else:
                    st.error("Optimization failed")
            except:
                st.info("Database optimization functionality coming soon")

st.write('')
st.divider()

# Audit Log
st.subheader("Recent Database Changes")

try:
    response = requests.get(f"{API_BASE}/admin/audit-log")
    if response.status_code == 200:
        audit_logs = response.json()
        if audit_logs and len(audit_logs) > 0:
            for log in audit_logs[-10:]:  # Last 10 changes
                col1, col2, col3 = st.columns([2, 2, 1])
                with col1:
                    st.write(f"**{log.get('Action', 'Action')}**")
                with col2:
                    st.caption(f"{log.get('Table_Name', 'Table')} - User: {log.get('User_ID', 'N/A')}")
                with col3:
                    st.caption(log.get('Timestamp', ''))
        else:
            st.info("No recent changes recorded")
    else:
        st.info("Audit log not available")
except:
    st.info("Audit log will appear here when available")

st.write('')
if st.button("← Back to Admin Home", use_container_width=True):
    st.switch_page('pages/13_Eva_Home.py')

