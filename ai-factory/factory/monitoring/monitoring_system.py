# factory/monitoring/monitoring_system.py
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta
import asyncio
import logging
import json

logger = logging.getLogger(__name__)

@dataclass
class MetricPoint:
    name: str
    value: float
    timestamp: datetime
    tags: Dict[str, str]

class MonitoringSystem:
    def __init__(self):
        self.metrics: List[MetricPoint] = []
        self.alerts: List[Dict[str, Any]] = []
        self.running = False
    
    async def start(self):
        self.running = True
        logger.info("Monitoring system started")
        
        while self.running:
            await self._collect_metrics()
            await self._check_alerts()
            await asyncio.sleep(60)
    
    async def stop(self):
        self.running = False
        logger.info("Monitoring system stopped")
    
    async def _collect_metrics(self):
        # Simulated metrics (no psutil dependency)
        import random
        cpu_percent = random.randint(10, 60)
        memory_percent = random.randint(20, 70)
        disk_percent = random.randint(30, 80)
        
        self.metrics.append(MetricPoint("cpu_usage", cpu_percent, datetime.now(), {"type": "system"}))
        self.metrics.append(MetricPoint("memory_usage", memory_percent, datetime.now(), {"type": "system"}))
        self.metrics.append(MetricPoint("disk_usage", disk_percent, datetime.now(), {"type": "system"}))
        self.metrics.append(MetricPoint("api_requests", random.randint(100, 300), datetime.now(), {"type": "api"}))
        self.metrics.append(MetricPoint("avg_response_time", random.randint(50, 200), datetime.now(), {"type": "api"}))
        
        logger.debug(f"Metrics collected - CPU: {cpu_percent}%, Memory: {memory_percent}%")
    
    async def _check_alerts(self):
        cutoff = datetime.now() - timedelta(minutes=5)
        recent_metrics = [m for m in self.metrics if m.timestamp > cutoff]
        
        for metric in recent_metrics:
            if metric.name == "cpu_usage" and metric.value > 80:
                self.alerts.append({"type": "high_cpu", "value": metric.value, "threshold": 80, "timestamp": metric.timestamp.isoformat()})
            elif metric.name == "memory_usage" and metric.value > 90:
                self.alerts.append({"type": "high_memory", "value": metric.value, "threshold": 90, "timestamp": metric.timestamp.isoformat()})
    
    def get_metrics(self, metric_name: Optional[str] = None, last_minutes: int = 60) -> List[Dict[str, Any]]:
        cutoff = datetime.now() - timedelta(minutes=last_minutes)
        filtered = [m for m in self.metrics if m.timestamp > cutoff]
        
        if metric_name:
            filtered = [m for m in filtered if m.name == metric_name]
        
        return [{"name": m.name, "value": m.value, "timestamp": m.timestamp.isoformat()} for m in filtered[-50:]]
    
    def get_alerts(self) -> List[Dict[str, Any]]:
        return self.alerts[-20:]
    
    def get_summary(self) -> Dict[str, Any]:
        recent_metrics = [m for m in self.metrics if m.timestamp > datetime.now() - timedelta(minutes=5)]
        
        return {
            "status": "healthy",
            "metrics_count": len(self.metrics),
            "alerts_count": len(self.alerts),
            "latest_cpu": next((m.value for m in reversed(recent_metrics) if m.name == "cpu_usage"), 0),
            "latest_memory": next((m.value for m in reversed(recent_metrics) if m.name == "memory_usage"), 0),
            "timestamp": datetime.now().isoformat()
        }