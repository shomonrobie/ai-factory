# backend/app/api/v1/billing/webhooks.py
from fastapi import APIRouter, HTTPException, Request, BackgroundTasks
from pydantic import BaseModel
from typing import Dict, Any, Optional
import os
import logging

from ...billing.stripe_service import StripeService
from ...entitlement.feature_gate import FeatureGate, Tier
from ...usage.metering import UsageMeter

router = APIRouter()

stripe_service = StripeService()
feature_gate = FeatureGate()
usage_meter = UsageMeter()

class CheckoutRequest(BaseModel):
    price_id: str
    success_url: str
    cancel_url: str

@router.post("/create-checkout")
async def create_checkout_session(request: CheckoutRequest, user_id: str = "test_user"):
    customer_id = stripe_service.create_customer("user@example.com", "Test User")
    result = stripe_service.create_checkout_session(
        customer_id=customer_id,
        price_id=request.price_id,
        success_url=request.success_url,
        cancel_url=request.cancel_url
    )
    return result

@router.post("/webhook/stripe")
async def stripe_webhook(request: Request, background_tasks: BackgroundTasks):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature", "")
    webhook_secret = os.getenv("STRIPE_WEBHOOK_SECRET", "whsec_test")
    
    result = stripe_service.handle_webhook(payload.decode(), sig_header, webhook_secret)
    
    if result.get("type") == "checkout.session.completed":
        session = result.get("data", {})
        customer_id = session.get("customer")
        background_tasks.add_task(handle_subscription_created, customer_id, session)
    
    return {"received": True}

async def handle_subscription_created(customer_id: str, session: Dict[str, Any]):
    logger.info(f"Subscription created for customer {customer_id}")
    # Update user tier based on subscription
    pass

@router.get("/plans")
async def get_plans():
    from ...billing.stripe_service import PLANS
    return {"plans": PLANS}

class EntitlementResponse(BaseModel):
    user_id: str
    tier: str
    features: Dict[str, Any]

@router.get("/entitlements/{user_id}")
async def get_user_entitlements(user_id: str) -> EntitlementResponse:
    entitlements = feature_gate.get_entitlements(user_id)
    return EntitlementResponse(
        user_id=user_id,
        tier=entitlements["tier"],
        features=entitlements["features"]
    )

@router.post("/entitlements/{user_id}/tier")
async def update_user_tier(user_id: str, tier: str):
    try:
        new_tier = Tier(tier)
        feature_gate.set_user_tier(user_id, new_tier)
        return {"status": "updated", "user_id": user_id, "tier": tier}
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid tier")

@router.get("/usage/{user_id}")
async def get_user_usage(user_id: str):
    monthly = usage_meter.get_monthly_usage(user_id)
    history = usage_meter.get_usage_history(user_id)
    return {
        "current_month": monthly,
        "history": history
    }

@router.post("/usage/{user_id}/batch")
async def record_batch_usage(user_id: str, batch_id: int):
    usage_meter.record_batch(user_id, batch_id)
    
    if not feature_gate.can_create_batch(user_id, monthly["batch_count"]):
        raise HTTPException(status_code=429, detail="Batch limit exceeded for this tier")
    
    return {"status": "recorded"}
