from fastapi import APIRouter, Depends
import subprocess

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/")
async def get_logs(
    limit: int = 100,
    current_user: dict = Depends(get_current_user)
):
    """Get system logs using log command"""
    try:
        result = subprocess.run(
            ['log', 'show', '--last', '1h', '--style', 'compact'],
            capture_output=True,
            text=True
        )
        
        lines = result.stdout.strip().split('\n')[-limit:]
        
        logs = []
        for line in lines:
            if line.strip():
                logs.append({"message": line})
        
        return logs
    except Exception as e:
        return {"error": str(e)}
