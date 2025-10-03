import requests
import json
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    try:
        api_path = os.environ.get('API_PATH')
        ms_path = os.environ.get('MS_PATH')

        if not api_path or not ms_path:
            logger.error("Missing required environment variables: API_PATH or MS_PATH")
            return {
                'statusCode': 500,
                'body': json.dumps({
                    'error': 'Missing required environment variables: API_PATH or MS_PATH'
                })
            }

        logger.info(f"Fetching data from API: {api_path}")
        data = requests.get(api_path, headers={"Accept": "application/json"})
        data.raise_for_status()  # Raise an exception for bad status codes

        json_data = data.json()
        logger.info(f"Successfully fetched data from API")

        logger.info(f"Posting data to microservice: {ms_path}")
        response = requests.post(
            ms_path,
            json=json_data,
            headers={
                'Content-type': 'application/json'
            }
        )
        response.raise_for_status()

        logger.info("Successfully posted data to microservice")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'The function was successfully executed',
                'api_path': api_path,
                'ms_path': ms_path
            })
        }

    except requests.exceptions.RequestException as e:
        logger.error(f"Request error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Request failed: {str(e)}'
            })
        }
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Invalid JSON response: {str(e)}'
            })
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f'Unexpected error: {str(e)}'
            })
        }
