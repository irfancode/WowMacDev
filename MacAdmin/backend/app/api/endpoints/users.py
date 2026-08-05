from fastapi import APIRouter, Depends
import subprocess

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/")
async def get_users(current_user: dict = Depends(get_current_user)):
    """Get system users"""
    try:
        # Get users from dscl
        result = subprocess.run(['dscl', '.', 'list', '/Users'], capture_output=True, text=True)
        users = result.stdout.strip().split('\n')
        
        # Filter out system users
        system_users = ['root', 'daemon', 'nobody']
        users = [u for u in users if u and u not in system_users and not u.startswith('_')]
        
        return [{"username": u} for u in users]
    except Exception as e:
        return {"error": str(e)}
