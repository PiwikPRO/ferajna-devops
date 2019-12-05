from flask import Flask
from random import randint
from flask import jsonify

from uuid import uuid4

app = Flask(__name__)

@app.route("/foo")
@app.route("/bar")
def rand_response_two():
    if randint(0, 10) < 7:
        raise RuntimeError()
    return jsonify({'token': uuid4().hex})

if __name__ == "__main__":
    app.run()
