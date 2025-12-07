from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection

def get_db():
    return db_connection.get_db().cursor()

plans = Blueprint("plans", __name__)


@plans.route("", methods=["GET"])
def get_plans():
    db = get_db()
    db.execute("SELECT * FROM Plans")
    plans = db.fetchall()
    db.close()
    
    return jsonify(plans), 200


@plans.route("", methods=["POST"])
def create_plan():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "Plan_Name" not in data:
        error = "Plan_Name is required"
    elif "Client_ID" not in data:
        error = "Client_ID is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "INSERT INTO Plans (Plan_Name, Client_ID, Start_Date, End_Date, Description) VALUES (%s, %s, %s, %s, %s)",
            (data["Plan_Name"], data["Client_ID"], data.get("Start_Date"), data.get("End_Date"), data.get("Description"))
        )
        db_connection.get_db().commit()
        plan_id = db.lastrowid
        db.close()
        return jsonify({"message": "Plan created and assigned successfully", "plan_id": plan_id}), 201
    
    return jsonify({"error": error}), 400


@plans.route("/<int:plan_id>/exercises", methods=["GET"])
def get_plan_exercises(plan_id):
    db = get_db()
    db.execute(
        "SELECT pe.*, e.Exercise_Name, e.Video_URL FROM Plan_Exercises pe JOIN Exercises e ON pe.Exercise_ID = e.Exercise_ID WHERE pe.Plan_ID = %s",
        (plan_id,)
    )
    exercises = db.fetchall()
    db.close()
    
    return jsonify(exercises), 200


@plans.route("/<int:plan_id>/exercises", methods=["PUT"])
def update_plan_exercises(plan_id):
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "exercise_id" not in data:
        error = "exercise_id is required"
    elif "sets" not in data:
        error = "sets is required"
    elif "reps" not in data:
        error = "reps is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "UPDATE Plan_Exercises SET Sets = %s, Reps = %s WHERE Plan_ID = %s AND Exercise_ID = %s",
            (data["sets"], data["reps"], plan_id, data["exercise_id"])
        )
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Exercise sets/reps updated successfully"}), 200
    
    return jsonify({"error": error}), 400


@plans.route("/exercises", methods=["GET"])
def get_exercises():
    db = get_db()
    db.execute("SELECT * FROM Exercises")
    exercises = db.fetchall()
    db.close()
    
    return jsonify(exercises), 200


@plans.route("/exercises", methods=["POST"])
def create_exercise():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "Exercise_Name" not in data:
        error = "Exercise_Name is required"
    elif "Video_URL" not in data:
        error = "Video_URL is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "INSERT INTO Exercises (Exercise_Name, Video_URL, Description, Muscle_Group) VALUES (%s, %s, %s, %s)",
            (data["Exercise_Name"], data["Video_URL"], data.get("Description"), data.get("Muscle_Group"))
        )
        db_connection.get_db().commit()
        exercise_id = db.lastrowid
        db.close()
        return jsonify({"message": "Exercise created successfully", "exercise_id": exercise_id}), 201
    
    return jsonify({"error": error}), 400

