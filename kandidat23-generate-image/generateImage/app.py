import base64
import boto3
import json
import random
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# import requests

BUCKET_NAME = os.getenv('BUCKET_NAME')
#BUCKET_NAME = "pgr301-couch-explorers"
kandidat = 23

bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

model_id = "amazon.titan-image-generator-v1"

def lambda_handler(event, context):
    # Frank; Important; Change this prompt to something else before the presentation with the investors!
    prompt = "Sunset safari"
    
    seed = random.randint(0, 2147483647)
    s3_image_path = f"{kandidat}/titan_{seed}.png"
    
    try:
        native_request = {
            "taskType": "TEXT_IMAGE",
            "textToImageParams": {"text": prompt},
            "imageGenerationConfig": {
                "numberOfImages": 1,
                "quality": "standard",
                "cfgScale": 8.0,
                "height": 1024,
                "width": 1024,
                "seed": seed,
            }
        }
        
        response = bedrock_client.invoke_model(modelId=model_id, body=json.dumps(native_request))
        model_response = json.loads(response["body"].read())
        
        # Extract and decode the Base64 image data
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)
        
        # Upload the decoded image data to S3
        s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Generated image, leggo",
            }),
        }
    except Exception as e:
        logger.error("Error during image generation", exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Image generation failed, internal server error",
                "error": str(e)
            })
        }
