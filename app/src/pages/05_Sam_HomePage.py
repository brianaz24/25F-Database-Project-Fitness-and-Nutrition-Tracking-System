import logging
logger = logging.getLogger(__name__)

import streamlit as st
import requests
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')

API_BASE = "http://api:4000"

SideBarLinks()

user_id = st.session_state.get('user_id', 2)
first_name = st.session_state.get('first_name', 'Sam')

st.title(f"Welcome Coach {st.session_state['first_name']}!")
st.write('')
st.write('')
st.write('### Your Coaching Dashboard')

col1, col2, col3 = st.columns(3)

try:
    clients_count = 5
    
    plans_response = requests.get(f"{API_BASE}/plans")
    plans_count = 0
    if plans_response.status_code == 200:
        plans = plans_response.json()
        plans_count = len(plans) if isinstance(plans, list) else 0
    
    alerts_response = requests.get(f"{API_BASE}/clients/coaches/{user_id}/notifications")
    alerts_count = 0
    if alerts_response.status_code == 200:
        alerts = alerts_response.json()
        alerts_count = len(alerts) if isinstance(alerts, list) else 0
    
    with col1:
        st.metric("Total Clients", clients_count)
    
    with col2:
        st.metric("Active Plans", plans_count)
    
    with col3:
        st.metric("Alerts", alerts_count, delta=None if alerts_count == 0 else "Action needed")

except Exception as e:
    st.info("Stats will be available once clients are added to your roster.")
    logger.error(f"Error fetching coach stats: {str(e)}")

st.write('')
st.write('')
st.write('### Coach Actions')

col1, col2 = st.columns(2)

with col1:
    if st.button('Monitor Client Progress', type='primary', use_container_width=True):
        st.switch_page('pages/06_Sam_Client_Progress.py')
    
    if st.button('Manage Workout Plans', type='primary', use_container_width=True):
        st.switch_page('pages/07_Sam_Manage_Plans.py')

with col2:
    if st.button('View Client Alerts', type='primary', use_container_width=True):
        st.switch_page('pages/08_Sam_View_Alert.py')
    
    if st.button('View All Clients', use_container_width=True):
        st.switch_page('pages/06_Sam_Client_Progress.py')

st.write('')
st.write('')
st.write('### Recent Client Activity')

try:
    st.info("Recent client activity will appear here once clients start logging their data.")
    
except Exception as e:
    st.info("Recent activity will appear here once clients start logging their data.")
    logger.error(f"Error fetching recent activity: {str(e)}")