# Colors
GREEN			= \033[0;32m
YELLOW			= \033[1;33m
RED				= \033[0;31m
BLUE			= \033[0;34m
RESET			= \033[0m

# Helper variables
NAME			=	inception
LOGIN			=	hcavet
DATA_PATH		=	/home/$(LOGIN)/data
ENV				=	LOGIN=$(LOGIN) DATA_PATH=$(DATA_PATH) COMPOSE_PROJECT_NAME=$(NAME)

# Commands
RM				=	rm -rf
COMPOSE_COMMAND	=	docker-compose -f
COMPOSE_FILE	=	./srcs/docker-compose.yml

# Targets
all:		header setup up

$(NAME):	all

header:		# Display header
			echo "$(BLUE)==============================$(RESET)"
			echo "$(GREEN)     🚀 Starting Inception     $(RESET)"
			echo "$(BLUE)==============================$(RESET)"

setup:		# Setup data folders
			echo "$(BLUE)🛠 Setting up data folders for Inception...$(RESET)"
			mkdir -p $(DATA_PATH)
			mkdir -p $(DATA_PATH)/wordpress
			mkdir -p $(DATA_PATH)/mariadb
			echo "$(GREEN)✅ All required folders are ready!$(RESET)"

up:			setup # Build & start containers
			echo "$(YELLOW)⬆️  Bringing up containers...$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) up -d --build
			echo "$(GREEN)✅ Containers are up!$(RESET)"
			$(MAKE) status

down:		# Stop & remove containers
			echo "$(YELLOW)⬇️ Taking down containers...$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) down
			echo "$(RED)🛑 Containers are down$(RESET)"

stop:		# Stop containers without removing them
			echo "$(YELLOW)✋ Stopping containers...$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) stop
			echo "$(RED)🛑 Containers stopped$(RESET)"

start:		# Start stopped containers
			echo "$(YELLOW)▶️ Starting containers...$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) start
			echo "$(GREEN)✅ Containers started$(RESET)"
			$(MAKE) status

kill:		# Force kill containers
			echo "$(RED)💀 Force-killing containers...$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) kill
			echo "$(RED)☠️  All containers killed$(RESET)"

status:		# List running containers
			echo "$(BLUE)🔍 Container status:$(RESET)"
			docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

logs:		# Follow logs
			echo "$(BLUE)📜 Showing logs... Press Ctrl+C to exit$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) logs -f

clean:		# Remove containers and volumes
			echo "$(YELLOW)🧹 Cleaning containers & volumes...$(RESET)"
			$(ENV) $(COMPOSE_COMMAND) $(COMPOSE_FILE) down -v
			echo "$(GREEN)✨ Cleaned containers & volumes$(RESET)"

fclean:		clean # Remove containers, prune and delete data
			echo "$(RED)🔥 Full cleanup (including $(DATA_PATH))...$(RESET)"
			$(RM) $(DATA_PATH)
			echo "$(YELLOW)🧨 Pruning Docker images, volume and network...$(RESET)"
			docker image prune -f
			docker volume prune -f
			docker network prune -f
			echo "$(GREEN)✨ System fully cleaned$(RESET)"

help:		# Display commands
			echo "$(BLUE)📌 Available commands:$(RESET)"
			grep -E '^[a-zA-Z]+ *:.*?#' Makefile | \
				awk 'BEGIN {FS=":.*?#"} {printf "  $(GREEN)%-10s$(RESET) %s\n", $$1, $$2}'

.SILENT:	all header setup up down stop start kill status logs clean fclean help