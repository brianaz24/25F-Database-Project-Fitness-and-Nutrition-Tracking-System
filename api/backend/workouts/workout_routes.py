from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection

def get_db():
    return db_connection.get_db().cursor()

workouts = Blueprint("workouts", __name__)


@workouts.route("/<int:workout_id>", methods=["GET"])
def get_workout(workout_id):
    db = get_db()
    db.execute("SELECT * FROM Workouts WHERE Workout_ID = %s", (workout_id,))
    workout = db.fetchone()
    db.close()
    
    error = None
    if workout is None:
        error = "Workout not found"
    
    if error is None:
        return jsonify(workout), 200
    
    return jsonify({"error": error}), 404


@workouts.route("", methods=["POST"])
def create_workout():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "User_ID" not in data:
        error = "User_ID is required"
    elif "Workout_Date" not in data:
        error = "Workout_Date is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "INSERT INTO Workouts (User_ID, Workout_Date, Workout_Type, Duration_Minutes, Calories_Burned, Notes) VALUES (%s, %s, %s, %s, %s, %s)",
            (data["User_ID"], data["Workout_Date"], data.get("Workout_Type"), data.get("Duration_Minutes"), data.get("Calories_Burned"), data.get("Notes"))
        )
        db_connection.get_db().commit()
        workout_id = db.lastrowid
        db.close()
        return jsonify({"message": "Workout created successfully", "workout_id": workout_id}), 201
    
    return jsonify({"error": error}), 400


@workouts.route("/<int:workout_id>", methods=["PUT"])
def update_workout(workout_id):
    data = request.get_json()
    error = None
    
    db = get_db()
    db.execute("SELECT * FROM Workouts WHERE Workout_ID = %s", (workout_id,))
    workout = db.fetchone()
    
    if workout is None:
        error = "Workout not found"
    elif not data:
        error = "Request body is required"
    
    if error is None:
        update_fields = []
        params = []
        allowed_fields = ["Workout_Date", "Workout_Type", "Duration_Minutes", "Calories_Burned", "Notes"]
        
        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])
        
        if not update_fields:
            error = "No valid fields to update"
    
    if error is None:
        params.append(workout_id)
        db.execute(f"UPDATE Workouts SET {', '.join(update_fields)} WHERE Workout_ID = %s", tuple(params))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Workout updated successfully"}), 200
    
    db.close()
    if error == "Workout not found":
        return jsonify({"error": error}), 404
    return jsonify({"error": error}), 400


@workouts.route("/<int:workout_id>", methods=["DELETE"])
def delete_workout(workout_id):
    db = get_db()
    db.execute("SELECT * FROM Workouts WHERE Workout_ID = %s", (workout_id,))
    workout = db.fetchone()
    
    error = None
    if workout is None:
        error = "Workout not found"
    
    if error is None:
        db.execute("DELETE FROM Workouts WHERE Workout_ID = %s", (workout_id,))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Workout deleted successfully"}), 200
    
    db.close()
    return jsonify({"error": error}), 404


@workouts.route("/metrics/weight", methods=["GET"])
def get_weight_metrics():
    user_id = request.args.get("user_id")
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")
    
    query = "SELECT * FROM Weight_Metrics WHERE 1=1"
    params = []
    
    if user_id:
        query += " AND User_ID = %s"
        params.append(user_id)
    if start_date:
        query += " AND Weight_Date >= %s"
        params.append(start_date)
    if end_date:
        query += " AND Weight_Date <= %s"
        params.append(end_date)
    
    query += " ORDER BY Weight_Date ASC"
    
    db = get_db()
    db.execute(query, params)
    weight_data = db.fetchall()
    db.close()
    
    return jsonify(weight_data), 200

