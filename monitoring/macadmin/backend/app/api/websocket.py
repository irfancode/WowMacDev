from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import asyncio
import json
import psutil

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            await connection.send_text(message)

manager = ConnectionManager()

@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            # Get system metrics
            cpu = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory().percent
            disk = psutil.disk_usage('/').percent
            
            data = {
                "type": "metrics",
                "timestamp": asyncio.get_event_loop().time(),
                "data": {
                    "cpu": cpu,
                    "memory": memory,
                    "disk": disk,
                }
            }
            
            await websocket.send_text(json.dumps(data))
            await asyncio.sleep(5)
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        print(f"WebSocket error: {e}")
        manager.disconnect(websocket)
