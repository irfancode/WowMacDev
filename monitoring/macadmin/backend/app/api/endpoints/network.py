from fastapi import APIRouter, Depends
import psutil

from app.api.endpoints.auth import get_current_user

router = APIRouter()

@router.get("/interfaces")
async def get_network_interfaces(current_user: dict = Depends(get_current_user)):
    """Get network interfaces"""
    interfaces = []
    stats = psutil.net_io_counters(pernic=True)
    
    for name, addrs in psutil.net_if_addrs().items():
        interface_info = {
            "name": name,
            "addresses": [],
            "stats": {
                "bytes_sent": stats[name].bytes_sent if name in stats else 0,
                "bytes_recv": stats[name].bytes_recv if name in stats else 0,
            }
        }
        
        for addr in addrs:
            interface_info["addresses"].append({
                "family": addr.family.name,
                "address": addr.address,
                "netmask": addr.netmask,
            })
        
        interfaces.append(interface_info)
    
    return interfaces

@router.get("/stats")
async def get_network_stats(current_user: dict = Depends(get_current_user)):
    """Get network statistics"""
    stats = psutil.net_io_counters()
    return {
        "bytes_sent": stats.bytes_sent,
        "bytes_recv": stats.bytes_recv,
        "packets_sent": stats.packets_sent,
        "packets_recv": stats.packets_recv,
        "errin": stats.errin,
        "errout": stats.errout,
        "dropin": stats.dropin,
        "dropout": stats.dropout,
    }
