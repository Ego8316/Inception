# Colors
GREEN			= \033[0;32m
YELLOW			= \033[1;33m
RED				= \033[0;31m
BLUE			= \033[0;34m
RESET			= \033[0m

# Docker compose
COMPOSE_COMMAND	=	docker-compose -f
COMPOSE_FILE	=	./srcs/docker-compose.yml

# Targets
all				:	info up

info			:
					echo "$(BLUE)==============================$(RESET)"
					echo "$(GREEN)🚀 Starting Inception Stack$(RESET)"
					echo "$(BLUE)==============================$(RESET)"

up				:
					echo "$(YELLOW)⬆️  Bringing up containers...$(RESET)"
					$(COMPOSE_COMMAND) $(COMPOSE_FILE) up -d
					echo "$(GREEN)✅ Containers are up!$(RESET)"
					$(MAKE) status

down			:
					echo "$(YELLOW)⬇️ Taking down containers...$(RESET)"
					$(COMPOSE_COMMAND) $(COMPOSE_FILE) down
					echo "$(RED)🛑 All containers stopped!$(RESET)"

stop			:
					echo "$(YELLOW)✋ Stopping containers...$(RESET)"
					$(COMPOSE_COMMAND) $(COMPOSE_FILE) stop
					echo "$(RED)🛑 Containers stopped$(RESET)"

start			:
					echo "$(YELLOW)▶️ Starting containers...$(RESET)"
					$(COMPOSE_COMMAND) $(COMPOSE_FILE) start
					echo "$(GREEN)✅ Containers started$(RESET)"
					$(MAKE) status

status			:
					echo "$(BLUE)🔍 Container status:$(RESET)"
					docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

logs			:
					echo "$(BLUE)📜 Showing logs... Press Ctrl+C to exit$(RESET)"
					$(COMPOSE_COMMAND) $(COMPOSE_FILE) logs -f

.SILENT			:	all info up down stop start status logs