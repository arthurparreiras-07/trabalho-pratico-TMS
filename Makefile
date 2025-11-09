# ==============================================================================
# DevOps Monitoring - Makefile
# ==============================================================================

.PHONY: help up down logs restart clean status
.PHONY: test-all test-error test-slow test-users test-memory test-app-down
.PHONY: watch-alerts watch-metrics check-alerts

# Colors
CYAN    := \033[0;36m
YELLOW  := \033[0;33m
GREEN   := \033[0;32m
RED     := \033[0;31m
BLUE    := \033[0;34m
RESET   := \033[0m
BOLD    := \033[1m

# ==============================================================================
# HELP
# ==============================================================================

help: ## Mostra esta ajuda
	@echo ""
	@echo "$(BOLD)DevOps Monitoring - Comandos Disponíveis$(RESET)"
	@echo ""
	@echo "$(CYAN)GERENCIAMENTO:$(RESET)"
	@grep -E '^(up|down|restart|clean|logs|status):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)TESTES DE ALERTAS:$(RESET)"
	@grep -E '^test-.*:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)MONITORAMENTO:$(RESET)"
	@grep -E '^(watch-alerts|watch-metrics|check-alerts):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# ==============================================================================
# GERENCIAMENTO
# ==============================================================================

up: ## Inicia todos os containers
	@echo "$(BLUE)[INFO]$(RESET) Iniciando serviços Docker Compose..."
	@docker-compose up --build -d
	@echo ""
	@echo "$(GREEN)[SUCESSO]$(RESET) Todos os containers estão rodando"
	@echo ""
	@echo "$(BOLD)Endpoints dos Serviços:$(RESET)"
	@echo "  • Aplicação:     http://localhost:3000"
	@echo "  • Prometheus:    http://localhost:9090"
	@echo "  • Alertmanager:  http://localhost:9093"
	@echo "  • Grafana:       http://localhost:3001 $(CYAN)(admin/admin)$(RESET)"
	@echo ""
	@echo "$(CYAN)[DICA]$(RESET) Teste os alertas com: make test-all"
	@echo ""

down: ## Para todos os containers
	@echo "$(BLUE)[INFO]$(RESET) Parando todos os containers..."
	@docker-compose down
	@echo "$(GREEN)[SUCESSO]$(RESET) Containers parados"

logs: ## Mostra logs de todos os containers
	@echo "$(BLUE)[INFO]$(RESET) Exibindo logs (Ctrl+C para sair)..."
	@docker-compose logs -f

restart: ## Reinicia todos os containers
	@echo "$(BLUE)[INFO]$(RESET) Reiniciando todos os serviços..."
	@$(MAKE) down
	@$(MAKE) up

clean: ## Remove containers e volumes
	@echo "$(YELLOW)[AVISO]$(RESET) Removendo todos os containers e volumes..."
	@docker-compose down -v
	@echo "$(GREEN)[SUCESSO]$(RESET) Limpeza concluída"

status: ## Mostra status dos containers
	@echo "$(BOLD)Status dos Containers:$(RESET)"
	@echo ""
	@docker-compose ps

# ==============================================================================
# TESTES DE ALERTAS
# ==============================================================================

test-all: ## Executa TODOS os testes de alerta sequencialmente
	@echo ""
	@echo "$(BOLD)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo "$(BOLD)  Executando Todos os Testes de Alerta$(RESET)"
	@echo "$(BOLD)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(RESET)"
	@echo ""
	@$(MAKE) test-error
	@sleep 10
	@$(MAKE) test-slow
	@sleep 10
	@$(MAKE) test-users
	@sleep 10
	@$(MAKE) test-memory
	@echo ""
	@echo "$(GREEN)[SUCESSO]$(RESET) Todos os testes concluídos"
	@echo "$(CYAN)[DICA]$(RESET) Verifique os resultados: make check-alerts"
	@echo ""

test-error: ## Dispara alerta HighErrorRate
	@echo ""
	@echo "$(YELLOW)[TESTE]$(RESET) $(BOLD)Alerta HighErrorRate$(RESET)"
	@echo "  Condição:   taxa > 0.5 erros/seg por 30s"
	@echo "  Estratégia: Gerar 2 erros/seg por 60s"
	@echo ""
	@echo "$(BLUE)[INFO]$(RESET) Iniciando em 3 segundos..."
	@sleep 3
	@echo "$(BLUE)[EXECUTANDO]$(RESET) Gerando erros contínuos..."
	@for i in $$(seq 1 60); do \
		curl -s http://localhost:3000/simulate/error > /dev/null 2>&1 & \
		curl -s http://localhost:3000/simulate/error > /dev/null 2>&1 & \
		sleep 1; \
		if [ $$((i % 10)) -eq 0 ]; then \
			printf "  $(CYAN)[%02d/60s]$(RESET) Erros gerados...\n" $$i; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)[CONCLUÍDO]$(RESET) Teste finalizado"
	@echo "$(CYAN)[INFO]$(RESET) Alerta deve disparar em ~30s"
	@echo "$(CYAN)[INFO]$(RESET) Verifique em: http://localhost:9093"
	@echo ""

test-slow: ## Dispara alerta SlowRequests
	@echo ""
	@echo "$(YELLOW)[TESTE]$(RESET) $(BOLD)Alerta SlowRequests$(RESET)"
	@echo "  Condição:   percentil 95 > 1s por 1min"
	@echo "  Estratégia: Gerar 30 requisições lentas (2s cada)"
	@echo ""
	@echo "$(BLUE)[INFO]$(RESET) Iniciando em 3 segundos..."
	@sleep 3
	@echo "$(BLUE)[EXECUTANDO]$(RESET) Gerando requisições lentas..."
	@for i in $$(seq 1 30); do \
		curl -s http://localhost:3000/simulate/slow > /dev/null 2>&1 & \
		if [ $$((i % 5)) -eq 0 ]; then \
			printf "  $(CYAN)[%02d/30]$(RESET) Requisições lentas enviadas...\n" $$i; \
		fi; \
		sleep 2; \
	done
	@echo ""
	@echo "$(GREEN)[CONCLUÍDO]$(RESET) Teste finalizado"
	@echo "$(CYAN)[INFO]$(RESET) Alerta deve disparar em ~1min"
	@echo "$(CYAN)[INFO]$(RESET) Verifique em: http://localhost:9093"
	@echo ""

test-users: ## Dispara alerta HighActiveUsers
	@echo ""
	@echo "$(YELLOW)[TESTE]$(RESET) $(BOLD)Alerta HighActiveUsers$(RESET)"
	@echo "  Condição:   > 150 usuários ativos por 30s"
	@echo "  Estratégia: Manter alto número de usuários por 45s"
	@echo ""
	@echo "$(BLUE)[INFO]$(RESET) Iniciando em 3 segundos..."
	@sleep 3
	@echo "$(BLUE)[EXECUTANDO]$(RESET) Simulando pico de usuários..."
	@for i in $$(seq 1 15); do \
		curl -s http://localhost:3000/simulate/users > /dev/null 2>&1; \
		if [ $$((i % 5)) -eq 0 ]; then \
			printf "  $(CYAN)[%02d/15]$(RESET) Pico de usuários mantido...\n" $$i; \
		fi; \
		sleep 3; \
	done
	@echo ""
	@echo "$(GREEN)[CONCLUÍDO]$(RESET) Teste finalizado"
	@echo "$(CYAN)[INFO]$(RESET) Alerta deve disparar em ~30s"
	@echo "$(CYAN)[INFO]$(RESET) Verifique em: http://localhost:9093"
	@echo ""

test-memory: ## Dispara alerta HighMemoryUsage
	@echo ""
	@echo "$(YELLOW)[TESTE]$(RESET) $(BOLD)Alerta HighMemoryUsage$(RESET)"
	@echo "  Condição:   Memória > 100MB por 1min"
	@echo "  Estratégia: Forçar coleta de métricas de memória"
	@echo ""
	@echo "$(BLUE)[INFO]$(RESET) Iniciando em 3 segundos..."
	@sleep 3
	@echo "$(BLUE)[EXECUTANDO]$(RESET) Registrando uso de memória..."
	@for i in $$(seq 1 20); do \
		curl -s http://localhost:3000/simulate/memory > /dev/null 2>&1; \
		if [ $$((i % 5)) -eq 0 ]; then \
			printf "  $(CYAN)[%02d/20]$(RESET) Métricas de memória registradas...\n" $$i; \
		fi; \
		sleep 3; \
	done
	@echo ""
	@echo "$(GREEN)[CONCLUÍDO]$(RESET) Teste finalizado"
	@echo "$(CYAN)[INFO]$(RESET) Alerta deve disparar em ~1min"
	@echo "$(CYAN)[INFO]$(RESET) Verifique em: http://localhost:9093"
	@echo ""

test-app-down: ## Dispara alerta ApplicationDown
	@echo ""
	@echo "$(YELLOW)[TESTE]$(RESET) $(BOLD)Alerta ApplicationDown$(RESET)"
	@echo "  Condição:   Aplicação offline por 30s"
	@echo "  Estratégia: Parar container por 45s"
	@echo ""
	@read -p "$(YELLOW)[AVISO]$(RESET) Isso vai parar a aplicação por 45s. Continuar? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(BLUE)[INFO]$(RESET) Parando container da aplicação..."; \
		docker-compose stop app; \
		echo "$(BLUE)[INFO]$(RESET) Aguardando 45 segundos..."; \
		sleep 45; \
		echo "$(BLUE)[INFO]$(RESET) Reiniciando container da aplicação..."; \
		docker-compose start app; \
		echo ""; \
		echo "$(GREEN)[CONCLUÍDO]$(RESET) Teste finalizado"; \
		echo "$(CYAN)[INFO]$(RESET) Verifique em: http://localhost:9093"; \
	else \
		echo "$(RED)[CANCELADO]$(RESET) Teste abortado"; \
	fi
	@echo ""

# ==============================================================================
# MONITORAMENTO
# ==============================================================================

watch-alerts: ## Monitora alertas em tempo real
	@echo "$(BLUE)[INFO]$(RESET) Monitorando alertas (Ctrl+C para sair)..."
	@echo ""
	@watch -n 2 'curl -s http://localhost:9093/api/v2/alerts 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -E "(alertname|state|startsAt)" || echo "Nenhum alerta ativo"'

watch-metrics: ## Monitora métricas em tempo real
	@echo "$(BLUE)[INFO]$(RESET) Monitorando métricas (Ctrl+C para sair)..."
	@echo ""
	@watch -n 2 'echo "=== MÉTRICAS ===" && curl -s http://localhost:3000/metrics 2>/dev/null | grep -E "(app_errors_total|app_active_users|app_memory_usage_bytes|http_requests_total)" | head -10'

check-alerts: ## Verifica alertas ativos no momento
	@echo ""
	@echo "$(BOLD)Alertas Ativos:$(RESET)"
	@echo ""
	@ALERTS=$$(curl -s http://localhost:9093/api/v2/alerts 2>/dev/null); \
	if [ "$$ALERTS" = "[]" ]; then \
		echo "  $(GREEN)✓$(RESET) Nenhum alerta ativo"; \
	elif [ -z "$$ALERTS" ]; then \
		echo "  $(RED)✗$(RESET) Não foi possível conectar ao Alertmanager"; \
		echo "  $(CYAN)[DICA]$(RESET) Verifique o status dos containers: make status"; \
	else \
		echo "$$ALERTS" | python3 -c 'import sys, json; alerts = json.load(sys.stdin); [print(f"  $(YELLOW)⚠$(RESET) {a[\"labels\"][\"alertname\"]} ({a[\"labels\"][\"severity\"]}) - {a[\"status\"][\"state\"]}") for a in alerts]' 2>/dev/null || echo "$$ALERTS"; \
	fi
	@echo ""
	@echo "$(BOLD)Links Rápidos:$(RESET)"
	@echo "  • Prometheus:    http://localhost:9090/alerts"
	@echo "  • Alertmanager:  http://localhost:9093"
	@echo ""
