# Python with FastAPI
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import json
import asyncio
from datetime import datetime

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/events")
async def stream_events():
    async def generate():
        yield f"data: Connected to Python FastAPI SSE\n\n"
        
        while True:
            timestamp = datetime.now().isoformat()
            data = {
                "message": "Hello from Python FastAPI",
                "timestamp": timestamp
            }
            yield f"data: {json.dumps(data)}\n\n"
            await asyncio.sleep(2)
    
    return StreamingResponse(
        generate(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive"
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=3003)