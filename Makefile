# Makefile for OpenClaw Docker on Synology

.PHONY: help build up down logs restart clean status shell

help:
	@echo "OpenClaw Docker for Synology - Available commands:"
	@echo ""
	@echo "  make build    - Build the Docker image"
	@echo "  make up       - Start the container"
	@echo "  make down     - Stop the container"
	@echo "  make logs     - View container logs"
	@echo "  make restart  - Restart the container"
	@echo "  make status   - Show container status"
	@echo "  make shell    - Open a shell in the container"
	@echo "  make clean    - Remove container and image"
	@echo ""

build:
	docker-compose build

up:
	docker-compose up -d
	@echo "OpenClaw container started!"
	@echo "Remember to place CLAW.REZ in the assets directory"

down:
	docker-compose down

logs:
	docker-compose logs -f openclaw

restart:
	docker-compose restart

status:
	docker-compose ps

shell:
	docker-compose exec openclaw /bin/bash

clean:
	docker-compose down -v
	docker rmi openclaw:latest

setup-dirs:
	mkdir -p assets config saves
	touch assets/.gitkeep config/.gitkeep saves/.gitkeep
	@echo "Directories created. Please copy CLAW.REZ to assets/"
