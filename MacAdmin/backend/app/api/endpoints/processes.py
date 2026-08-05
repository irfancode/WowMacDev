from fastapi import APIRouter, Depends
import psutil

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/")
async def get_processes(current_user: dict = Depends(get_current_user)):
    """Get all processes"""
    processes = []
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'status', 'create_time']):
        try:
            pinfo = proc.info
            processes.append(pinfo)
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return processes

@router.post("/{pid}/kill")
async def kill_process(pid: int, current_user: dict = Depends(get_current_user)):
    """Kill a process by PID"""
    try:
        proc = psutil.Process(pid)
        proc.terminate()
        return {"message": f"Process {pid} terminated"}
    except psutil.NoSuchProcess:
        return {"error": "Process not found"}
    except Exception as e:
        return {"error": str(e)}
