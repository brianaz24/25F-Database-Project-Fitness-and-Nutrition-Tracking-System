from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection
from datetime import datetime, date, time, timedelta
import decimal

def get_db():
    return db_connection.get_db().cursor()

def serialize_row(row):
    """Convert database row to JSON-serializable dict"""
    if row is None:
        return None
    result = {}
    for key, value in row.items():
        if isinstance(value, (datetime, date)):
            result[key] = value.isoformat() if value else None
        elif isinstance(value, time):
            result[key] = str(value) if value else None
        elif isinstance(value, timedelta):
            result[key] = str(value) if value else None
        elif isinstance(value, decimal.Decimal):
            result[key] = float(value) if value is not None else None
        else:
            result[key] = value
    return result

def serialize_rows(rows):
    """Convert list of database rows to JSON-serializable list"""
    return [serialize_row(row) for row in rows] if rows else []

clients = Blueprint("clients", __name__)


@clients.route("/<int:client_id>/workouts", methods=["GET"])
def get_client_workouts(client_id):
    db = get_db()
    db.execute("SELECT * FROM Workouts WHERE User_ID = %s ORDER BY Workout_Date DESC", (client_id,))
    workouts = db.fetchall()
    db.close()
    
    serialized_workouts = serialize_rows(workouts)
    return jsonify(serialized_workouts), 200


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
    
    serialized_nutrition = serialize_rows(nutrition_data)
    return jsonify(serialized_nutrition), 200


@clients.route("/<int:client_id>/meals", methods=["GET"])
def get_client_meals(client_id):
    db = get_db()
    db.execute("SELECT * FROM Meals WHERE User_ID = %s ORDER BY Meal_Date DESC, Meal_Time DESC", (client_id,))
    meals = db.fetchall()
    db.close()
    
    serialized_meals = serialize_rows(meals)
    return jsonify(serialized_meals), 200


@clients.route("/goals", methods=["GET"])
def get_goals():
    user_id = request.args.get("user_id")
    
    db = get_db()
    if user_id:
        db.execute("SELECT * FROM Goals WHERE user_id = %s ORDER BY start_time DESC", (user_id,))
    else:
        db.execute("SELECT * FROM Goals ORDER BY start_time DESC")
    goals = db.fetchall()
    db.close()
    
    serialized_goals = serialize_rows(goals)
    return jsonify(serialized_goals), 200


@clients.route("/goals", methods=["POST"])
def create_goal():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "User_ID" not in data and "user_id" not in data:
        error = "User_ID is required"
    elif "Goal_Type" not in data and "goal_type" not in data:
        error = "Goal_Type is required"
    elif "start_time" not in data and "Start_Time" not in data:
        error = "start_time is required"
    
    if error is None:
        db = get_db()
        user_id = data.get("User_ID") or data.get("user_id")
        goal_type = data.get("Goal_Type") or data.get("goal_type")
        start_time = data.get("start_time") or data.get("Start_Time") or data.get("Target_Date")
        end_time = data.get("end_time") or data.get("End_Time") or data.get("Target_Date")
        
        db.execute(
            "INSERT INTO Goals (user_id, goal_type, start_time, end_time) VALUES (%s, %s, %s, %s)",
            (user_id, goal_type, start_time, end_time)
        )
        db_connection.get_db().commit()
        goal_id = db.lastrowid
        db.close()
        return jsonify({"message": "Goal created successfully", "goal_id": goal_id}), 201
    
    return jsonify({"error": error}), 400


@clients.route("/goals/<int:goal_id>", methods=["PUT"])
def update_goal(goal_id):
    data = request.get_json()
    error = None
    
    db = get_db()
    db.execute("SELECT * FROM Goals WHERE goal_id = %s", (goal_id,))
    goal = db.fetchone()
    
    if goal is None:
        error = "Goal not found"
    elif not data:
        error = "Request body is required"
    
    if error is None:
        update_fields = []
        params = []
        # Map frontend field names to database column names
        field_mapping = {
            "Goal_Type": "goal_type",
            "goal_type": "goal_type",
            "start_time": "start_time",
            "Start_Time": "start_time",
            "Target_Date": "start_time",  # Map Target_Date to start_time
            "end_time": "end_time",
            "End_Time": "end_time"
        }
        
        for frontend_field, db_field in field_mapping.items():
            if frontend_field in data:
                update_fields.append(f"{db_field} = %s")
                params.append(data[frontend_field])
        
        if not update_fields:
            error = "No valid fields to update"
    
    if error is None:
        params.append(goal_id)
        db.execute(f"UPDATE Goals SET {', '.join(update_fields)} WHERE goal_id = %s", tuple(params))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Goal updated successfully"}), 200
    
    db.close()
    if error == "Goal not found":
        return jsonify({"error": error}), 404
    return jsonify({"error": error}), 400


@clients.route("/goals/<int:goal_id>", methods=["DELETE"])
def delete_goal(goal_id):
    db = get_db()
    db.execute("SELECT * FROM Goals WHERE goal_id = %s", (goal_id,))
    goal = db.fetchone()
    
    error = None
    if goal is None:
        error = "Goal not found"
    
    if error is None:
        db.execute("DELETE FROM Goals WHERE goal_id = %s", (goal_id,))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Goal deleted successfully"}), 200
    
    db.close()
    return jsonify({"error": error}), 404


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

