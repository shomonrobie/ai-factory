# backend/app/entitlement/feature_gate.py
from typing import Dict, Any, List, Optional
from enum import Enum
import json
import os
import logging

logger = logging.getLogger(__name__)

class Tier(Enum):
    FREE = "free"
    PRO = "pro"
    ENTERPRISE = "enterprise"

FEATURES = {
    Tier.FREE: {
        "max_batches_per_month": 5,
        "max_users_per_workspace": 1,
        "batch_history_days": 7,
        "multi_agent_orchestration": False,
        "self_improving_system": False,
        "ci_cd_pipeline": False,
        "team_workspaces": False,
        "priority_processing": False,
        "advanced_templates": False,
        "documentation_generation": False,
        "email_support": False,
        "api_access": True,
        "webhooks": False,
        "audit_logs": False,
        "sso": False,
        "white_label": False
    },
    Tier.PRO: {
        "max_batches_per_month": -1,
        "max_users_per_workspace": 3,
        "batch_history_days": 90,
        "multi_agent_orchestration": True,
        "self_improving_system": True,
        "ci_cd_pipeline": True,
        "team_workspaces": True,
        "priority_processing": True,
        "advanced_templates": True,
        "documentation_generation": True,
        "email_support": True,
        "api_access": True,
        "webhooks": True,
        "audit_logs": False,
        "sso": False,
        "white_label": False
    },
    Tier.ENTERPRISE: {
        "max_batches_per_month": -1,
        "max_users_per_workspace": -1,
        "batch_history_days": -1,
        "multi_agent_orchestration": True,
        "self_improving_system": True,
        "ci_cd_pipeline": True,
        "team_workspaces": True,
        "priority_processing": True,
        "advanced_templates": True,
        "documentation_generation": True,
        "email_support": True,
        "api_access": True,
        "webhooks": True,
        "audit_logs": True,
        "sso": True,
        "white_label": True
    }
}

class FeatureGate:
    def __init__(self):
        self.user_tiers = {}
    
    def get_user_tier(self, user_id: str) -> Tier:
        return self.user_tiers.get(user_id, Tier.FREE)
    
    def set_user_tier(self, user_id: str, tier: Tier):
        self.user_tiers[user_id] = tier
        logger.info(f"User {user_id} set to tier {tier.value}")
    
    def has_feature(self, user_id: str, feature_name: str) -> bool:
        tier = self.get_user_tier(user_id)
        features = FEATURES.get(tier, FEATURES[Tier.FREE])
        return features.get(feature_name, False)
    
    def get_feature_value(self, user_id: str, feature_name: str):
        tier = self.get_user_tier(user_id)
        features = FEATURES.get(tier, FEATURES[Tier.FREE])
        return features.get(feature_name)
    
    def get_entitlements(self, user_id: str) -> Dict[str, Any]:
        tier = self.get_user_tier(user_id)
        return {
            "tier": tier.value,
            "features": FEATURES.get(tier, FEATURES[Tier.FREE])
        }
    
    def can_create_batch(self, user_id: str, current_month_batches: int) -> bool:
        max_batches = self.get_feature_value(user_id, "max_batches_per_month")
        if max_batches == -1:
            return True
        return current_month_batches < max_batches
    
    def can_add_team_member(self, user_id: str, current_members: int) -> bool:
        max_members = self.get_feature_value(user_id, "max_users_per_workspace")
        if max_members == -1:
            return True
        return current_members < max_members
