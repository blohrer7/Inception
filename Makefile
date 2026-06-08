DATA_PATH	= /home/blohrer/data
# Shortcut damit der compose-Befehl nicht jedes Mal ausgeschrieben werden muss
COMPOSE		= docker compose -f srcs/docker-compose.yml
# Standard-Ziel: Verzeichnisse anlegen, Images bauen, Container starten
all:
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	@$(COMPOSE) up -d --build

# Container stoppen und entfernen (Volumes bleiben erhalten)
down:
	@$(COMPOSE) down

# Kompletter Neustart (down + all)
re: down all

# Images und Daten-Verzeichnis entfernen (Volumes gehen verloren!)
clean: down
	@docker system prune -af
	@sudo rm -rf $(DATA_PATH)

# Wie clean, entfernt zusätzlich alle ungenutzten Docker-Volumes
fclean: clean
	@docker volume prune -f

# Logs aller Container live verfolgen
logs:
	@$(COMPOSE) logs -f

# Status aller Container anzeigen
ps:
	@$(COMPOSE) ps

.PHONY: all down re clean fclean logs ps
