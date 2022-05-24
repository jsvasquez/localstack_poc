import redis
import os
import logging

# Setting up root logger
LOG_LEVEL = logging.DEBUG if os.environ.get("DEBUG") == "1" else logging.INFO
if len(logging.getLogger().handlers) > 0:
    # The Lambda environment pre-configures a handler logging to stderr.
    # If a handler is already configured, `.basicConfig` does not execute.
    # Thus we set the level directly.
    logging.getLogger().setLevel(LOG_LEVEL)
else:
    logging.basicConfig(
        format="%(asctime)s/%(name)s/%(levelname)s:%(message)s",
        datefmt="%H:%M:%S",
        level=LOG_LEVEL,
    )

logger = logging.getLogger(__name__)

def send_objects_to_redis(object_keys: list) -> bool:
    redis_endpoint = os.environ["REDIS_ENDPOINT"]
    redis_port     = os.environ["REDIS_PORT"]

    logger.info("Starting push to Redis")
    logger.debug("Will push both object keys and object names.")

    object_names = list(map(lambda s3_key: s3_key.split('/')[-1], object_keys))

    redis_client = redis.Redis(
        host=redis_endpoint,
        port=redis_port,
        decode_responses=True
    )

    keys_response = redis_client.rpush("object_keys", *object_keys)
    names_response = redis_client.rpush("object_names", *object_names)

    logger.debug(f"{keys_response=}")
    logger.debug(f"{names_response=}")

    logger.info("Records successfully pushed to Redis")
    return True


def lambda_handler(event, context):
    logger.debug(event)
    object_keys = list(map(lambda record: record["s3"]["object"]["key"], event.get("Records", [])))

    send_objects_to_redis(object_keys)

if __name__ == "__main__":
    event = {
        'Records': [
            {
            'eventVersion': '2.1',
            'eventSource': 'aws:s3',
            'awsRegion': 'us-east-1',
            'eventTime': '2022-05-21T01:42:34.907Z',
            'eventName': 'ObjectCreated:Put',
            'userIdentity': {
                'principalId': 'AIDAJDPLRKLG7UEXAMPLE'
            },
            'requestParameters': {
                'sourceIPAddress': '127.0.0.1'
            },
            'responseElements': {
                'x-amz-request-id': '3c2e5a4f',
                'x-amz-id-2': 'eftixk72aD6Ap51TnqcoF8eFidJG9Z/2'
            },
            's3': {
                's3SchemaVersion': '1.0',
                'configurationId': 'testConfigRule',
                'bucket': {
                'name': 'a_bucket',
                'ownerIdentity': {
                    'principalId': 'A3NL1KOZZKExample'
                },
                'arn': 'arn:aws:s3:::a_bucket'
                },
                'object': {
                'key': 'hey/.gitignore4',
                'size': 722,
                'eTag': '\"02994cd7270d5507b752a50f0aef7767\"',
                'versionId': None,
                'sequencer': '0055AED6DCD90281E5'
                }
            }
            }
        ]
    }
    lambda_handler(event, None)
