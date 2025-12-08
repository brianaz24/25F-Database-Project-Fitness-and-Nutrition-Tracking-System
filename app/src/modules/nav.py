# Idea borrowed from https://github.com/fsmosca/sample-streamlit-authenticator

# This file has function to add certain functionality to the left side bar of the app

import streamlit as st


#### ------------------------ General ------------------------
def HomeNav():
    st.sidebar.page_link("Home.py", label="Home", icon="🏠")


def AboutPageNav():
    st.sidebar.page_link("pages/18_About.py", label="About", icon="🧠")


#### ------------------------ Mark (Everyday User) ------------------------
def MarkHomeNav():
    st.sidebar.page_link("pages/00_Mark_Home.py", label="My Dashboard", icon="🏠")

def MarkLogMealNav():
    st.sidebar.page_link("pages/01_Mark_Log_Meal.py", label="Log Meal", icon="🍽️")

def MarkLogWorkoutNav():
    st.sidebar.page_link("pages/02_Mark_Log_Workout.py", label="Log Workout", icon="💪")

def MarkViewProgressNav():
    st.sidebar.page_link("pages/03_Mark_View_Progress.py", label="View Progress", icon="📊")

def MarkGoalsNav():
    st.sidebar.page_link("pages/04_Mark_Goals.py", label="Manage Goals", icon="🎯")

def MapDemoNav():
    st.sidebar.page_link("pages/02_Map_Demo.py", label="Map Demonstration", icon="🗺️")


## ------------------------ Examples for Role of usaid_worker ------------------------

def usaidWorkerHomeNav():
    st.sidebar.page_link(
      "pages/10_USAID_Worker_Home.py", label="USAID Worker Home", icon="🏠"
    )

def NgoDirectoryNav():
    st.sidebar.page_link("pages/14_NGO_Directory.py", label="NGO Directory", icon="📁")

def AddNgoNav():
    st.sidebar.page_link("pages/15_Add_NGO.py", label="Add New NGO", icon="➕")

def ApiTestNav():
    st.sidebar.page_link("pages/12_API_Test.py", label="Test the API", icon="🛜")

def PredictionNav():
    st.sidebar.page_link(
        "pages/11_Prediction.py", label="Regression Prediction", icon="📈"
    )

def ClassificationNav():
    st.sidebar.page_link(
        "pages/13_Classification.py", label="Classification Demo", icon="🌺"
    )





#### ------------------------ System Admin Role ------------------------
def AdminPageNav():
    st.sidebar.page_link("pages/13_Eva_Home.py", label="Admin Dashboard", icon="🏠")
    st.sidebar.page_link("pages/14_Eva_Users.py", label="User Management", icon="👥")
    st.sidebar.page_link("pages/15_Eva_Audit.py", label="Audit & Security", icon="🔒")
    st.sidebar.page_link("pages/16_Eva_Database.py", label="Database", icon="💾")
    st.sidebar.page_link("pages/17_ML_Model_Mgmt.py", label="System Monitoring", icon="📊")


# --------------------------------Links Function -----------------------------------------------
def SideBarLinks(show_home=False):
    """
    This function handles adding links to the sidebar of the app based upon the logged-in user's role, which was put in the streamlit session_state object when logging in.
    """

    # add a logo to the sidebar always
    st.sidebar.image("assets/logo.png", width=150)

    # If there is no logged in user, redirect to the Home (Landing) page
    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False
        st.switch_page("Home.py")

    if show_home:
        # Show the Home page link (the landing page)
        HomeNav()

    # Show the other page navigators depending on the users' role.
    if st.session_state["authenticated"]:

        # If the user is an everyday user (Mark), show their pages
        if st.session_state["role"] == "everyday_user":
            MarkHomeNav()
            MarkLogMealNav()
            MarkLogWorkoutNav()
            MarkViewProgressNav()
            MarkGoalsNav()

        # If the user is a fitness coach (Sam), show their pages
        if st.session_state["role"] == "fitness_coach":
            st.sidebar.page_link("pages/05_Sam_HomePage.py", label="Coach Dashboard", icon="🏠")
            st.sidebar.page_link("pages/06_Sam_Client_Progress.py", label="Client Progress", icon="📊")
            st.sidebar.page_link("pages/07_Sam_Manage_Plans.py", label="Manage Plans", icon="📋")
            st.sidebar.page_link("pages/08_Sam_View_Alert.py", label="Notifications", icon="🔔")

        # If the user is a dietitian (James), show their pages
        if st.session_state["role"] == "dietitian":
            st.sidebar.page_link("pages/09_James_Home.py", label="Dietitian Dashboard", icon="🏠")
            st.sidebar.page_link("pages/10_James_Client_Meals.py", label="Client Meals", icon="🍽️")
            st.sidebar.page_link("pages/11_James_Analytics.py", label="Analytics", icon="📈")
            st.sidebar.page_link("pages/12_James_Meal_Plans.py", label="Meal Plans", icon="📝")

        # If the user is an administrator, give them access to the administrator pages
        if st.session_state["role"] == "administrator":
            AdminPageNav()

    # Always show the About page at the bottom of the list of links
    AboutPageNav()

    if st.session_state["authenticated"]:
        # Always show a logout button if there is a logged in user
        if st.sidebar.button("Logout"):
            del st.session_state["role"]
            del st.session_state["authenticated"]
            st.switch_page("Home.py")