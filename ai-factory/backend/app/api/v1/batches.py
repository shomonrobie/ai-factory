# backend/app/api/v1/batches.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from datetime import datetime
import json
import os

router = APIRouter()

DATA_FILE = "/app/data/batches.json"
os.makedirs("/app/data", exist_ok=True)

def load_batches():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as f:
            return json.load(f)
    return []

def save_batches(batches):
    with open(DATA_FILE, 'w') as f:
        json.dump(batches, f, indent=2)

class BatchCreate(BaseModel):
    batch_number: int
    prompt: str
    metadata: Optional[Dict] = {}

@router.post("/")
async def create_batch(batch: BatchCreate):
    batches = load_batches()
    
    for existing in batches:
        if existing.get("batch_number") == batch.batch_number:
            raise HTTPException(status_code=400, detail=f"Batch #{batch.batch_number} already exists")
    
    new_batch = {
        "id": len(batches) + 1,
        "batch_number": batch.batch_number,
        "prompt": batch.prompt,
        "status": "completed",
        "created_at": datetime.now().isoformat(),
        "metadata": batch.metadata
    }
    
    batches.append(new_batch)
    save_batches(batches)
    return new_batch

@router.get("/")
async def list_batches():
    return load_batches()

@router.get("/{batch_id}")
async def get_batch(batch_id: int):
    batches = load_batches()
    for batch in batches:
        if batch.get("id") == batch_id:
            return batch
    raise HTTPException(status_code=404, detail="Batch not found")