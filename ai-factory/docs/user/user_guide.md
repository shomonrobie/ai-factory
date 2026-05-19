# FactoryOS AI - User Guide

## Getting Started

### Sign Up
1. Visit https://factoryos.ai
2. Click Sign Up
3. Enter email and password
4. Verify email

### Create a Batch

curl -X POST https://api.factoryos.ai/api/v1/batches/ \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"batch_number": 1, "prompt": "Create a todo list app"}'

### Check Status

curl -X GET https://api.factoryos.ai/api/v1/batches/1 \
  -H "Authorization: Bearer YOUR_API_KEY"

### Use Agents

curl -X POST https://api.factoryos.ai/api/v1/agents/generate \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Create user authentication", "entity_name": "User"}'
