# ADR-006: Estratégia Docker Multi-Ambiente

**Status:** Aceito  
**Data:** 2026-10-11  
**Decisores:** Henry

## Contexto

Precisamos containerizar todos os serviços (5 backend + frontend) tanto para ambientes de desenvolvimento quanto de produção. A estratégia deve suportar:
- **Desenvolvimento:** Rebuild rápido, live reload, debug fácil
- **Produção:** Imagens otimizadas, tamanho mínimo, hardening de segurança

**Abordagens consideradas:**

1. **Dockerfile único por serviço:** Usar build args para alternar entre dev/prod
2. **Dockerfiles separados:** `Dockerfile.dev` e `Dockerfile.prod` por serviço
3. **Targets do Docker Compose:** Dockerfile multi-stage com stages nomeados, compose seleciona target
4. **Sem containers dev:** Desenvolver localmente sem Docker, containerizar apenas para prod

## Decisão

Usaremos **Dockerfiles separados** (`Dockerfile.dev` e `Dockerfile.prod`) para cada serviço, orquestrados por Docker Compose com arquivos de override.

**Estrutura:**
```
services/user-service/
├── Dockerfile.dev      # Desenvolvimento: live reload, JDK completo
├── Dockerfile.prod     # Produção: multi-stage, JRE mínimo

infra/
├── docker-compose.yml           # Definição base (todos os serviços)
├── docker-compose.dev.yml       # Overrides de desenvolvimento
├── docker-compose.prod.yml      # Overrides de produção
└── .env.example                 # Template para variáveis de ambiente
```

**Execução:**
```bash
# Modo desenvolvimento
docker-compose -f infra/docker-compose.yml -f infra/docker-compose.dev.yml up

# Modo produção
docker-compose -f infra/docker-compose.yml -f infra/docker-compose.prod.yml up
```

## Consequências

### Positivas
- **Separação clara:** Dockerfiles dev e prod são independentes, sem condicionais complexas
- **Velocidade de desenvolvimento:** `Dockerfile.dev` otimizado para rebuilds rápidos e live reload
- **Otimização de produção:** `Dockerfile.prod` usa multi-stage builds para imagens finais mínimas
- **Configuração explícita:** Overrides do Docker Compose tornam diferenças de ambiente visíveis
- **Manutenção fácil:** Mudar comportamento dev não arrisca quebrar builds prod
- **Debug local:** Containers dev expõem portas de debug, montam volumes de source

### Negativas
- **Duplicação:** Algumas instruções de Dockerfile repetidas entre versões dev e prod
- **Mais arquivos:** 2 Dockerfiles por serviço (10 total para backend, 2 para frontend)
- **Complexidade do Compose:** Deve lembrar de especificar ambos arquivos YAML

### Neutras
- **CI/CD:** Pipeline de produção usa apenas Dockerfiles prod
- **Tamanho de imagem:** Imagens dev maiores (~800MB JDK) vs prod (~200MB JRE), trade-off aceitável

## Detalhes de Implementação

### Serviços Backend (Spring Boot)

**Dockerfile.dev:**
```dockerfile
FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn dependency:go-offline
CMD ["mvn", "spring-boot:run"]
```
- JDK completo para compilação
- Código fonte montado como volume (live reload via Spring DevTools)
- Maven roda no container
- Sem otimização, foco em velocidade

**Dockerfile.prod:**
```dockerfile
# Stage 1: Build
FROM eclipse-temurin:21-jdk AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /build/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```
- Multi-stage: build no JDK, execução no JRE
- Imagem final ~200MB (vs ~800MB single-stage)
- Sem código fonte na imagem final
- Entrypoint pronto para produção

### Frontend (Angular)

**Dockerfile.dev:**
```dockerfile
FROM node:22
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
CMD ["npm", "start"]
```
- Executa `ng serve` com live reload
- Source montado como volume
- Hot module replacement habilitado

**Dockerfile.prod:**
```dockerfile
# Stage 1: Build
FROM node:22 AS build
WORKDIR /app
COPY package*.json .
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build /app/dist/frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
- Multi-stage: build com Node, servir com nginx
- Imagem final ~20MB
- Build de produção otimizado do Angular

### Estratégia Docker Compose

**docker-compose.yml (base):**
- Define todos os serviços (backend, frontend, bancos, Kafka)
- Variáveis de ambiente comuns
- Definições de networks e volumes
- Sem configuração específica de build (overridden por dev/prod)

**docker-compose.dev.yml (override):**
```yaml
services:
  user-service:
    build:
      dockerfile: Dockerfile.dev
    volumes:
      - ./services/user-service:/app
    ports:
      - "8081:8080"
      - "5005:5005"  # Porta de debug
    environment:
      - SPRING_DEVTOOLS_RESTART_ENABLED=true
```
- Usa `Dockerfile.dev`
- Monta source como volume para live reload
- Expõe portas de debug
- Variáveis de ambiente amigáveis ao desenvolvimento

**docker-compose.prod.yml (override):**
```yaml
services:
  user-service:
    build:
      dockerfile: Dockerfile.prod
    restart: always
    environment:
      - SPRING_PROFILES_ACTIVE=prod
```
- Usa `Dockerfile.prod`
- Sem volumes (código embutido na imagem)
- Variáveis de ambiente de produção
- Políticas de restart

## Configuração de Live Reload

**Backend (Spring Boot):**
- Adicionar dependência `spring-boot-devtools`
- Container dev monta source como volume
- Spring DevTools detecta mudanças e reinicia automaticamente
- Tempo de restart ~2-3 segundos

**Frontend (Angular):**
- `ng serve` observa mudanças em arquivos
- Container dev monta source como volume
- Hot module replacement (HMR) para updates instantâneos
- Sem necessidade de restart

## Considerações de Segurança

**Hardening de produção:**
- Usar imagens base oficiais (eclipse-temurin, nginx:alpine)
- Multi-stage builds previnem código fonte na imagem final
- Executar como usuário non-root (adicionar diretiva USER em Dockerfiles prod)
- Escanear imagens com `docker scan` no CI/CD
- Fixar versões de imagem base (não usar `latest`)

## Alternativas Rejeitadas

**Dockerfile único com build args:**
- Rejeitado porque mistura preocupações dev e prod em um arquivo
- Mais difícil de ler e manter
- Fácil acidentalmente enviar ferramentas dev para produção

**Multi-stage com compose targets:**
- Rejeitado porque arquivos de override são mais explícitos
- Seleção de target pode ser obscura no docker-compose.yml

**Sem containers dev:**
- Rejeitado porque cria problemas de "funciona na minha máquina"
- Docker garante ambiente dev consistente

## Notas

Esta estratégia equilibra experiência do desenvolvedor (iterações rápidas) com requisitos de produção (imagens pequenas e seguras). A separação explícita via arquivos diferentes previne problemas acidentais de produção de ferramentas dev.

Arquivos de override do Docker Compose são um padrão estabelecido e bem documentado, reduzindo atrito de onboarding.
