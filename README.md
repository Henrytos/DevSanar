# DevSanar

> Fórum de perguntas e respostas para a comunidade de desenvolvimento de software — arquitetado como um ecossistema de microsserviços para colocar em prática, de ponta a ponta, toda a stack back-end, front-end, dados, mensageria e infraestrutura.

## 1. Por que esse projeto existe

A proposta nasceu da própria pesquisa de mercado e gaps reais: identificamos competências já dominadas (Java, Spring Boot, Kafka, Docker, testes automatizados) e gaps claros (Kubernetes, observabilidade, cultura DevOps completa, AWS em produção). O **DevSanar** foi desenhado para ser grande o suficiente para exercitar as duas listas ao mesmo tempo, num projeto único e coerente — não um conjunto de exercícios soltos.

A ideia de negócio: uma comunidade onde desenvolvedores tiram dúvidas técnicas, respondem perguntas de outros devs, ganham reputação por ajudar e encontram conteúdo relevante rapidamente — pense em algo no espírito de um Stack Overflow, mas construído e operado por você, do banco de dados ao Kubernetes.

## 2. Objetivos do projeto

- **Objetivo de produto:** permitir que desenvolvedores publiquem perguntas, recebam respostas, votem no conteúdo mais útil e evoluam uma reputação dentro da comunidade.
- **Objetivo de aprendizado (o que realmente importa aqui):** construir um sistema distribuído real, com múltiplos serviços se comunicando de forma síncrona e assíncrona, observável, testado, containerizado, orquestrado e implantado na nuvem — reproduzindo o dia a dia de vagas Pleno/Sênior Java.

## 3. Escopo funcional (MVP e evoluções)

### MVP (fase 1)
- Cadastro/login de usuários com autenticação segura
- Criar pergunta (título, descrição, tags)
- Responder pergunta
- Votar em perguntas e respostas (upvote/downvote)
- Marcar uma resposta como "aceita"

### Evoluções (fases seguintes)
- Sistema de reputação e badges (gamificação)
- Notificações assíncronas (nova resposta, resposta aceita, menção)
- Busca de perguntas por palavra-chave/tag
- Moderação de conteúdo (denúncias, edição, exclusão)
- Painel de métricas da comunidade (admin)

## 4. Arquitetura

Arquitetura de microsserviços, com um **API Gateway** como porta de entrada única e comunicação assíncrona via **Kafka** entre os serviços que não precisam de resposta imediata (reputação, notificações).

```
                              ┌──────────────────┐
                              │  Angular (SPA)    │
                              └─────────┬─────────┘
                                        │
                              ┌─────────▼─────────┐
                              │   API Gateway      │  (Spring Cloud Gateway)
                              └───┬─────┬─────┬────┘
                   ┌──────────────┘     │     └───────────────┐
         ┌─────────▼────────┐ ┌────────▼────────┐  ┌──────────▼─────────┐
         │   user-service    │ │ question-service │  │ notification-service│
         │ (auth, perfil)    │ │ (perguntas,      │  │ (e-mail/push,        │
         │ Postgres + Redis  │ │  respostas, votos)│  │  consumidor Kafka)   │
         └─────────┬─────────┘ │ Postgres (DDD)   │  └──────────▲─────────┘
                   │            └────────┬─────────┘             │
                   │                     │  eventos Kafka         │
                   │            ┌────────▼─────────┐             │
                   └───────────▶│ reputation-service│─────────────┘
                                │ MySQL + Kafka      │
                                └────────────────────┘

   Observabilidade transversal: Prometheus + Grafana + logs centralizados
   Infra: Docker Compose (dev) → Kubernetes (homolog/prod) → AWS (EC2/RDS/S3/VPC)
```

### Serviços

| Serviço | Responsabilidade | Banco | Padrões |
|---|---|---|---|
| `user-service` | Cadastro, login, autenticação, perfil | PostgreSQL | Spring Security + JWT |
| `question-service` | Perguntas, respostas, tags, votos | PostgreSQL | DDD + Arquitetura Hexagonal (evoluindo do que você já praticou no Cycle Authenticate) |
| `reputation-service` | Pontuação e badges, consumindo eventos | MySQL | Consumer Kafka, idempotência |
| `notification-service` | Notificações assíncronas | — (stateless) | Consumer Kafka |
| `api-gateway` | Roteamento, entrada única | — | Spring Cloud Gateway |
| `frontend` | Interface do fórum | — | Angular + TypeScript + Tailwind |

## 5. Stack técnica mapeada aos seus gaps

| Categoria | Tecnologia | Onde entra no projeto | Status na pesquisa de mercado |
|---|---|---|---|
| Linguagem/Framework | Java, Spring Boot, Spring Cloud, Spring Security, Maven | Todos os serviços back-end | ✅ Já domina |
| Mensageria | Apache Kafka | Eventos entre question → reputation → notification | ✅ Já domina |
| Banco de dados | PostgreSQL, MySQL, Redis | Persistência poliglota + cache de perguntas populares | ✅ Já domina |
| Testes | JUnit, Mockito | Testes unitários/integração em cada serviço | ✅ Já domina |
| Arquitetura | DDD, Arquitetura Hexagonal | `question-service` | ✅ Já domina |
| Containerização | Docker | Todos os serviços | ✅ Já domina |
| **Orquestração** | **Kubernetes** | Deploy de todos os serviços em cluster (ex.: Minikube local → EKS) | 🟡 Gap a cobrir |
| **Observabilidade** | **Prometheus + Grafana**, Spring Boot Actuator | Métricas, dashboards, alertas | 🔴 Gap a cobrir |
| **Cloud** | **AWS** (EC2, RDS, S3, VPC) | Deploy de produção, réplica do que já foi feito no Kore | 🟡 Praticado parcialmente, a aprofundar |
| **CI/CD / DevOps** | GitHub Actions | Build, testes e deploy automatizados a cada push | 🟡 Gap a aprofundar |
| Front-end | Angular, TypeScript, Tailwind | SPA do fórum | ✅ Já domina |

## 6. Roadmap sugerido (projeto de 3+ meses)

- **Mês 1 — Fundação:** `user-service` + `question-service` funcionando localmente com Docker Compose, autenticação JWT, testes unitários, API REST documentada.
- **Mês 2 — Distribuído:** integração via Kafka (`reputation-service`, `notification-service`), `api-gateway`, front-end Angular consumindo tudo, cache com Redis.
- **Mês 3 — Produção:** containerização completa, manifests Kubernetes, pipeline de CI/CD no GitHub Actions, observabilidade (Prometheus/Grafana + Actuator), deploy real na AWS.
- **Extra (se sobrar fôlego):** busca full-text, badges de gamificação, painel admin.

## 7. Estrutura de pastas

```
devsanar/
├── services/
│   ├── user-service/
│   ├── question-service/
│   ├── reputation-service/
│   ├── notification-service/
│   └── api-gateway/
├── frontend/
├── infra/
│   ├── docker-compose.yml
│   ├── docker-compose.dev.yml
│   ├── docker-compose.prod.yml
│   └── .env.example
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── docs/
│   ├── adrs/             # Architecture Decision Records
│   └── plans/            # Implementation Plans
├── Makefile
└── README.md
```

## 8. Como executar o projeto

### Pré-requisitos

- Docker e Docker Compose instalados
- Java 21+ (para desenvolvimento local)
- Maven 3.8+ (para desenvolvimento local)
- Node.js 22+ (para desenvolvimento frontend local)

### Comandos disponíveis (Makefile)

```bash
# Ver todos os comandos disponíveis
make help

# Desenvolvimento com live reload
make dev

# Desenvolvimento em background
make dev-bg

# Produção (builds otimizados)
make prod

# Apenas infraestrutura (bancos, Kafka, Redis)
make up

# Parar containers
make down

# Ver logs
make logs

# Ver logs de um serviço específico
make logs-service SERVICE=user-service

# Health check dos serviços
make health

# Rebuild após mudanças no código
make rebuild

# Rebuild de serviço específico
make rebuild-service SERVICE=question-service

# Limpar tudo (remove volumes - CUIDADO!)
make clean
```

### Execução rápida

**Modo desenvolvimento (com live reload):**
```bash
make dev
```

Serviços disponíveis:
- API Gateway: http://localhost:8080
- User Service: http://localhost:8081/actuator/health
- Question Service: http://localhost:8082/actuator/health
- Reputation Service: http://localhost:8083/actuator/health
- Notification Service: http://localhost:8084/actuator/health
- Frontend Angular: http://localhost:4200

**Modo produção:**
```bash
make prod
```

### Desenvolvimento local (sem Docker)

**Backend:**
```bash
# Compilar todos os serviços
mvn clean install

# Executar um serviço específico
cd services/user-service
mvn spring-boot:run
```

**Frontend:**
```bash
cd frontend
npm install
npm start
```

### Testes

```bash
# Executar todos os testes
make test

# Ou diretamente com Maven
mvn test

# Testes de integração
mvn verify
```

### Estrutura dos serviços

Cada serviço Spring Boot segue arquitetura hexagonal:

```
<nome-servico>/
├── src/main/java/com/devsanar/<servico>/
│   ├── domain/                 # Entidades, VOs, interfaces de porta
│   ├── application/            # Casos de uso, services
│   ├── adapter/
│   │   ├── in/web/            # Controllers REST
│   │   └── out/persistence/   # Repositories JPA
│   ├── config/                 # Configuração Spring
│   └── <Servico>Application.java
├── src/main/resources/
│   ├── application.yml
│   └── db/migration/          # Migrações Flyway
└── src/test/java/
```

### Troubleshooting

**Containers não iniciam:**
```bash
# Ver logs detalhados
make logs

# Verificar status
make ps

# Rebuild limpo
make build-nc
make dev
```

**Porta já em uso:**
- Verifique se há outros serviços rodando nas portas 8080-8084, 4200, 5432-5433, 3306, 6379, 9092

**Erro de compilação Maven:**
```bash
# Limpar e recompilar
mvn clean install -U
```
