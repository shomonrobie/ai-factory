# FactoryOS AI - Deployment Guide

## Docker Compose (Development)

docker-compose up -d

## Kubernetes (Production)

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

## Environment Variables

DATABASE_URL=postgresql://user:pass@postgres:5432/factoryos
REDIS_URL=redis://redis:6379
JWT_SECRET=your-secret-key
OPENAI_API_KEY=sk-...

## SSL Configuration

certbot --nginx -d factoryos.ai

## Monitoring

Prometheus: http://localhost:9090
Grafana: http://localhost:3000

## Backup

pg_dump factoryos > backup.sql
aws s3 cp backup.sql s3://factoryos-backups/
