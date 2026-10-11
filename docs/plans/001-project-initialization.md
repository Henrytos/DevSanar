# Plano de Inicialização do Projeto DevSanar

**Data:** 2026-10-11  
**Status:** Em Execução  
**Objetivo:** Criar a estrutura base completa para o projeto DevSanar com 5 microsserviços (Spring Boot), frontend (Angular 22) e infraestrutura Docker.

## Contexto

O DevSanar é um projeto de aprendizado que simula um ambiente de produção completo com microsserviços. Este plano estabelece a fundação do projeto - scaffolding de todos os serviços, estrutura hexagonal, containerização e orquestração Docker.

**Por que agora:** Sem a base estruturada, não é possível começar a implementar funcionalidades. Este é o ponto de partida obrigatório.

**Decisões já tomadas:**
- Monorepo modular (ver ADR-001)
- Spring Boot 3.3.x + Java 21 (ver ADR-002)
- Angular 22 (ver ADR-003)
- Arquitetura hexagonal com pacotes por camada (ver ADR-004)
- JWT puro para autenticação (ver ADR-005)
- Estratégia Docker multi-ambiente (ver ADR-006)

## Estrutura Final

```
devsanar/
├── pom.xml                          # Parent POM
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
└── docs/
    ├── plans/
    ├── adrs/
    └── artifacts/
```

## Escopo de Implementação

### 1. Parent POM Maven
- Define Spring Boot 3.3.x como parent
- Declara os 5 serviços como módulos
- Centraliza versões de dependências:
  - Spring Cloud: 2023.0.x (compatível com Boot 3.3)
  - PostgreSQL Driver: gerenciado pelo Spring Boot BOM
  - MySQL Connector: gerenciado pelo Spring Boot BOM
  - jjwt: 0.12.x
  - Lombok: gerenciado pelo Spring Boot BOM
- Configura plugins compartilhados (spring-boot-maven-plugin, maven-compiler-plugin)

### 2. Microsserviços Spring Boot (5x)

Cada serviço segue estrutura hexagonal:

```
<nome-servico>/
├── pom.xml
├── Dockerfile.dev              # Live reload com Spring DevTools
├── Dockerfile.prod             # Multi-stage build otimizado
└── src/main/java/com/devsanar/<servico>/
    ├── domain/                 # Entidades, VOs, interfaces de porta
    ├── application/            # Casos de uso, services
    ├── adapter/
    │   ├── in/web/            # Controllers REST
    │   └── out/persistence/   # Repositories JPA
    ├── config/                 # Configuração Spring
    └── <Servico>Application.java
```

**Dependências base por serviço:**

- **user-service:**
  - spring-boot-starter-web
  - spring-boot-starter-data-jpa
  - spring-boot-starter-security
  - jjwt-api, jjwt-impl, jjwt-jackson (JWT)
  - postgresql
  - spring-boot-starter-data-redis
  - spring-boot-starter-validation
  - spring-boot-starter-actuator
  - flyway-core
  - lombok

- **question-service:**
  - spring-boot-starter-web
  - spring-boot-starter-data-jpa
  - spring-kafka
  - postgresql
  - spring-boot-starter-validation
  - spring-boot-starter-actuator
  - flyway-core
  - lombok

- **reputation-service:**
  - spring-boot-starter-web
  - spring-boot-starter-data-jpa
  - spring-kafka
  - mysql-connector-java
  - spring-boot-starter-actuator
  - flyway-core
  - lombok

- **notification-service:**
  - spring-boot-starter-web
  - spring-kafka
  - spring-boot-starter-mail
  - spring-boot-starter-actuator
  - lombok

- **api-gateway:**
  - spring-cloud-starter-gateway
  - spring-boot-starter-actuator

### 3. Frontend Angular 22

```
frontend/
├── package.json
├── angular.json
├── Dockerfile.dev              # ng serve com live reload
├── Dockerfile.prod             # nginx multi-stage
└── src/
    ├── app/
    │   ├── core/               # Services, guards, interceptors
    │   ├── shared/             # Componentes reutilizáveis
    │   └── features/           # Módulos de features
    └── environments/
```

**Dependências:**
- @angular/core: ^22.0.0
- TypeScript: ~5.6.0
- Tailwind CSS: ^3.4.0
- RxJS: ^7.8.0
- @angular/common/http (cliente HTTP)
- @angular/router (roteamento)

### 4. Infraestrutura Docker

**docker-compose.yml** (base):
- Define todos os serviços (5 backend + frontend)
- Define infraestrutura (PostgreSQL, MySQL, Redis, Kafka, Zookeeper)
- Networks compartilhadas

**docker-compose.dev.yml** (override para desenvolvimento):
- Usa `Dockerfile.dev` em cada serviço
- Monta volumes para live reload
- Expõe portas para debug local
- Variáveis de ambiente para dev

**docker-compose.prod.yml** (override para produção):
- Usa `Dockerfile.prod` com multi-stage build
- Sem volumes de código fonte
- Otimizações de imagem
- Variáveis de ambiente para prod

**Execução:**
```bash
# Modo dev
docker-compose -f infra/docker-compose.yml -f infra/docker-compose.dev.yml up

# Modo prod
docker-compose -f infra/docker-compose.yml -f infra/docker-compose.prod.yml up
```

### 5. Dockerfiles

Cada serviço tem 2 Dockerfiles:

**Dockerfile.dev:**
- Base: `eclipse-temurin:21-jdk`
- Copia código fonte
- Usa Spring DevTools para live reload
- Não otimiza camadas
- Rápido para rebuild durante desenvolvimento

**Dockerfile.prod:**
- Multi-stage build
- Stage 1: Build com Maven
- Stage 2: Runtime mínimo com JRE
- Copia apenas JAR final
- Imagem otimizada (menor tamanho)

**Frontend Dockerfiles:**

**Dockerfile.dev:**
- Base: `node:22`
- Expõe `ng serve`
- Live reload habilitado

**Dockerfile.prod:**
- Stage 1: Build com `node:22` → gera dist/
- Stage 2: nginx:alpine + copia dist/
- Imagem final ~20MB

### 6. Estrutura de Testes

Cada serviço Spring Boot inclui:

**Testes Unitários:**
- Dependências: JUnit 5, Mockito, AssertJ
- Localização: `src/test/java`
- Escopo: Lógica de domínio isolada, sem Spring context
- Cobertura: Domain services, entidades, value objects

**Testes de Integração:**
- Dependências: 
  - spring-boot-starter-test
  - testcontainers (PostgreSQL, MySQL, Kafka)
  - rest-assured (para testes de API)
- Localização: `src/test/java` com anotação `@Tag("integration")`
- Escopo: Endpoints REST, repositories JPA, consumers Kafka
- Configuração: `@SpringBootTest` com Testcontainers

**Frontend (Angular):**
- Framework: Jasmine + Karma (padrão Angular)
- Testes unitários para componentes, services e pipes
- Testes e2e com Playwright (fase futura)

## Critérios de Aceitação

✅ **Repositório configurado:**
- Estrutura de pastas criada
- Parent POM válido
- .gitignore configurado

✅ **Serviços Spring Boot:**
- 5 serviços compilam com `mvn clean install`
- Cada um tem endpoint de health `/actuator/health`
- Estrutura hexagonal implementada (pacotes domain, application, adapter)
- Application.java de cada serviço sobe localmente

✅ **Frontend Angular:**
- `npm install` executa sem erros
- `ng serve` sobe aplicação em localhost:4200
- Página inicial exibe "DevSanar" ou equivalente

✅ **Docker:**
- Cada serviço tem Dockerfile.dev e Dockerfile.prod
- `docker-compose.yml` orquestra todos os serviços + infra
- Overrides (dev/prod) funcionam corretamente
- `docker-compose up` em modo dev sobe tudo e aplica live reload

✅ **Documentação:**
- ADRs criadas para decisões principais
- README atualizado com instruções de setup
- CLAUDE.md documenta estrutura de docs/

## Verificação Final

Após implementação, executar:

```bash
# Compilar todos os serviços
mvn clean install

# Verificar health de cada serviço individualmente
cd services/user-service && mvn spring-boot:run
# Acessar http://localhost:8081/actuator/health (deve retornar UP)

# Compilar frontend
cd frontend && npm install && npm run build

# Subir todo o ambiente em modo dev
docker-compose -f infra/docker-compose.yml -f infra/docker-compose.dev.yml up
# Verificar logs de todos os containers
# Acessar endpoints de health via API Gateway

# Subir em modo prod (teste de build otimizado)
docker-compose -f infra/docker-compose.yml -f infra/docker-compose.prod.yml build
```

## Próximos Passos

Após este plano:
1. Implementar autenticação JWT no user-service
2. Criar endpoints REST para questions/answers
3. Configurar Kafka producers/consumers
4. Implementar UI básica no Angular
