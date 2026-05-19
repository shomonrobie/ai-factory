.PHONY: help build up down logs clean test

help:
@echo "Available commands:"
@echo " make build - Build Docker images"
@echo " make up - Start all services"
@echo " make down - Stop all services"
@echo " make logs - View logs"
@echo " make clean - Clean up containers and volumes"

build:
docker-compose build

up:
docker-compose up -d
@echo "Services started. Access:"
@echo " Frontend: http://localhost:4000"
@echo " Backend API: http://localhost:4001"
@echo " API Docs: http://localhost:4001/docs"

down:
docker-compose down

logs:
docker-compose logs -f

clean:
docker-compose down -v
docker system prune -f
