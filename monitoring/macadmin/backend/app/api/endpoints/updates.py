from fastapi import APIRouter, Depends
import subprocess

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/")
async def check_updates(current_user: dict = Depends(get_current_user)):
    """Check for macOS software updates"""
    try:
        result = subprocess.run(['softwareupdate', '-l'], capture_output=True, text=True)
        
        # Parse the output
        updates = []
        lines = result.stdout.split('\n')
        
        for line in lines:
            if 'Label:' in line:
                # Extract update name
                update_name = line.replace('Label:', '').strip()
                updates.append({"name": update_name, "size": "Unknown"})
        
        return {
            "available": len(updates) > 0,
            "updates": updates,
            "raw_output": result.stdout
        }
    except Exception as e:
        return {"error": str(e), "available": False}
