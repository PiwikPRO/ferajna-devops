from flask import Flask, request, jsonify, Response, stream_with_context
from http import HTTPStatus
import os
import redis
import json
from pubsub import PubSubExample
import sys
import logging

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

def get_app(pubsub):
    app = Flask(__name__)

    @app.after_request
    def apply_cors(response):
        response.headers["Access-Control-Allow-Origin"] = "*"
        return response

    @app.route('/health', methods=('GET',))
    def health():
        return Response(status=HTTPStatus.OK)

    @app.route('/publish', methods=('GET',))
    def publish():
        data = {
            "message": "hello"
        }
        pubsub.publish(data)
        return "Message published"

    @app.route('/stream', methods=('GET',))
    def subscribe():
        @stream_with_context
        def generator():
            for msg in pubsub.receive_messages():
                yield str(msg) + '\n'

        return Response(generator(), 'text/event-stream')
    return app

redis_url = os.getenv('REDIS_URL', 'localhost:6379')
pubsub = PubSubExample(redis_url, 'pubsub')
app = get_app(pubsub)
