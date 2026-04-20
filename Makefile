NAME = inception
USER = shaly
COMPOSE = docker compose -f srcs/docker-compose.yml -p $(NAME)
DATA_PATH = /home/$(USER)/data

RESET = \033[0m
MINT = \033[38;5;122m
LILAC = \033[38;5;219m
PINK = \033[38;5;213m

all: up

up:
	@echo "$(LILAC)Creating volume directories...$(RESET)"
	@mkdir -p $(DATA_PATH)/vol_wp
	@mkdir -p $(DATA_PATH)/vol_db
	@echo "$(PINK)Building and starting containers...$(RESET)"
	@$(COMPOSE) up --build -d
	@echo "$(MINT)Infrastructure is running!$(RESET)"

down:
	@echo "$(LILAC)Stopping containers...$(RESET)"
	@$(COMPOSE) down
	@echo "$(MINT)Containers stopped successfully!$(RESET)"

fclean: down
	@echo "$(PINK)Full cleanup in progress...$(RESET)"
	@docker system prune --all --force --volumes
	@rm -rf $(DATA_PATH)
	@echo "$(MINT)Everything cleaned successfully!$(RESET)"

re: fclean all

.PHONY: all up down fclean re
