import os
import shutil
import torch
import logging
from flask import Flask, Blueprint, request, render_template, jsonify, url_for
from werkzeug.utils import secure_filename
from modules.database.collection import addNewImage

logging.basicConfig(level=logging.INFO)

mod = Blueprint('backend', __name__, template_folder='templates', static_folder='./static')
model = torch.hub.load('ultralytics/yolov5', 'custom', path='./models/identification.pt', trust_repo=True)

ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@mod.route('/')
def home():
    return render_template('index.html')

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, 'modules', 'static')

@mod.route('/upload', methods=['POST'])
def upload():
    file = request.files['file']
    if file:
        filename = secure_filename(file.filename)
        upload_dir = os.path.join(os.getcwd(), 'modules/static', 'upload')
        os.makedirs(upload_dir, exist_ok=True)
        filepath = os.path.join(upload_dir, filename)
        file.save(filepath)
        file_url = url_for('backend.static', filename=f'upload/{filename}', _external=True)
        return jsonify({'uploaded_url': file_url})
    return jsonify({'error': 'No file provided'}), 400

@mod.route('/predict', methods=['POST'])
def predict():
    image_url = request.form.get('image_url')
    if not image_url:
        return jsonify({"error": "No image URL provided"}), 400

    exp_dir = 'runs/detect/exp'
    
    if(os.path.exists(exp_dir)):
        shutil.rmtree(exp_dir)

    filename = image_url.split('/')[-1] 
    local_image_path = os.path.join(os.getcwd(), 'modules/static', 'upload', filename)
    
    if not os.path.isfile(local_image_path):
        return jsonify({"error": "Image file not found on server"}), 404

    results = model(local_image_path)
    results.save()

    processed_dir = os.path.join(os.getcwd(), 'modules/static', 'processed')
    os.makedirs(processed_dir, exist_ok=True)

    for file in os.listdir('runs/detect/exp'):
        if file.endswith('.jpg'):
            shutil.move(os.path.join('runs/detect/exp', file), os.path.join(processed_dir, file))
            processed_image_url = url_for('backend.static', filename=f'processed/{file}', _external=True)
            
            if len(results.pred[0]) > 0:
                    first_detection = results.pred[0][0]
                    class_id = int(first_detection[5])
                    class_name = results.names[class_id]

                    save_success = addNewImage(processed_image_url, class_name)
                    
                    if save_success:
                        return jsonify(success=True, image_url=processed_image_url, class_name=class_name)
                    else:
                        return jsonify(success=False, message="Failed to save the prediction result")

            return jsonify(success=True, image_url=processed_image_url)

    return jsonify(success=False, message="Processed file could not be found")
