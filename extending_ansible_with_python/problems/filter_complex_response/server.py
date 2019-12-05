from flask import Flask
from random import randint
from flask import jsonify


app = Flask(__name__)

def randstate():
    return "stopped" if randint(0, 1) == 0 else "started"

@app.route('/')
def summary():
    return jsonify(
        {
            "meta": {
                "instances": [
                    {
                        "name": "piwik-data-processing-organization{i}".format(i=i),
                        "state": randstate()
                    } for i in range(3)
                ] + [
                    {
                        "name": "foo",
                        "state": randstate()
                    },
                    {
                        "name": "bar",
                        "state": randstate()
                    }
                ]
            }
        }
    )

if __name__ == "__main__":
    app.run()

