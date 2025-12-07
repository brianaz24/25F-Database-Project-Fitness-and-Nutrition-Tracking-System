from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection

def get_db():
    return db_connection.get_db().cursor()

clients = Blueprint("clients", __name__)


@clients.route("/<int:client_id>/workouts", methods=["GET"])
def get_client_workouts(client_id):
    db = get_db()
    db.execute("SELECT * FROM Workouts WHERE User_ID = %s ORDER BY Workout_Date DESC", (client_id,))
    workouts = db.fetchall()
    db.close()
    
    return jsonify(workouts), 200


@clients.route("/<int:client_id>/nutrition", methods=["GET"])
def get_client_nutrition(client_id):
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")
    meal_type = request.args.get("meal_type")
    
    query = "SELECT * FROM Meals WHERE User_ID = %s"
    params = [client_id]
    
    if start_date:
        query += " AND Meal_Date >= %s"
        params.append(start_date)
    if end_date:
        query += " AND Meal_Date <= %s"
        params.append(end_date)
    if meal_type:
        query += " AND Meal_Type = %s"
        params.append(meal_type)
    
    query += " ORDER BY Meal_Date DESC, Meal_Time DESC"
    
    db = get_db()
    db.execute(query, tuple(params))
    nutrition_data = db.fetchall()
    db.close()
    
    return jsonify(nutrition_data), 200


@clients.route("/<int:client_id>/meals", methods=["GET"])
def get_client_meals(client_id):
    db = get_db()
    db.execute("SELECT * FROM Meals WHERE User_ID = %s ORDER BY Meal_Date DESC, Meal_Time DESC", (client_id,))
    meals = db.fetchall()
    db.close()
    
    return jsonify(meals), 200


@clients.route("/goals", methods=["GET"])
def get_goals():
    user_id = request.args.get("user_id")
    
    db = get_db()
    if user_id:
        db.execute("SELECT * FROM Goals WHERE User_ID = %s", (user_id,))
    else:
        db.execute("SELECT * FROM Goals")
    goals = db.fetchall()
    db.close()
    
    return jsonify(goals), 200


@clients.route("/goals", methods=["POST"])
def create_goal():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "User_ID" not in data:
        error = "User_ID is required"
    elif "Goal_Type" not in data:
        error = "Goal_Type is required"
    elif "Target_Value" not in data:
        error = "Target_Value is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "INSERT INTO Goals (User_ID, Goal_Type, Target_Value, Target_Date, Description) VALUES (%s, %s, %s, %s, %s)",
            (data["User_ID"], data["Goal_Type"], data["Target_Value"], data.get("Target_Date"), data.get("Description"))
        )
        db_connection.get_db().commit()
        goal_id = db.lastrowid
        db.close()
        return jsonify({"message": "Goal created successfully", "goal_id": goal_id}), 201
    
    return jsonify({"error": error}), 400


@clients.route("/coaches/<int:coach_id>/notifications", methods=["GET"])
def get_coach_notifications(coach_id):
    db = get_db()
    db.execute(
        "SELECT * FROM Notifications WHERE Coach_ID = %s AND Notification_Type = 'missed_workout' ORDER BY Notification_Date DESC",
        (coach_id,)
    )
    notifications = db.fetchall()
    db.close()
    
    return jsonify(notifications), 200

