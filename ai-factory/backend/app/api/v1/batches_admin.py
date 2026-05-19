# backend/app/api/v1/batches_admin.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, Optional
import json
import os

router = APIRouter()
BATCHES_FILE = "/app/data/batches.json"

def load_batches():
    if os.path.exists(BATCHES_FILE):
        with open(BATCHES_FILE, 'r') as f:
            return json.load(f)
    return []

def save_batches(batches):
    os.makedirs(os.path.dirname(BATCHES_FILE), exist_ok=True)
    with open(BATCHES_FILE, 'w') as f:
        json.dump(batches, f, indent=2)

class BatchUpdate(BaseModel):
    prompt: Optional[str] = None
    status: Optional[str] = None
    result: Optional[Dict] = None

@router.put("/{batch_id}")
async def update_batch(batch_id: int, update: BatchUpdate):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            if update.prompt is not None:
                batches[i]["prompt"] = update.prompt
            if update.status is not None:
                batches[i]["status"] = update.status
            if update.result is not None:
                batches[i]["result"] = update.result
            save_batches(batches)
            return batches[i]
    raise HTTPException(status_code=404, detail="Batch not found")

@router.delete("/{batch_id}")
async def delete_batch(batch_id: int):
    batches = load_batches()
    for i, batch in enumerate(batches):
        if batch.get("id") == batch_id:
            deleted = batches.pop(i)
            save_batches(batches)
            return {"message": f"Batch #{deleted.get('batch_number')} deleted"}
    raise HTTPException(status_code=404, detail="Batch not found")
