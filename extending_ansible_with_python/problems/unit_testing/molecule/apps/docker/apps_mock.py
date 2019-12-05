from flask import Flask
from flask import jsonify
from flask import request

app = Flask(__name__)


@app.route(
    '/api/apps/v2/firstWebsiteId',
    methods=('DELETE',)
)
def rm_first():
    raise RuntimeError("This website should never be deleted !!!")


@app.route(
    '/api/apps/v2/secondWebsiteId',
    methods=('DELETE',)
)
def rm_second():
    resp = jsonify(success=True)
    resp.status_code = 204
    return resp


@app.route(
    '/api/apps/v2/thirdWebsiteId',
    methods=('DELETE',)
)
def rm_third():
    resp = jsonify(success=True)
    resp.status_code = 204
    return resp


@app.route('/api/apps/v2')
def instance():
    return jsonify(
        {
            'data': [
                {
                    'id': 'firstWebsiteId',
                    'attributes': {
                        'name': 'First website'
                    }
                },
                {
                    'id': 'secondWebsiteId',
                    'attributes': {
                        'name': 'Second website'
                    }
                },
                {
                    'id': 'thirdWebsiteId',
                    'attributes': {
                        'name': 'Third website'
                    }
                }
            ]
        }
    )
