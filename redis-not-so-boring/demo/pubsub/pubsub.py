import redis
from redis.exceptions import ConnectionError
import json
import logging


logger = logging.getLogger(__name__)

class Message:
    def __init__(self, data, type='pubsub'):
        self.data = data
        self.type = type

    def sse_format(self):
        output = [f'event:{self.type}'] + [f'data:{line}' for line in json.dumps(self.data).splitlines()]
        return '\n'.join(output) + '\n\n'

    def to_dict(self):
        return {
            'data': self.data,
            'type': self.type
        }

class PubSubExample:
    def __init__(self, redis_url, channel_name):
        self.redis_url = redis_url
        self.channel_name = channel_name

    @property
    def redis(self):
        return redis.from_url(f'redis://{self.redis_url}')

    def publish(self, data):
        logger.info(f'Published {data}')
        message = Message(data)
        msg_json = json.dumps(message.to_dict())
        return self.redis.publish(self.channel_name, message=msg_json)

    def receive_messages(self):
        pubsub = self.redis.pubsub()
        pubsub.subscribe(self.channel_name)
        try:
            for pubsub_msg in pubsub.listen():
                logger.info(f'Received: {pubsub_msg}')
                if pubsub_msg['type'] == 'message':
                    msg_dict = json.loads(pubsub_msg['data'])
                    yield Message(**msg_dict).sse_format()
        finally:
            try:
                pubsub.unsubscribe(self.channel_name)
            except ConnectionError:
                pass