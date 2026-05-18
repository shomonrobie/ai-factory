# factory/cicd/batch_scheduler.py
from typing import Dict, Any, List, Optional
from dataclasses import dataclass
from datetime import datetime, timedelta
import asyncio
import logging
import json
import uuid

logger = logging.getLogger(__name__)

@dataclass
class ScheduledBatch:
    batch_id: str
    batch_number: int
    prompt: str
    scheduled_time: datetime
    status: str
    result: Optional[Dict[str, Any]]

class BatchScheduler:
    def __init__(self):
        self.scheduled_batches: List[ScheduledBatch] = []
        self.running = False
        self.check_interval_seconds = 30
    
    async def start(self):
        self.running = True
        logger.info("Batch scheduler started")
        
        while self.running:
            await self._process_due_batches()
            await asyncio.sleep(self.check_interval_seconds)
    
    async def stop(self):
        self.running = False
        logger.info("Batch scheduler stopped")
    
    def schedule_batch(self, batch_number: int, prompt: str, delay_seconds: int = 0) -> str:
        batch_id = str(uuid.uuid4())
        scheduled_time = datetime.now() + timedelta(seconds=delay_seconds)
        
        batch = ScheduledBatch(
            batch_id=batch_id,
            batch_number=batch_number,
            prompt=prompt,
            scheduled_time=scheduled_time,
            status="scheduled",
            result=None
        )
        
        self.scheduled_batches.append(batch)
        logger.info(f"Scheduled batch {batch_number} at {scheduled_time}")
        return batch_id
    
    async def _process_due_batches(self):
        now = datetime.now()
        due_batches = [b for b in self.scheduled_batches if b.scheduled_time <= now and b.status == "scheduled"]
        
        for batch in due_batches:
            batch.status = "processing"
            logger.info(f"Processing scheduled batch {batch.batch_number}")
            
            try:
                import requests
                response = requests.post(
                    "http://localhost:4001/api/v1/batches/",
                    json={"batch_number": batch.batch_number, "prompt": batch.prompt}
                )
                batch.result = response.json() if response.status_code == 200 else {"error": "Failed"}
                batch.status = "completed" if response.status_code == 200 else "failed"
            except Exception as e:
                batch.status = "failed"
                batch.result = {"error": str(e)}
    
    def get_scheduled_batches(self) -> List[Dict[str, Any]]:
        return [
            {
                "batch_id": b.batch_id,
                "batch_number": b.batch_number,
                "scheduled_time": b.scheduled_time.isoformat(),
                "status": b.status
            }
            for b in self.scheduled_batches
        ]
