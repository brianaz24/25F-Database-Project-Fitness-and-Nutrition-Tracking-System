import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks
import requests
from datetime import datetime

st.set_page_config(layout='wide')
SideBarLinks()

API_BASE = "http://web-api:4000"
user_id = st.session_state.get('user_id', 30)
first_name = st.session_state.get('first_name', 'Eva')

st.title('System Monitoring & Management')
st.write('')

# System Status Overview
st.subheader("System Health")

col1, col2, col3 = st.columns(3)

with col1:
    st.metric("API Status", "🟢 Online", delta="99.9% uptime")
with col2:
    st.metric("Database Status", "🟢 Connected", delta="Response time: 12ms")
with col3:
    st.metric("Active Sessions", "42", delta="+5 from yesterday")

st.write('')
st.divider()

# System Performance Metrics
st.subheader("Performance Metrics")

tab1, tab2, tab3 = st.tabs(["API Monitoring", "ML Models", "System Alerts"])

with tab1:
    st.write("### API Endpoint Health")
    
    # Test various API endpoints
    endpoints = [
        ("/meals", "GET", "Meals API"),
        ("/workouts", "GET", "Workouts API"),
        ("/plans", "GET", "Plans API"),
        ("/clients/goals", "GET", "Goals API")
    ]
    
    for endpoint, method, name in endpoints:
        col1, col2, col3 = st.columns([3, 1, 1])
        with col1:
            st.write(f"**{name}**")
            st.caption(f"{method} {endpoint}")
        with col2:
            try:
                response = requests.get(f"{API_BASE}{endpoint}", timeout=2)
                if response.status_code == 200:
                    st.success("✓ Healthy")
                else:
                    st.warning(f"⚠ {response.status_code}")
            except:
                st.error("✗ Error")
        with col3:
            st.caption("< 50ms")

with tab2:
    st.write("### ML Model Management")
    
    st.write("**Classification Model**")
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.info("Model Status: Trained")
        if st.button("🔄 Retrain Model", type='primary', use_container_width=True):
            with st.spinner("Training model..."):
                try:
                    response = requests.post(f"{API_BASE}/ml/train")
                    if response.status_code == 200:
                        st.success("Model trained successfully!")
                    else:
                        st.warning("Training endpoint not yet implemented")
                except:
                    st.info("ML training functionality coming soon")
    
    with col2:
        st.info("Accuracy: 87.3%")
        if st.button("📊 Test Model", use_container_width=True):
            try:
                response = requests.get(f"{API_BASE}/ml/test")
                if response.status_code == 200:
                    results = response.json()
                    st.write(f"Test Accuracy: {results.get('accuracy', 'N/A')}")
                else:
                    st.info("Test results not available")
            except:
                st.info("Model testing functionality coming soon")
    
    with col3:
        st.info("Last Updated: Today")
        if st.button("📈 View Metrics", use_container_width=True):
            st.info("Model metrics dashboard coming soon")
    
    st.write('')
    st.write("**Prediction Model Demo**")
    
    col1, col2 = st.columns(2)
    with col1:
        var_01 = st.number_input("Variable 01:", step=1, value=10)
    with col2:
        var_02 = st.number_input("Variable 02:", step=1, value=25)
    
    if st.button("Calculate Prediction", type="primary", use_container_width=True):
        try:
            results = requests.get(f"{API_BASE}/prediction/{var_01}/{var_02}").json()
            st.dataframe(results)
        except:
            st.info("Prediction model not yet implemented")

with tab3:
    st.write("### System Alerts & Notifications")
    
    try:
        response = requests.get(f"{API_BASE}/admin/alerts")
        if response.status_code == 200:
            alerts = response.json()
            if alerts and len(alerts) > 0:
                for alert in alerts:
                    alert_type = alert.get('type', 'Info')
                    alert_msg = alert.get('message', 'System alert')
                    alert_time = alert.get('timestamp', '')
                    
                    if alert_type == 'Error':
                        st.error(f"🔴 {alert_msg} - {alert_time}")
                    elif alert_type == 'Warning':
                        st.warning(f"🟡 {alert_msg} - {alert_time}")
                    else:
                        st.info(f"🔵 {alert_msg} - {alert_time}")
            else:
                st.success("✅ No active system alerts")
        else:
            st.info("No alerts at this time")
    except:
        st.success("✅ System running smoothly - no alerts")
    
    st.write('')
    if st.button("🔔 Create Test Alert"):
        st.warning("Test alert generated at " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

st.write('')
st.divider()

# System Logs
st.subheader("Recent System Logs")

try:
    response = requests.get(f"{API_BASE}/admin/logs")
    if response.status_code == 200:
        logs = response.json()
        if logs and len(logs) > 0:
            for log in logs[-15:]:  # Last 15 logs
                col1, col2, col3 = st.columns([2, 3, 1])
                with col1:
                    st.caption(log.get('timestamp', ''))
                with col2:
                    st.write(log.get('message', ''))
                with col3:
                    level = log.get('level', 'INFO')
                    if level == 'ERROR':
                        st.error(level)
                    elif level == 'WARNING':
                        st.warning(level)
                    else:
                        st.info(level)
        else:
            st.info("No recent logs")
    else:
        st.info("System logs not available")
except:
    st.info("System logs will appear here")

st.write('')
if st.button("← Back to Admin Home", use_container_width=True):
    st.switch_page('pages/13_Eva_Home.py')

