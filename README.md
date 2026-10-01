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

## 7. Estrutura de pastas sugerida

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
│   ├── k8s/
│   │   ├── user-service.yaml
│   │   ├── question-service.yaml
│   │   └── ...
│   └── observability/
│       ├── prometheus.yml
│       └── grafana-dashboards/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
└── docs/
    ├── adr/              # Architecture Decision Records
    └── diagrams/
```
