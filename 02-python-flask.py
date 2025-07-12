# Python with Flask
from flask import Flask, Response
import json
import time
from datetime import datetime
import threading

app = Flask(__name__)

@app.route('/events')
def events():
    def generate():
        yield f"data: Connected to Python Flask SSE\n\n"
        
        while True:
            timestamp = datetime.now().isoformat()
            data = {
                "message": "Hello from Python Flask",
                "timestamp": timestamp
            }
            yield f"data: {json.dumps(data)}\n\n"
            time.sleep(2)
    
    return Response(
        generate(),
        mimetype='text/event-stream',
        headers={
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive',
            'Access-Control-Allow-Origin': '*'
        }
    )

if __name__ == '__main__':
    app.run(debug=True, port=3002, threaded=True)