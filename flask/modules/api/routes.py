from flask import Blueprint, jsonify, Response
from modules.database import collection as db
from bson import json_util

mod = Blueprint('api', __name__, template_folder='templates')

@mod.route('/')
def api():
    try:
        data = db.getAllImages()
        filtered_data = [
            {
                'url': item['image_url'], 
                'timestamp': item['timestamp'].isoformat() if 'timestamp' in item else None,
                'class_name': item['class_name']
            } 
            for item in data
        ]
        return Response(json_util.dumps(filtered_data), mimetype='application/json')
    except Exception as e:
        return jsonify({'error': str(e)}), 500
