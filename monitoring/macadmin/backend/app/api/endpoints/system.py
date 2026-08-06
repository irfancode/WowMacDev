from fastapi import APIRouter, Depends
import psutil
import platform
import subprocess
from datetime import datetime

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/metrics")
async def get_system_metrics(current_user: dict = Depends(get_current_user)):
    """Get real-time system metrics for macOS"""
    
    # CPU information
    cpu_percent = psutil.cpu_percent(interval=1)
    cpu_count = psutil.cpu_count()
    
    # Memory information
    memory = psutil.virtual_memory()
    
    # Disk information
    disk = psutil.disk_usage('/')
    
    # Network information
    network = psutil.net_io_counters()
    
    # Boot time
    boot_time = datetime.fromtimestamp(psutil.boot_time())
    uptime = datetime.now() - boot_time
    
    return {
        "cpu": {
            "percent": cpu_percent,
            "count": cpu_count,
            "count_logical": psutil.cpu_count(logical=True),
        },
        "memory": {
            "total": memory.total,
            "available": memory.available,
            "percent": memory.percent,
            "used": memory.used,
            "free": memory.free,
        },
        "disk": {
            "total": disk.total,
            "used": disk.used,
            "free": disk.free,
            "percent": disk.percent,
        },
        "network": {
            "bytes_sent": network.bytes_sent,
            "bytes_recv": network.bytes_recv,
            "packets_sent": network.packets_sent,
            "packets_recv": network.packets_recv,
        },
        "boot_time": boot_time.isoformat(),
        "uptime": str(uptime).split('.')[0],
    }

@router.get("/info")
async def get_system_info(current_user: dict = Depends(get_current_user)):
    """Get macOS system information"""
    
    # Get macOS version info
    try:
        result = subprocess.run(['sw_vers'], capture_output=True, text=True)
        macos_info = result.stdout
    except:
        macos_info = "Unknown"
    
    # Get hardware info
    try:
        result = subprocess.run(['system_profiler', 'SPHardwareDataType'], capture_output=True, text=True)
        hardware_info = result.stdout
    except:
        hardware_info = "Unknown"
    
    return {
        "platform": platform.system(),
        "platform_release": platform.release(),
        "platform_version": platform.version(),
        "architecture": platform.machine(),
        "processor": platform.processor(),
        "hostname": platform.node(),
        "macos_info": macos_info,
        "hardware_info": hardware_info,
    }

@router.get("/processes")
async def get_processes(current_user: dict = Depends(get_current_user)):
    """Get top processes by CPU usage"""
    processes = []
    
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'status']):
        try:
            pinfo = proc.info
            processes.append({
                "pid": pinfo['pid'],
                "name": pinfo['name'],
                "cpu_percent": pinfo['cpu_percent'] or 0,
                "memory_percent": pinfo['memory_percent'] or 0,
                "status": pinfo['status'],
            })
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    # Sort by CPU usage
    processes.sort(key=lambda x: x['cpu_percent'], reverse=True)
    return processes[:20]
