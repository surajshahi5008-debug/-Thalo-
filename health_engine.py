
import time
import psutil
from fastapi import FastAPI, status
from fastapi.responses import JSONResponse

app = FastAPI(title="Thalo Health & Monitoring Engine")

def check_database_connection() -> bool:
    # वास्तविक एपमा यहाँ Database Connection जाँच हुन्छ
    return True

@app.get("/health", tags=["System Health"])
async def health_check():
    '''
    Thalo एपको हेल्थ चेक API Endpoint। 
    यसले सर्भरको CPU, RAM, र Database को जानकारी दिन्छ।
    '''
    db_status = check_database_connection()
    cpu_usage = psutil.cpu_percent(interval=0.1)
    memory_info = psutil.virtual_memory()

    is_healthy = db_status and (cpu_usage < 90.0) and (memory_info.percent < 90.0)
    system_status = "HEALTHY" if is_healthy else "DEGRADED"

    health_report = {
        "app_name": "Thalo App",
        "status": system_status,
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "components": {
            "database": "UP" if db_status else "DOWN",
            "ai_engine": "ACTIVE"
        },
        "system_metrics": {
            "cpu_usage_percent": f"{cpu_usage}%",
            "memory_usage_percent": f"{memory_info.percent}%",
            "free_memory_mb": round(memory_info.available / (1024 * 1024), 2)
        }
    }
    
    status_code = status.HTTP_200_OK if is_healthy else status.HTTP_503_SERVICE_UNAVAILABLE
    return JSONResponse(status_code=status_code, content=health_report)

@app.get("/")
def root():
    return {"message": "Welcome to Thalo App Monitoring System!"}
