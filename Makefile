NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml -p $(NAME)
USER = ssottori
DATA_PATH = /home/$(USER)/data

RESET = \033[0m
BOLD = \033[1m
PINK = \033[38;5;213m
LILAC = \033[38;5;219m
MINT = \033[38;5;122m
CYAN = \033[38;5;159m
GRAY = \033[38;5;245m

all: banner up

banner:
	@echo "$(PINK)$(BOLD)"
	@echo "██╗███╗   ██╗ ██████╗███████╗██████╗ ████████╗██╗ ██████╗ ███╗   ██╗"
	@echo "██║████╗  ██║██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║"
	@echo "██║██╔██╗ ██║██║     █████╗  ██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║"
	@echo "██║██║╚██╗██║██║     ██╔══╝  ██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║"
	@echo "██║██║ ╚████║╚██████╗███████╗██║        ██║   ██║╚██████╔╝██║ ╚████║"
	@echo "╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
	@echo "$(RESET)$(GRAY)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "$(CYAN)		Project: $(NAME) by ssottori $(RESET)\n"
	@echo "$(CYAN)                      Docker Infrastructure$(RESET)"
	@echo "$(GRAY)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"

up:
	@echo "$(LILAC)Creating volume directories...$(RESET)"
	@mkdir -p $(DATA_PATH)/vol_wp
	@mkdir -p $(DATA_PATH)/vol_db
	@echo "$(LILAC)▶ Building and starting containers...$(RESET)"
	@$(COMPOSE) up --build -d
	@echo "$(MINT)✔ Infrastructure is running!$(RESET)"

down:
	@echo "$(LILAC)▼ Stopping containers...$(RESET)"
	@$(COMPOSE) down
	@echo "$(MINT)✔ Containers stopped successfully!$(RESET)"

clean:
	@echo "$(LILAC)◼ Removing containers, network, and volumes...$(RESET)"
	@$(COMPOSE) down --remove-orphans
	@echo "$(MINT)✔ Project cleanup done!$(RESET)"

fclean: clean
	@echo "$(PINK)✦ Removing unused Docker data...$(RESET)"
	@docker volume rm -f $(NAME)_vol_db
	@docker volume rm -f $(NAME)_vol_wp
	@docker system prune -af --volumes
	@echo "$(MINT)✔ Everything cleaned successfully!$(RESET)"

re: fclean all

.PHONY: all banner up down clean fclean re

# @docker image rm mariadb wordpress nginx 2>/dev/null || true