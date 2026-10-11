# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Visão Geral do Projeto

DevSanar é um fórum de perguntas e respostas para desenvolvedores (estilo Stack Overflow) construído como um ecossistema de microsserviços. O objetivo principal é aprender e demonstrar sistemas distribuídos de nível de produção com Java/Spring Boot, Kafka, Kubernetes e AWS.

**Domínio de negócio:** Desenvolvedores publicam perguntas, recebem respostas, votam no conteúdo, ganham reputação e fazem crescer a comunidade.

**Objetivo técnico:** Construir um sistema distribuído real com comunicação síncrona e assíncrona, observável, testado, containerizado, orquestrado no Kubernetes e implantado na AWS.

## Arquitetura

Arquitetura de microsserviços com API Gateway como ponto de entrada único e comunicação assíncrona via Kafka entre serviços que não precisam de respostas imediatas.

```
SPA Angular → API Gateway → [user-service, question-service, notification-service]
                                    ↓ (eventos Kafka)
                              reputation-service
```

### Serviços e Responsabilidades

| Serviço | Propósito | Banco de Dados | Padrões Principais |
|---------|-----------|----------------|-------------------|
| `user-service` | Autenticação, perfis de usuário | PostgreSQL + Redis | Spring Security, JWT |
| `question-service` | Perguntas, respostas, tags, votos | PostgreSQL | DDD + Arquitetura Hexagonal |
| `reputation-service` | Pontos e badges de eventos | MySQL | Consumer Kafka, idempotência |
| `notification-service` | Notificações assíncronas | Stateless | Consumer Kafka |
| `api-gateway` | Ponto de entrada único, roteamento | Stateless | Spring Cloud Gateway |
| `frontend` | Interface SPA | N/A | Angular + TypeScript + Tailwind |

## Estrutura de Documentação

O projeto mantém documentação organizada no diretório `docs/`:

```
docs/
├── plans/          # Planos de implementação e roteiros de execução
├── adrs/           # Registros de Decisões de Arquitetura (ADRs)
└── artifacts/      # Artefatos do projeto (backlogs, diagramas, docs PMBOK)
```

### Registros de Decisões de Arquitetura (ADRs)

Todas as decisões arquiteturais significativas são documentadas como ADRs em `docs/adrs/`. Cada ADR segue o formato:

- **Título:** Nome descritivo curto
- **Status:** Proposto | Aceito | Depreciado | Substituído
- **Contexto:** Quais forças estão em jogo (técnicas, políticas, sociais, projeto)
- **Decisão:** O que decidimos fazer
- **Consequências:** O que fica mais fácil ou mais difícil como resultado

Ao fazer mudanças arquiteturais, crie um novo ADR ou atualize os existentes. Isso cria um registro histórico do porquê das decisões.

### Planos de Implementação

Planos de execução e quebra de tarefas são armazenados em `docs/plans/`. Estes documentam a abordagem passo a passo para implementar funcionalidades ou infraestrutura.

### Artefatos do Projeto

Documentação de suporte (itens de backlog, diagramas UML, artefatos de gerenciamento de projeto) vão em `docs/artifacts/`.

## Fluxo de Trabalho de Desenvolvimento

### Fase 1: Fundação (Mês 1)
Começar com `user-service` e `question-service` rodando localmente via Docker Compose:
- Autenticação JWT funcionando
- APIs REST documentadas (OpenAPI/Swagger)
- Testes unitários para lógica de domínio
- Testes de integração para repositories

### Fase 2: Distribuição (Mês 2)
Adicionar integração Kafka e serviços restantes:
- `reputation-service` consumindo eventos do `question-service`
- `notification-service` para notificações assíncronas
- `api-gateway` roteando todo o tráfego
- Frontend Angular consumindo as APIs
- Cache Redis para perguntas populares

### Fase 3: Produção (Mês 3)
Deploy em infraestrutura de nível de produção:
- Containerização completa com Dockerfiles otimizados
- Manifests Kubernetes (deployments, services, configmaps, secrets)
- Pipeline CI/CD via GitHub Actions
- Observabilidade: Prometheus + Grafana + Spring Boot Actuator
- Deploy AWS (EKS, RDS, ElastiCache)

## Convenção de Estrutura de Serviços

Cada serviço segue esta estrutura:

```
<nome-servico>/
├── src/
│   ├── main/
│   │   ├── java/com/devsanar/<servico>/
│   │   │   ├── domain/        # Entidades, value objects, domain services
│   │   │   ├── application/   # Casos de uso, DTOs, portas (interfaces)
│   │   │   ├── adapter/       # Adaptadores (REST, Kafka, JPA)
│   │   │   └── config/        # Configuração Spring
│   │   └── resources/
│   │       ├── application.yml
│   │       └── db/migration/  # Migrações Flyway
│   └── test/
├── Dockerfile.dev
├── Dockerfile.prod
├── pom.xml
└── README.md
```

### Arquitetura Hexagonal (question-service)

O `question-service` especificamente usa Arquitetura Hexagonal:

- **Camada de domínio:** Lógica de negócio pura, sem dependências de framework
- **Camada de aplicação:** Casos de uso orquestrando objetos de domínio, definindo portas (interfaces)
- **Camada de infraestrutura:** Adaptadores implementando portas (controllers REST, repositories JPA, producers Kafka)

Ao modificar `question-service`, respeite os limites de porta/adaptador. Código de domínio nunca deve importar Spring, JPA ou Kafka.

## Construindo e Executando

### Pré-requisitos
```bash
# Obrigatório
- Java 21+
- Maven 3.8+
- Docker & Docker Compose
- Node.js 22+ (para frontend)

# Para deploy em produção
- kubectl
- AWS CLI
- Terraform (opcional, para infraestrutura como código)
```

### Desenvolvimento Local

```bash
# Iniciar infraestrutura (PostgreSQL, MySQL, Redis, Kafka, Zookeeper)
docker-compose up -d

# Build e executar um serviço
cd services/<nome-servico>
mvn clean install
mvn spring-boot:run

# Executar testes
mvn test                    # Apenas testes unitários
mvn verify                  # Testes unitários + integração
mvn test -Dtest=ClassName   # Classe de teste única

# Frontend
cd frontend
npm install
npm start                   # Servidor de desenvolvimento em http://localhost:4200
npm test                    # Executar testes
npm run build               # Build de produção
```

### Docker Compose (Todos os Serviços)

```bash
# Build de todas as imagens de serviços
docker-compose build

# Iniciar todo o ecossistema
docker-compose up

# Iniciar serviços específicos
docker-compose up api-gateway question-service

# Ver logs
docker-compose logs -f <nome-servico>

# Derrubar
docker-compose down -v  # -v remove volumes (bancos de dados)
```

### Kubernetes (Local com Minikube)

```bash
# Iniciar Minikube
minikube start --cpus=4 --memory=8192

# Aplicar infraestrutura
kubectl apply -f infra/k8s/namespace.yaml
kubectl apply -f infra/k8s/postgres.yaml
kubectl apply -f infra/k8s/kafka.yaml

# Deploy dos serviços
kubectl apply -f infra/k8s/user-service.yaml
kubectl apply -f infra/k8s/question-service.yaml
# ... etc

# Verificar status
kubectl get pods -n devsanar
kubectl logs -f <nome-pod> -n devsanar

# Port forward para acesso local
kubectl port-forward svc/api-gateway 8080:8080 -n devsanar
```

## Diretrizes da Stack Tecnológica

### Configuração Spring Boot

- Usar `application.yml` para configuração (não .properties)
- Externalizar todas as configs específicas de ambiente (URLs de banco, brokers Kafka)
- Usar Spring Profiles: `dev`, `test`, `prod`
- Habilitar endpoints Actuator para observabilidade: `/actuator/health`, `/actuator/metrics`, `/actuator/prometheus`

### Convenções de Eventos Kafka

Eventos seguem esta estrutura:

```json
{
  "eventId": "uuid",
  "eventType": "QUESTION_CREATED | ANSWER_CREATED | VOTE_CAST | ...",
  "timestamp": "ISO-8601",
  "aggregateId": "question-123",
  "payload": { ... }
}
```

- Nomenclatura de tópicos: `devsanar.<dominio>.<evento>` (ex: `devsanar.questions.created`)
- Consumers devem ser idempotentes (verificar `eventId` duplicado)
- Usar tópicos dead-letter para tratamento de mensagens falhadas

### Migrações de Banco de Dados

- Usar Flyway para versionamento de schema
- Migrações em `src/main/resources/db/migration/`
- Nomenclatura: `V1__initial_schema.sql`, `V2__add_tags_table.sql`
- Nunca modificar migrações commitadas; criar novas

### Estratégia de Testes

**Testes Unitários:**
- Lógica de domínio isolada
- Sem contexto Spring, sem banco de dados
- Rápidos, numerosos, granulares

**Testes de Integração:**
- `@SpringBootTest` para contexto completo
- Testcontainers para PostgreSQL/MySQL/Kafka
- Testar endpoints de API, queries de repository, consumers de eventos
- Anotar com `@Tag("integration")` para executar separadamente

**Testes de Contrato:**
- Verificar contratos de API entre serviços
- Usar Spring Cloud Contract ou Pact

### Segurança

- Tokens JWT emitidos pelo `user-service`
- API Gateway valida tokens antes de rotear
- Serviços confiam no Gateway, não revalidam (rede interna)
- Secrets no Kubernetes Secrets, nunca no código ou Git
- Usar variáveis de ambiente para configurações sensíveis

## Observabilidade

### Logging
- Logs JSON estruturados (usar Logback com JSON encoder)
- Incluir `traceId` e `spanId` para rastreamento distribuído
- Níveis de log: ERROR (problemas que precisam ação), WARN (estado degradado), INFO (eventos chave), DEBUG (apenas desenvolvimento)

### Métricas
- Expor métricas Prometheus via `/actuator/prometheus`
- Métricas customizadas: taxa de criação de perguntas, contagens de votos, mudanças de reputação
- Dashboards no Grafana (templates em `infra/observability/grafana-dashboards/`)

### Rastreamento Distribuído
- Usar Spring Cloud Sleuth + Zipkin (fase futura)
- Rastrear requests através de serviços e eventos assíncronos

## Referência de Comandos Comuns

```bash
# Build limpo de todos os serviços
mvn clean install -DskipTests

# Executar testes de integração para um serviço
cd services/question-service
mvn verify -Dtest="*IT"

# Verificar versão do Spring Boot em todos os serviços
find . -name pom.xml -exec grep -H "spring-boot-starter-parent" {} \;

# Rebuild de imagens Docker após mudanças de código
docker-compose build --no-cache <nome-servico>

# Ver tópicos Kafka
docker exec -it devsanar-kafka kafka-topics.sh --list --bootstrap-server localhost:9092

# Tail de mensagens Kafka
docker exec -it devsanar-kafka kafka-console-consumer.sh --topic devsanar.questions.created --from-beginning --bootstrap-server localhost:9092

# Verificar schema de banco de dados
docker exec -it devsanar-postgres psql -U devsanar -d questions -c "\dt"

# Port forward de todos os serviços (Kubernetes)
kubectl port-forward svc/api-gateway 8080:8080 -n devsanar &
kubectl port-forward svc/frontend 4200:80 -n devsanar &
```

## Pipeline CI/CD

Workflow GitHub Actions (`.github/workflows/ci-cd.yml`):

1. **Stage de Build:** Compilar todos os serviços, executar testes unitários
2. **Stage de Teste:** Executar testes de integração com Testcontainers
3. **Stage de Pacote:** Build de imagens Docker, push para registry
4. **Stage de Deploy:** Atualizar deployments Kubernetes (EKS para prod)

Branches:
- `main`: Pronto para produção, auto-deploy para prod
- `develop`: Branch de integração, auto-deploy para staging
- Feature branches: Apenas checks de CI, sem deploy

## Princípios de Desenvolvimento

1. **API First:** Definir specs OpenAPI antes de implementar endpoints
2. **Testes de Contrato:** Serviços se comunicam via contratos bem definidos
3. **Compatibilidade Retroativa:** Nunca quebrar contratos de API existentes; versionar se necessário
4. **Event Sourcing Lite:** Mudanças de estado chave publicam eventos (perguntas, votos, reputação)
5. **Idempotência:** Todos os consumers Kafka devem lidar com mensagens duplicadas graciosamente
6. **Observabilidade desde o Dia 1:** Todo serviço expõe health checks e métricas
7. **Fail Fast:** Serviços recusam iniciar com configuração inválida
8. **Degradação Graciosa:** Cache protege contra falhas de banco onde possível

## Notas Importantes

- **Sem otimização prematura:** Construir para clareza primeiro, otimizar quando métricas mostrarem necessidade
- **Persistência poliglota é intencional:** Bancos de dados diferentes demonstram padrões diferentes
- **Kafka é assíncrono por design:** Não usá-lo para padrões request/response
- **Este é um projeto de aprendizado:** Documentar decisões em ADRs conforme avança
- **Frontend chama apenas API Gateway:** Nunca fazer bypass para serviços internos

## Troubleshooting

**Serviço não inicia:**
- Verificar logs: `docker-compose logs <servico>`
- Verificar se banco está pronto: `docker-compose ps`
- Verificar application.yml para connection strings corretas

**Consumer Kafka não recebe mensagens:**
- Verificar se tópico existe: `kafka-topics.sh --list`
- Verificar lag do consumer group: `kafka-consumer-groups.sh --describe --group <group-id>`
- Procurar erros de deserialização nos logs

**Migração de banco falhou:**
- Erros do Flyway estão nos logs do serviço
- Verificar tabela `flyway_schema_history` para o estado
- Para dev local, pode dropar e recriar: `docker-compose down -v && docker-compose up`

**Pod Kubernetes não inicia:**
- `kubectl describe pod <nome-pod> -n devsanar` para eventos
- Verificar pull de imagem, secrets, configmaps existem
- Verificar se limites de recursos não estão muito baixos

## Recursos

- README do Projeto: [README.md](./README.md)
- Diagramas de arquitetura: `docs/diagrams/`
- Documentação de API: Cada serviço expõe Swagger UI em `/swagger-ui.html`
- Observabilidade: Dashboards Grafana em `http://localhost:3000` (local), credenciais em docker-compose.yml
