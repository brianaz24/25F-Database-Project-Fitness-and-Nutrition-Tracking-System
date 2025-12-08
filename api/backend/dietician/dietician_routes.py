from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection

dietician_bp = Blueprint("dietician", __name__, url_prefix="/dieticians")


@dietician_bp.route("/", methods=["GET"])
def get_all_dieticians():
    query = """
        SELECT dietitian_id, user_id, license_number, specialization
        FROM Dietitians
    """
    result = db_connection.execute_query(query)
    return jsonify(result), 200


@dietician_bp.route("/<int:dietitian_id>", methods=["GET"])
def get_dietician_by_id(dietitian_id):
    query = """
        SELECT dietitian_id, user_id, license_number, specialization
        FROM Dietitians
        WHERE dietitian_id = %s
    """
    result = db_connection.execute_query(query, (dietitian_id,))
    if not result:
        return jsonify({"error": "Dietician not found"}), 404
    return jsonify(result[0]), 200


@dietician_bp.route("/", methods=["POST"])
def create_dietician():
    data = request.get_json()

    user_id = data.get("user_id")
    license_number = data.get("license_number")
    specialization = data.get("specialization")

    if user_id is None:
        return jsonify({"error": "user_id is required"}), 400

    query = """
        INSERT INTO Dietitians (user_id, license_number, specialization)
        VALUES (%s, %s, %s)
    """

    new_id = db_connection.insert_query(
        query,
        (user_id, license_number, specialization)
    )

    return jsonify({
        "dietitian_id": new_id,
        "user_id": user_id,
        "license_number": license_number,
        "specialization": specialization
    }), 201


@dietician_bp.route("/<int:dietitian_id>", methods=["PUT"])
def update_dietician(dietitian_id):
    data = request.get_json()

    user_id = data.get("user_id")
    license_number = data.get("license_number")
    specialization = data.get("specialization")

    if user_id is None:
        return jsonify({"error": "user_id is required"}), 400

    existing = db_connection.execute_query(
        "SELECT dietitian_id FROM Dietitians WHERE dietitian_id = %s",
        (dietitian_id,)
    )
    if not existing:
        return jsonify({"error": "Dietician not found"}), 404

    query = """
        UPDATE Dietitians
        SET user_id = %s,
            license_number = %s,
            specialization = %s
        WHERE dietitian_id = %s
    """

    db_connection.execute_query(
        query,
        (user_id, license_number, specialization, dietitian_id),
        commit=True
    )

    return jsonify({
        "dietitian_id": dietitian_id,
        "user_id": user_id,
        "license_number": license_number,
        "specialization": specialization
    }), 200


@dietician_bp.route("/<int:dietitian_id>", methods=["PATCH"])
def patch_dietician(dietitian_id):
    data = request.get_json()

    existing = db_connection.execute_query(
        "SELECT * FROM Dietitians WHERE dietitian_id = %s",
        (dietitian_id,)
    )
    if not existing:
        return jsonify({"error": "Dietician not found"}), 404

    existing = existing[0]

    user_id = data.get("user_id", existing["user_id"])
    license_number = data.get("license_number", existing["license_number"])
    specialization = data.get("specialization", existing["specialization"])

    query = """
        UPDATE Dietitians
        SET user_id = %s,
            license_number = %s,
            specialization = %s
        WHERE dietitian_id = %s
    """

    db_connection.execute_query(
        query,
        (user_id, license_number, specialization, dietitian_id),
        commit=True
    )

    return jsonify({
        "dietitian_id": dietitian_id,
        "user_id": user_id,
        "license_number": license_number,
        "specialization": specialization
    }), 200


@dietician_bp.route("/<int:dietitian_id>", methods=["DELETE"])
def delete_dietician(dietitian_id):
    existing = db_connection.execute_query(
        "SELECT dietitian_id FROM Dietitians WHERE dietitian_id = %s",
        (dietitian_id,)
    )
    if not existing:
        return jsonify({"error": "Dietician not found"}), 404

    db_connection.execute_query(
        "DELETE FROM Dietitians WHERE dietitian_id = %s",
        (dietitian_id,),
        commit=True
    )

    return jsonify({"message": "Dietician deleted"}), 200
