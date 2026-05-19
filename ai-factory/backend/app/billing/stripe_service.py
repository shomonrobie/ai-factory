# backend/app/billing/stripe_service.py
from typing import Dict, Any, Optional, List
from datetime import datetime
import stripe
import os
import logging

logger = logging.getLogger(__name__)

stripe.api_key = os.getenv("STRIPE_SECRET_KEY", "sk_test_placeholder")

PLANS = {
    "free": {
        "stripe_price_id": "price_free",
        "name": "Free",
        "price": 0,
        "features": ["5_batches", "single_user", "basic_templates"]
    },
    "pro": {
        "stripe_price_id": os.getenv("STRIPE_PRO_PRICE_ID", "price_pro"),
        "name": "Pro",
        "price": 4900,
        "features": ["unlimited_batches", "multi_agent", "self_improving", "team_workspaces", "priority_processing"]
    },
    "enterprise": {
        "stripe_price_id": "price_enterprise",
        "name": "Enterprise",
        "price": "custom",
        "features": ["white_label", "sso", "on_premise", "dedicated_support"]
    }
}

class StripeService:
    def __init__(self):
        self.api_key = stripe.api_key
    
    def create_checkout_session(self, customer_id: Optional[str], price_id: str, success_url: str, cancel_url: str) -> Dict[str, Any]:
        try:
            session = stripe.checkout.Session.create(
                customer=customer_id,
                payment_method_types=["card"],
                line_items=[{"price": price_id, "quantity": 1}],
                mode="subscription",
                success_url=success_url,
                cancel_url=cancel_url,
                metadata={"plan": price_id}
            )
            return {"session_id": session.id, "url": session.url}
        except Exception as e:
            logger.error(f"Stripe checkout error: {str(e)}")
            return {"error": str(e)}
    
    def create_customer(self, email: str, name: str) -> Optional[str]:
        try:
            customer = stripe.Customer.create(email=email, name=name)
            return customer.id
        except Exception as e:
            logger.error(f"Customer creation error: {str(e)}")
            return None
    
    def get_subscription(self, subscription_id: str) -> Optional[Dict[str, Any]]:
        try:
            subscription = stripe.Subscription.retrieve(subscription_id)
            return {
                "id": subscription.id,
                "status": subscription.status,
                "current_period_start": subscription.current_period_start,
                "current_period_end": subscription.current_period_end,
                "plan": subscription.items.data[0].price.id if subscription.items.data else None
            }
        except Exception as e:
            logger.error(f"Subscription retrieval error: {str(e)}")
            return None
    
    def cancel_subscription(self, subscription_id: str) -> bool:
        try:
            stripe.Subscription.delete(subscription_id)
            return True
        except Exception as e:
            logger.error(f"Subscription cancellation error: {str(e)}")
            return False
    
    def handle_webhook(self, payload: str, sig_header: str, webhook_secret: str) -> Dict[str, Any]:
        try:
            event = stripe.Webhook.construct_event(payload, sig_header, webhook_secret)
            return {"type": event["type"], "data": event["data"]["object"]}
        except Exception as e:
            logger.error(f"Webhook error: {str(e)}")
            return {"error": str(e)}
