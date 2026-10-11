# ADR-001: Arquitetura Monorepo

**Status:** Aceito  
**Data:** 2026-10-11  
**Decisores:** Henry

## Contexto

O projeto DevSanar consiste em 5 microsserviços backend, 1 aplicação frontend e configurações de infraestrutura compartilhada. Precisamos decidir como organizar esses componentes no controle de versão.

Três abordagens foram consideradas:
1. **Monorepo:** Todos os serviços em um único repositório
2. **Multi-repo:** Cada serviço em seu próprio repositório
3. **Monorepo com submódulos:** Abordagem híbrida

**Forças em jogo:**
- Este é um projeto de aprendizado gerenciado por um único desenvolvedor
- Refatorações frequentes entre serviços são esperadas durante o desenvolvimento inicial
- Necessidade de manter consistência em ferramentas, dependências e padrões
- Possibilidade futura de separar serviços se necessário
- Complexidade de CI/CD varia significativamente entre abordagens

## Decisão

Usaremos uma **arquitetura monorepo modular** com a seguinte estrutura:

```
devsanar/
├── pom.xml (parent)
├── services/
│   ├── user-service/
│   ├── question-service/
│   ├── reputation-service/
│   ├── notification-service/
│   └── api-gateway/
├── frontend/
└── infra/
```

Todos os serviços compartilham um POM parent para gerenciamento de dependências, mas cada serviço permanece independentemente deployável com seu próprio POM de módulo.

## Consequências

### Positivas
- **Coordenação simplificada:** Refatoração entre serviços é direta
- **Pipeline único de CI/CD:** Um workflow gerencia todos os serviços
- **Ferramentas consistentes:** Configurações compartilhadas de linting, formatação e build
- **Onboarding mais fácil:** Clone único, fonte única de documentação
- **Commits atômicos:** Mudanças que abrangem múltiplos serviços podem ser commitadas juntas
- **Código compartilhado:** DTOs, exceções e utilitários comuns podem viver em um módulo `shared/`

### Negativas
- **Tamanho do repositório:** Crescerá maior ao longo do tempo comparado a repos separados
- **Tempo de build:** `mvn clean install` completo compila todos os serviços (mitigado pelos builds incrementais do Maven)
- **Histórico Git:** Commits misturam mudanças de diferentes serviços
- **Sem controle de acesso por serviço:** Todos com acesso ao repo têm acesso a todos os serviços (não é uma preocupação para projeto solo)

### Neutras
- **Caminho de migração:** Pode ser dividido em repos separados depois se necessário usando `git filter-branch` ou subtree split
- **Docker Compose:** Funciona de forma idêntica tanto em configurações monorepo quanto multi-repo

## Notas

Esta decisão se alinha com os objetivos de aprendizado do projeto. Em um ambiente de produção com múltiplas equipes, multi-repo pode ser preferido para autonomia de equipes. Para um desenvolvedor solo construindo um projeto de portfólio, o monorepo reduz significativamente o atrito.
