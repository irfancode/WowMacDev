from fastapi import APIRouter, Depends
import psutil
import shutil

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/")
async def get_storage_info(current_user: dict = Depends(get_current_user)):
    """Get storage information"""
    disk = psutil.disk_usage('/')
    
    return {
        "total": disk.total,
        "used": disk.used,
        "free": disk.free,
        "percent": disk.percent,
    }

@router.get("/disk")
async def get_disk_partitions(current_user: dict = Depends(get_current_user)):
    """Get disk partitions"""
    partitions = psutil.disk_partitions()
    result = []
    
    for partition in partitions:
        try:
            usage = psutil.disk_usage(partition.mountpoint)
            result.append({
                "device": partition.device,
                "mountpoint": partition.mountpoint,
                "fstype": partition.fstype,
                "total": usage.total,
                "used": usage.used,
                "free": usage.free,
                "percent": usage.percent,
            })
        except PermissionError:
            continue
    
    return result
