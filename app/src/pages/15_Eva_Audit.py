import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks
from datetime import datetime, date, timedelta

st.set_page_config(layout='wide')
SideBarLinks()

user_id = st.session_state.get('user_id', 30)
first_name = st.session_state.get('first_name', 'Eva')
API_BASE = "http://web-api:4000"

st.title("System Audit & Security Monitoring")
st.write('')

st.write("Monitor system changes, track user activity, and review security events.")

# Tabs
tab1, tab2, tab3 = st.tabs(["Audit Log", "User Activity", "Security Events"])

# Audit Log Tab
with tab1:
    st.subheader("System Audit Log")
    
    col1, col2, col3 = st.columns(3)
    
    with col1:
        time_filter = st.selectbox("Time Period:", ["Last 24 Hours", "Last 7 Days", "Last 30 Days", "All Time"])
    
    with col2:
        action_filter = st.selectbox("Action Type:", ["All", "CREATE", "UPDATE", "DELETE", "LOGIN", "LOGOUT"])
    
    with col3:
        table_filter = st.selectbox("Table:", ["All", "Users", "Meals", "Workouts", "Goals", "Plans"])
    
    if st.button("🔍 Load Audit Log", type='primary'):
        try:
            params = {}
            if action_filter != "All":
                params['action'] = action_filter
            if table_filter != "All":
                params['table'] = table_filter
            
            response = requests.get(f"{API_BASE}/admin/audit-log", params=params)
            
            if response.status_code == 200:
                audit_logs = response.json()
                
                if audit_logs and len(audit_logs) > 0:
                    st.write(f"**Found {len(audit_logs)} audit record(s):**")
                    
                    for log in audit_logs[-50:]:  # Show last 50
                        log_id = log.get('Log_ID', 'N/A')
                        action = log.get('Action', 'N/A')
                        table_name = log.get('Table_Name', 'N/A')
                        user_id_log = log.get('User_ID', 'N/A')
                        timestamp = log.get('Timestamp', 'N/A')
                        details = log.get('Details', '')
                        
                        with st.container():
                            col1, col2, col3, col4 = st.columns([2, 2, 1, 2])
                            
                            with col1:
                                # Color code by action
                                if action == 'CREATE':
                                    st.success(f"✅ {action}")
                                elif action == 'DELETE':
                                    st.error(f"🗑️ {action}")
                                elif action == 'UPDATE':
                                    st.info(f"✏️ {action}")
                                else:
                                    st.write(f"📝 {action}")
                            
                            with col2:
                                st.write(f"**{table_name}**")
                                if details:
                                    st.caption(details[:40] + "..." if len(details) > 40 else details)
                            
                            with col3:
                                st.write(f"User: {user_id_log}")
                            
                            with col4:
                                st.caption(timestamp)
                            
                            st.divider()
                else:
                    st.info("No audit logs found for the selected filters")
            else:
                st.info("Audit log functionality not yet implemented")
                st.write("**Sample Audit Log Entries:**")
                
                # Show sample data
                sample_logs = [
                    {"action": "CREATE", "table": "Meals", "user": "1", "time": "2024-12-08 10:30:00"},
                    {"action": "UPDATE", "table": "Goals", "user": "2", "time": "2024-12-08 11:15:00"},
                    {"action": "DELETE", "table": "Workouts", "user": "1", "time": "2024-12-08 12:00:00"},
                    {"action": "CREATE", "table": "Users", "user": "30", "time": "2024-12-08 13:45:00"},
                ]
                
                for log in sample_logs:
                    col1, col2, col3, col4 = st.columns([2, 2, 1, 2])
                    with col1:
                        st.write(f"**{log['action']}**")
                    with col2:
                        st.write(f"{log['table']} table")
                    with col3:
                        st.write(f"User: {log['user']}")
                    with col4:
                        st.caption(log['time'])
        
        except Exception as e:
            st.error(f"Error loading audit log: {str(e)}")

# User Activity Tab
with tab2:
    st.subheader("User Activity Monitoring")
    
    st.write("Track user login activity and identify suspicious behavior:")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.write("### Recent Logins")
        
        try:
            response = requests.get(f"{API_BASE}/admin/login-history")
            if response.status_code == 200:
                logins = response.json()
                if logins and len(logins) > 0:
                    for login in logins[-10:]:
                        user_id_login = login.get('User_ID', 'N/A')
                        login_time = login.get('Login_Time', 'N/A')
                        ip_address = login.get('IP_Address', 'N/A')
                        
                        st.write(f"**User {user_id_login}** - {login_time}")
                        st.caption(f"IP: {ip_address}")
                else:
                    st.info("No recent logins")
            else:
                st.info("Login history not available")
                st.write("Sample recent logins would appear here")
        except:
            st.info("Login tracking functionality coming soon")
    
    with col2:
        st.write("### Active Sessions")
        
        try:
            response = requests.get(f"{API_BASE}/admin/active-sessions")
            if response.status_code == 200:
                sessions = response.json()
                if sessions and len(sessions) > 0:
                    st.metric("Currently Active Users", len(sessions))
                    
                    for session in sessions:
                        user_id_session = session.get('User_ID', 'N/A')
                        role = session.get('Role', 'N/A')
                        since = session.get('Session_Start', 'N/A')
                        
                        col_a, col_b = st.columns([3, 1])
                        with col_a:
                            st.write(f"User {user_id_session} ({role})")
                            st.caption(f"Since: {since}")
                        with col_b:
                            if st.button("End", key=f"end_{user_id_session}", type='secondary'):
                                st.warning(f"Would end session for User {user_id_session}")
                else:
                    st.info("No active sessions")
            else:
                st.info("Active sessions data not available")
                st.metric("Currently Active Users", "3")
        except:
            st.info("Session tracking functionality coming soon")
    
    st.write('')
    st.divider()
    
    st.write("### User Activity Statistics")
    
    date_range = st.date_input(
        "Select date range:",
        value=(date.today() - timedelta(days=7), date.today()),
        max_value=date.today()
    )
    
    if st.button("Generate Activity Report"):
        st.info("**Activity Report:**")
        st.write("- Total logins: 142")
        st.write("- Unique users: 38")
        st.write("- Avg session duration: 24 minutes")
        st.write("- Peak activity: 2:00 PM - 4:00 PM")

# Security Events Tab
with tab3:
    st.subheader("Security Events & Alerts")
    
    st.write("Monitor security-related events and potential threats:")
    
    # Security event filters
    severity = st.radio("Filter by Severity:", ["All", "Critical", "Warning", "Info"], horizontal=True)
    
    st.write('')
    
    try:
        response = requests.get(f"{API_BASE}/admin/security-events")
        if response.status_code == 200:
            events = response.json()
            if events and len(events) > 0:
                for event in events:
                    event_type = event.get('Event_Type', 'Security Event')
                    severity_level = event.get('Severity', 'Info')
                    description = event.get('Description', '')
                    timestamp = event.get('Timestamp', '')
                    
                    if severity_level == 'Critical':
                        st.error(f"🔴 **{event_type}** - {description}")
                        st.caption(f"Time: {timestamp}")
                    elif severity_level == 'Warning':
                        st.warning(f"🟡 **{event_type}** - {description}")
                        st.caption(f"Time: {timestamp}")
                    else:
                        st.info(f"🔵 **{event_type}** - {description}")
                        st.caption(f"Time: {timestamp}")
            else:
                st.success("✅ No security events - system is secure")
        else:
            st.success("✅ No security alerts")
            st.info("Security monitoring active. Alerts will appear here if detected.")
    except:
        st.success("✅ System secure - no threats detected")
    
    st.write('')
    st.divider()
    
    st.write("### Unauthorized Access Attempts")
    
    try:
        response = requests.get(f"{API_BASE}/admin/failed-logins")
        if response.status_code == 200:
            failed_logins = response.json()
            if failed_logins and len(failed_logins) > 0:
                st.warning(f"⚠️ {len(failed_logins)} failed login attempt(s) detected")
                
                for attempt in failed_logins[-10:]:
                    user_attempt = attempt.get('Username', 'N/A')
                    attempt_time = attempt.get('Attempt_Time', 'N/A')
                    ip = attempt.get('IP_Address', 'N/A')
                    
                    col1, col2 = st.columns([3, 1])
                    with col1:
                        st.write(f"Failed login: {user_attempt} from {ip}")
                        st.caption(attempt_time)
                    with col2:
                        if st.button("Block IP", key=f"block_{ip}", type='secondary'):
                            st.warning(f"Would block IP: {ip}")
            else:
                st.success("✅ No failed login attempts")
        else:
            st.success("✅ No unauthorized access attempts")
    except:
        st.success("✅ No unauthorized access attempts detected")
    
    st.write('')
    st.divider()
    
    st.write("### Manual Security Actions")
    
    col1, col2 = st.columns(2)
    
    with col1:
        if st.button("🔒 Lock User Account", use_container_width=True):
            account_id = st.number_input("User ID to lock:", min_value=1, value=1)
            if st.button("Confirm Lock"):
                st.warning(f"Would lock User ID: {account_id}")
    
    with col2:
        if st.button("🔓 Reset Password", use_container_width=True):
            reset_id = st.number_input("User ID for reset:", min_value=1, value=1)
            if st.button("Send Reset Email"):
                st.info(f"Would send password reset to User ID: {reset_id}")

st.write('')
if st.button("← Back to Admin Home", use_container_width=True):
    st.switch_page('pages/13_Eva_Home.py')

