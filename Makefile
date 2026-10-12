.PHONY: help dev prod build up down clean logs ps restart rebuild test

# Default target
help:
	@echo "DevSanar - Makefile"
	@echo ""
	@echo "Comandos disponíveis:"
	@echo "  make dev          - Iniciar ambiente de desenvolvimento (live reload)"
	@echo "  make prod         - Iniciar ambiente de produção (builds otimizados)"
	@echo "  make build        - Build de todas as imagens Docker"
	@echo "  make up           - Iniciar apenas infraestrutura (bancos, Kafka, Redis)"
	@echo "  make down         - Parar todos os containers"
	@echo "  make clean        - Parar containers e remover volumes (CUIDADO: apaga dados)"
	@echo "  make logs         - Ver logs de todos os containers"
	@echo "  make logs-service - Ver logs de um serviço específico (ex: make logs-service SERVICE=user-service)"
	@echo "  make ps           - Listar containers em execução"
	@echo "  make restart      - Reiniciar todos os containers"
	@echo "  make rebuild      - Rebuild e reiniciar (após mudanças no código)"
	@echo "  make test         - Executar testes dos serviços Maven"
	@echo "  make mvn-install  - Build Maven de todos os serviços"
	@echo ""

# Desenvolvimento com live reload
dev:
	@echo "🚀 Iniciando ambiente de DESENVOLVIMENTO..."
	cd infra && docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Desenvolvimento em background
dev-bg:
	@echo "🚀 Iniciando ambiente de DESENVOLVIMENTO (background)..."
	cd infra && docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Produção com builds otimizados
prod:
	@echo "🏭 Iniciando ambiente de PRODUÇÃO..."
	cd infra && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# Produção em background
prod-bg:
	@echo "🏭 Iniciando ambiente de PRODUÇÃO (background)..."
	cd infra && docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Build de todas as imagens
build:
	@echo "🔨 Building todas as imagens Docker..."
	cd infra && docker-compose build

# Build sem cache
build-nc:
	@echo "🔨 Building todas as imagens (sem cache)..."
	cd infra && docker-compose build --no-cache

# Apenas infraestrutura (bancos, Kafka, Redis)
up:
	@echo "⚙️  Iniciando apenas infraestrutura..."
	cd infra && docker-compose up postgres-users postgres-questions mysql-reputation redis kafka zookeeper

# Parar todos os containers
down:
	@echo "🛑 Parando todos os containers..."
	cd infra && docker-compose down

# Parar e remover volumes (LIMPA DADOS!)
clean:
	@echo "🧹 Parando containers e removendo volumes (DADOS SERÃO PERDIDOS)..."
	@read -p "Tem certeza? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd infra && docker-compose down -v; \
		echo "✅ Volumes removidos"; \
	else \
		echo "❌ Operação cancelada"; \
	fi

# Ver logs de todos os containers
logs:
	@echo "📋 Logs de todos os containers..."
	cd infra && docker-compose logs -f

# Ver logs de um serviço específico
logs-service:
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Erro: especifique SERVICE=nome-do-servico"; \
		echo "Exemplo: make logs-service SERVICE=user-service"; \
		exit 1; \
	fi
	@echo "📋 Logs de $(SERVICE)..."
	cd infra && docker-compose logs -f $(SERVICE)

# Listar containers
ps:
	@echo "📊 Containers em execução:"
	cd infra && docker-compose ps

# Reiniciar todos os containers
restart:
	@echo "🔄 Reiniciando containers..."
	cd infra && docker-compose restart

# Reiniciar serviço específico
restart-service:
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Erro: especifique SERVICE=nome-do-servico"; \
		echo "Exemplo: make restart-service SERVICE=user-service"; \
		exit 1; \
	fi
	@echo "🔄 Reiniciando $(SERVICE)..."
	cd infra && docker-compose restart $(SERVICE)

# Rebuild e reiniciar (após mudanças no código)
rebuild:
	@echo "🔨 Rebuild e reiniciando..."
	cd infra && docker-compose up --build

# Rebuild serviço específico
rebuild-service:
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Erro: especifique SERVICE=nome-do-servico"; \
		echo "Exemplo: make rebuild-service SERVICE=user-service"; \
		exit 1; \
	fi
	@echo "🔨 Rebuild de $(SERVICE)..."
	cd infra && docker-compose up --build $(SERVICE)

# Executar testes Maven
test:
	@echo "🧪 Executando testes..."
	mvn test

# Build Maven de todos os serviços
mvn-install:
	@echo "📦 Build Maven (mvn clean install)..."
	mvn clean install

# Verificar compilação sem testes
mvn-compile:
	@echo "🔍 Compilando projeto..."
	mvn clean compile -DskipTests

# Health check de todos os serviços
health:
	@echo "❤️  Health check dos serviços..."
	@echo "User Service:"; curl -s http://localhost:8081/actuator/health | grep -o '"status":"[^"]*"' || echo "❌ Não disponível"
	@echo "Question Service:"; curl -s http://localhost:8082/actuator/health | grep -o '"status":"[^"]*"' || echo "❌ Não disponível"
	@echo "Reputation Service:"; curl -s http://localhost:8083/actuator/health | grep -o '"status":"[^"]*"' || echo "❌ Não disponível"
	@echo "Notification Service:"; curl -s http://localhost:8084/actuator/health | grep -o '"status":"[^"]*"' || echo "❌ Não disponível"
	@echo "API Gateway:"; curl -s http://localhost:8080/actuator/health | grep -o '"status":"[^"]*"' || echo "❌ Não disponível"

# Abrir shell em um serviço
shell:
	@if [ -z "$(SERVICE)" ]; then \
		echo "❌ Erro: especifique SERVICE=nome-do-servico"; \
		echo "Exemplo: make shell SERVICE=user-service"; \
		exit 1; \
	fi
	@echo "🐚 Abrindo shell em $(SERVICE)..."
	cd infra && docker-compose exec $(SERVICE) /bin/bash
