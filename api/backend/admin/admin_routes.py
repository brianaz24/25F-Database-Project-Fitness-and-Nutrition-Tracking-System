from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection

def get_db():
    return db_connection.get_db().cursor()

admin = Blueprint("admin", __name__)


@admin.route("/users", methods=["GET"])
def get_users():
    db = get_db()
    db.execute("SELECT u.*, r.Role_Name FROM Users u LEFT JOIN User_Roles r ON u.User_ID = r.User_ID")
    users = db.fetchall()
    db.close()
    
    return jsonify(users), 200


@admin.route("/users", methods=["PUT"])
def update_user_role():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "user_id" not in data:
        error = "user_id is required"
    elif "role_id" not in data:
        error = "role_id is required"
    
    if error is None:
        db = get_db()
        db.execute(
            "UPDATE User_Roles SET Role_ID = %s WHERE User_ID = %s",
            (data["role_id"], data["user_id"])
        )
        if db.rowcount == 0:
            db.execute(
                "INSERT INTO User_Roles (User_ID, Role_ID) VALUES (%s, %s)",
                (data["user_id"], data["role_id"])
            )
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "User role updated successfully"}), 200
    
    return jsonify({"error": error}), 400


@admin.route("/users", methods=["DELETE"])
def delete_user():
    data = request.get_json()
    error = None
    
    if not data:
        error = "Request body is required"
    elif "user_id" not in data:
        error = "user_id is required"
    
    if error is None:
        db = get_db()
        db.execute("UPDATE Users SET Is_Active = 0 WHERE User_ID = %s", (data["user_id"],))
        db_connection.get_db().commit()
        db.close()
        return jsonify({"message": "User deactivated successfully"}), 200
    
    return jsonify({"error": error}), 400


@admin.route("/audit", methods=["GET"])
def get_audit_log():
    user_id = request.args.get("user_id")
    start_date = request.args.get("start_date")
    end_date = request.args.get("end_date")
    
    query = "SELECT * FROM Audit_Log WHERE 1=1"
    params = []
    
    if user_id:
        query += " AND User_ID = %s"
        params.append(user_id)
    if start_date:
        query += " AND Change_Date >= %s"
        params.append(start_date)
    if end_date:
        query += " AND Change_Date <= %s"
        params.append(end_date)
    
    query += " ORDER BY Change_Date DESC"
    
    db = get_db()
    db.execute(query, tuple(params))
    audit_log = db.fetchall()
    db.close()
    
    return jsonify(audit_log), 200


@admin.route("/alerts", methods=["GET"])
def get_alerts():
    db = get_db()
    db.execute("SELECT * FROM System_Alerts WHERE Alert_Type = 'error' ORDER BY Alert_Date DESC")
    alerts = db.fetchall()
    db.close()
    
    return jsonify(alerts), 200


@admin.route("/backups", methods=["POST"])
def trigger_backup():
    db = get_db()
    db.execute("INSERT INTO Backup_Log (Backup_Date, Status) VALUES (NOW(), 'initiated')")
    db_connection.get_db().commit()
    backup_id = db.lastrowid
    db.close()
    
    return jsonify({"message": "Backup initiated successfully", "backup_id": backup_id}), 201


@admin.route("/system/metrics", methods=["GET"])
def get_system_metrics():
    db = get_db()
    db.execute("SELECT * FROM System_Metrics ORDER BY Metric_Date DESC LIMIT 100")
    metrics = db.fetchall()
    db.close()
    
    return jsonify(metrics), 200

