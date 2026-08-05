from fastapi import APIRouter

from app.api.endpoints import auth, system, processes, storage, network, users, updates, logs, brew

api_router = APIRouter()

# Auth routes
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])

# System routes
api_router.include_router(system.router, prefix="/system", tags=["system"])
api_router.include_router(processes.router, prefix="/processes", tags=["processes"])
api_router.include_router(storage.router, prefix="/storage", tags=["storage"])
api_router.include_router(network.router, prefix="/network", tags=["network"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(updates.router, prefix="/updates", tags=["updates"])
api_router.include_router(logs.router, prefix="/logs", tags=["logs"])

# Homebrew routes
api_router.include_router(brew.router, prefix="/brew", tags=["homebrew"])
