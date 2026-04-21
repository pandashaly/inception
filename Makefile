NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml -p $(NAME)

RESET = \033[0m
MINT = \033[38;5;122m
LILAC = \033[38;5;219m
PINK = \033[38;5;213m

all: up

up:
	@echo "$(PINK)Building and starting containers...$(RESET)"
	@$(COMPOSE) up --build -d
	@echo "$(MINT)Infrastructure is running!$(RESET)"

down:
	@echo "$(LILAC)Stopping containers...$(RESET)"
	@$(COMPOSE) down
	@echo "$(MINT)Containers stopped successfully!$(RESET)"

clean:
	@echo "$(LILAC)Stopping containers and removing project volumes...$(RESET)"
	@$(COMPOSE) down -v --remove-orphans
	@echo "$(MINT)Project cleanup done!$(RESET)"

fclean: clean
	@echo "$(PINK)Removing unused Docker data...$(RESET)"
	@docker system prune -af
	@echo "$(MINT)Everything cleaned successfully!$(RESET)"

re: fclean all

.PHONY: all up down clean fclean re

# @docker image rm mariadb wordpress nginx 2>/dev/null || true