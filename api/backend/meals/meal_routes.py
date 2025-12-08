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

meals = Blueprint("meals", __name__)


@meals.route("/<int:meal_id>", methods=["GET"])
def get_meal(meal_id):
    db = get_db()
    db.execute("SELECT * FROM Meals WHERE Meal_ID = %s", (meal_id,))
    meal = db.fetchone()
    db.close()
    
    error = None
    if meal is None:
        error = "Meal not found"
    
    if error is None:
        serialized_meal = serialize_row(meal)
        return jsonify(serialized_meal), 200
    
    return jsonify({"error": error}), 404


@meals.route("", methods=["POST"])
def create_meal():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "User_ID" not in data:
        error = "User_ID is required"
    elif "Meal_Name" not in data:
        error = "Meal_Name is required"
    elif "Calories" not in data:
        error = "Calories is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "INSERT INTO Meals (User_ID, Meal_Name, Calories, Meal_Date, Meal_Time) VALUES (%s, %s, %s, %s, %s)",
            (data["User_ID"], data["Meal_Name"], data["Calories"], data.get("Meal_Date"), data.get("Meal_Time"))
        )
        db_connection.get_db().commit()
        meal_id = db.lastrowid
        db.close()
        return jsonify({"message": "Meal created successfully", "meal_id": meal_id}), 201
    
    return jsonify({"error": error}), 400


@meals.route("/<int:meal_id>", methods=["PUT"])
def update_meal(meal_id):
    data = request.get_json()
    error = None
    
    db = get_db()
    db.execute("SELECT * FROM Meals WHERE Meal_ID = %s", (meal_id,))
    meal = db.fetchone()
    
    if meal is None:
        error = "Meal not found"
    elif not data:
        error = "Request body is required"
    
    if error is None:
        update_fields = []
        params = []
        allowed_fields = ["Meal_Name", "Calories", "Meal_Date", "Meal_Time", "Notes"]
        
        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                params.append(data[field])
        
        if not update_fields:
            error = "No valid fields to update"
    
    if error is None:
        params.append(meal_id)
        db.execute(f"UPDATE Meals SET {', '.join(update_fields)} WHERE Meal_ID = %s", tuple(params))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Meal updated successfully"}), 200
    
    db.close()
    if error == "Meal not found":
        return jsonify({"error": error}), 404
    return jsonify({"error": error}), 400


@meals.route("/<int:meal_id>", methods=["DELETE"])
def delete_meal(meal_id):
    db = get_db()
    db.execute("SELECT * FROM Meals WHERE Meal_ID = %s", (meal_id,))
    meal = db.fetchone()
    
    error = None
    if meal is None:
        error = "Meal not found"
    
    if error is None:
        db.execute("DELETE FROM Meals WHERE Meal_ID = %s", (meal_id,))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "Meal deleted successfully"}), 200
    
    db.close()
    return jsonify({"error": error}), 404


@meals.route("/<int:meal_id>/comments", methods=["GET"])
def get_meal_comments(meal_id):
    db = get_db()
    db.execute("SELECT * FROM Meals WHERE Meal_ID = %s", (meal_id,))
    meal = db.fetchone()
    
    error = None
    if meal is None:
        error = "Meal not found"
    
    if error is None:
        db.execute("SELECT * FROM Meal_Comments WHERE Meal_ID = %s", (meal_id,))
        comments = db.fetchall()
        db.close()
        return jsonify(comments), 200
    
    db.close()
    return jsonify({"error": error}), 404


@meals.route("/<int:meal_id>/comments", methods=["POST"])
def create_meal_comment(meal_id):
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "Dietitian_ID" not in data:
        error = "Dietitian_ID is required"
    elif "Comment_Text" not in data:
        error = "Comment_Text is required"
    
    if error is None:
        db = get_db()
        db.execute("SELECT * FROM Meals WHERE Meal_ID = %s", (meal_id,))
        meal = db.fetchone()
        
        if meal is None:
            error = "Meal not found"
    
    if error is None:
        db.execute(
            "INSERT INTO Meal_Comments (Meal_ID, Dietitian_ID, Comment_Text, Comment_Date) VALUES (%s, %s, %s, %s)",
            (meal_id, data["Dietitian_ID"], data["Comment_Text"], data.get("Comment_Date"))
        )
        db_connection.get_db().commit()
        comment_id = db.lastrowid
        db.close()
        return jsonify({"message": "Comment added successfully", "comment_id": comment_id}), 201
    
    if error == "Meal not found":
        return jsonify({"error": error}), 404
    return jsonify({"error": error}), 400

