from flask import Blueprint, jsonify, request
from backend.db_connection import db as db_connection

coach_bp = Blueprint("coach", __name__, url_prefix="/coaches")


@coach_bp.route("/", methods=["GET"])
def get_all_coaches():
    query = """
        SELECT coach_id, user_id, specialization, terminator
        FROM Coaches
    """
    result = db_connection.execute_query(query)
    return jsonify(result), 200


@coach_bp.route("/<int:coach_id>", methods=["GET"])
def get_coach_by_id(coach_id):
    query = """
        SELECT coach_id, user_id, specialization, terminator
        FROM Coaches
        WHERE coach_id = %s
    """
    result = db_connection.execute_query(query, (coach_id,))
    if not result:
        return jsonify({"error": "Coach not found"}), 404
    return jsonify(result[0]), 200


@coach_bp.route("/", methods=["POST"])
def create_coach():
    data = request.get_json()
    user_id = data.get("user_id")
    specialization = data.get("specialization")
    terminator = data.get("terminator")

    if user_id is None:
        return jsonify({"error": "user_id is required"}), 400

    query = """
        INSERT INTO Coaches (user_id, specialization, terminator)
        VALUES (%s, %s, %s)
    """
    new_id = db_connection.insert_query(
        query, (user_id, specialization, terminator)
    )

    return jsonify({
        "coach_id": new_id,
        "user_id": user_id,
        "specialization": specialization,
        "terminator": terminator
    }), 201


@coach_bp.route("/<int:coach_id>", methods=["PUT"])
def update_coach(coach_id):
    data = request.get_json()
    user_id = data.get("user_id")
    specialization = data.get("specialization")
    terminator = data.get("terminator")

    if user_id is None:
        return jsonify({"error": "user_id is required"}), 400

    existing = db_connection.execute_query(
        "SELECT coach_id FROM Coaches WHERE coach_id = %s",
        (coach_id,)
    )
    if not existing:
        return jsonify({"error": "Coach not found"}), 404

    query = """
        UPDATE Coaches
        SET user_id = %s,
            specialization = %s,
            terminator = %s
        WHERE coach_id = %s
    """
    db_connection.execute_query(
        query, (user_id, specialization, terminator, coach_id),
        commit=True
    )

    return jsonify({
        "coach_id": coach_id,
        "user_id": user_id,
        "specialization": specialization,
        "terminator": terminator
    }), 200


@coach_bp.route("/<int:coach_id>", methods=["PATCH"])
def patch_coach(coach_id):
    data = request.get_json()

    existing = db_connection.execute_query(
        "SELECT * FROM Coaches WHERE coach_id = %s",
        (coach_id,)
    )
    if not existing:
        return jsonify({"error": "Coach not found"}), 404

    existing = existing[0]

    user_id = data.get("user_id", existing["user_id"])
    specialization = data.get("specialization", existing["specialization"])
    terminator = data.get("terminator", existing["terminator"])

    query = """
        UPDATE Coaches
        SET user_id = %s,
            specialization = %s,
            terminator = %s
        WHERE coach_id = %s
    """
    db_connection.execute_query(
        query, (user_id, specialization, terminator, coach_id),
        commit=True
    )

    return jsonify({
        "coach_id": coach_id,
        "user_id": user_id,
        "specialization": specialization,
        "terminator": terminator
    }), 200


@coach_bp.route("/<int:coach_id>", methods=["DELETE"])
def delete_coach(coach_id):
    existing = db_connection.execute_query(
        "SELECT coach_id FROM Coaches WHERE coach_id = %s",
        (coach_id,)
    )
    if not existing:
        return jsonify({"error": "Coach not found"}), 404

    db_connection.execute_query(
        "DELETE FROM Coaches WHERE coach_id = %s",
        (coach_id,),
        commit=True
    )

    return jsonify({"message": "Coach deleted"}), 200
