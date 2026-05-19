# FactoryOS AI - Developer Guide

## Quick Start

git clone https://github.com/shomonrobie/ai-factory.git
cd ai-factory
docker-compose up -d

## API Integration

headers = {"Authorization": f"Bearer {API_KEY}"}

response = requests.post(
    "https://api.factoryos.ai/api/v1/batches/",
    headers=headers,
    json={"batch_number": 1, "prompt": "Create API"}
)

## Custom Agent

class CustomAgent(BaseAgent):
    async def process(self, task):
        return AgentResult(success=True, output="done")

## Testing

pytest backend/tests/ -v
cd frontend && npm test

## Deployment

docker build -f docker/Dockerfile.backend -t factoryos-backend .
kubectl apply -f k8s/deployment.yaml
