#!/usr/bin/env python3
"""
Lumyra Universal Medical Vision Model Runner
Executes registered clinical ML models dynamically based on registry configuration.
Zero heuristics. Zero mock data. Pure tensor inference.
"""

import sys
import os
import time
import json
import argparse
import numpy as np
from PIL import Image

try:
    from ai_edge_litert.interpreter import Interpreter
except ImportError:
    try:
        from tensorflow.lite.python.interpreter import Interpreter
    except ImportError:
        try:
            import tflite_runtime.interpreter as tflite
            Interpreter = tflite.Interpreter
        except ImportError:
            Interpreter = None

def load_registry(registry_path):
    if not os.path.exists(registry_path):
        raise FileNotFoundError(f"Model registry not found at: {registry_path}")
    with open(registry_path, "r", encoding="utf-8") as f:
        return json.load(f)

def run_inference(image_path, model_id=None, registry_path=None, project_root=None):
    start_time = time.time()
    
    if project_root is None:
        # Default to repo root (two levels up from backend/ml)
        project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

    if registry_path is None:
        registry_path = os.path.join(os.path.dirname(__file__), "models_registry.json")

    registry = load_registry(registry_path)

    if model_id is None:
        model_id = registry.get("defaultModelId", "breast_ultrasound_efficientnet_b0")

    models_dict = registry.get("models", {})
    if model_id not in models_dict:
        raise ValueError(f"Model ID '{model_id}' is not registered in models_registry.json. Available: {list(models_dict.keys())}")

    model_cfg = models_dict[model_id]

    # Resolve paths relative to project root if not absolute
    weights_path = model_cfg["weightsPath"]
    if not os.path.isabs(weights_path):
        weights_path = os.path.join(project_root, weights_path)

    labels_path = model_cfg["labelsPath"]
    if not os.path.isabs(labels_path):
        labels_path = os.path.join(project_root, labels_path)

    if not os.path.exists(weights_path):
        raise FileNotFoundError(f"Model weights file not found: {weights_path}")

    if not os.path.exists(labels_path):
        raise FileNotFoundError(f"Labels file not found: {labels_path}")

    # Load labels dynamically from file
    with open(labels_path, "r", encoding="utf-8") as lf:
        labels = [line.strip() for line in lf if line.strip()]

    if not labels:
        raise ValueError(f"Labels file at {labels_path} is empty.")

    if Interpreter is None:
        raise RuntimeError("No supported TensorFlow Lite / LiteRT interpreter found in Python environment.")

    # 1. Initialize Interpreter
    interp = Interpreter(model_path=weights_path)
    interp.allocate_tensors()
    input_details = interp.get_input_details()[0]
    output_details = interp.get_output_details()[0]

    # Validate output tensor dimension against labels count
    expected_classes_count = output_details["shape"][-1]
    if len(labels) != expected_classes_count:
        raise ValueError(
            f"Labels count ({len(labels)}) does not match model output tensor dimension ({expected_classes_count})!"
        )

    # 2. Preprocess Image according to model configuration
    input_cfg = model_cfg.get("input", {})
    color_mode = input_cfg.get("colorMode", "RGB")
    target_size = tuple(input_cfg.get("targetSize", [224, 224]))
    resampling_str = input_cfg.get("resampling", "bilinear").lower()
    resample_method = Image.Resampling.BICUBIC if resampling_str == "bicubic" else Image.Resampling.BILINEAR

    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Target scan image not found: {image_path}")

    try:
        raw_img = Image.open(image_path)
        img = raw_img.convert(color_mode)
    except Exception as img_err:
        raise ValueError(f"Failed to open or decode image: {img_err}")

    # Resize
    img_resized = img.resize(target_size, resample_method)

    # Convert to float32
    arr = np.array(img_resized, dtype=np.float32)

    # Pixel range scaling
    pixel_range = input_cfg.get("pixelRange", [0.0, 255.0])
    if pixel_range == [0.0, 1.0]:
        arr = arr / 255.0
    elif pixel_range == [-1.0, 1.0]:
        arr = (arr / 127.5) - 1.0
    # If [0.0, 255.0], keep as is (since model has internal rescaling)

    # Add batch dimension
    tensor_input = np.expand_dims(arr, axis=0)

    # 3. Execute Model Inference
    interp.set_tensor(input_details["index"], tensor_input)
    interp.invoke()
    raw_output = interp.get_tensor(output_details["index"])[0]

    # 4. Extract Probabilities and Class Predictions
    output_cfg = model_cfg.get("output", {})
    if output_cfg.get("isProbabilities", True):
        probs = raw_output
    else:
        exp_p = np.exp(raw_output - np.max(raw_output))
        probs = exp_p / np.sum(exp_p)

    top_idx = int(np.argmax(probs))
    predicted_class = labels[top_idx]
    confidence_pct = float(probs[top_idx] * 100.0)

    # Format probability dictionary
    probabilities_map = {}
    for i, label_name in enumerate(labels):
        probabilities_map[label_name] = round(float(probs[i]), 5)

    duration_ms = (time.time() - start_time) * 1000.0

    return {
        "success": True,
        "modelId": model_id,
        "modelName": model_cfg.get("name", model_id),
        "modality": model_cfg.get("modality", "ULTRASOUND"),
        "predictedClass": predicted_class,
        "confidence": round(confidence_pct, 2),
        "probabilities": probabilities_map,
        "classes": labels,
        "executionDurationMs": round(duration_ms, 2),
        "modelArchitecture": "EfficientNetB0",
        "inputResolution": f"{target_size[0]}x{target_size[1]}"
    }

def main():
    parser = argparse.ArgumentParser(description="Lumyra Clinical Model Runner")
    parser.add_argument("--image", required=True, help="Path to input scan image")
    parser.add_argument("--model-id", default=None, help="Registered model identifier")
    parser.add_argument("--registry", default=None, help="Path to models_registry.json")
    parser.add_argument("--root", default=None, help="Project root directory")

    args = parser.parse_args()

    try:
        result = run_inference(
            image_path=args.image,
            model_id=args.model_id,
            registry_path=args.registry,
            project_root=args.root
        )
        print(json.dumps(result, ensure_ascii=False))
        sys.exit(0)
    except Exception as e:
        error_payload = {
            "success": False,
            "errorCode": "MODEL_INFERENCE_ERROR",
            "errorMessage": str(e)
        }
        print(json.dumps(error_payload, ensure_ascii=False), file=sys.stderr)
        print(json.dumps(error_payload, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()
