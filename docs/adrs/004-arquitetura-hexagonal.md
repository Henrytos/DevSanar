# ADR-004: Arquitetura Hexagonal com Pacotes por Camada

**Status:** Aceito  
**Data:** 2026-10-11  
**Decisores:** Henry

## Contexto

Precisamos definir o padrão de arquitetura interna para todos os microsserviços. A arquitetura deve:
- Impor separação de responsabilidades
- Tornar a lógica de domínio independente de frameworks
- Permitir testes fáceis
- Suportar princípios SOLID
- Ser consistente entre todos os serviços

**Opções consideradas:**

1. **Arquitetura em camadas tradicional:** Controller → Service → Repository
2. **Arquitetura hexagonal (Portas & Adaptadores):** Domínio no centro, adaptadores nas bordas
3. **Clean architecture:** Similar à hexagonal mas com mais camadas
4. **Módulos baseados em feature:** Pacotes por feature ao invés de camada

**Organização de pacotes dentro da hexagonal:**
- **Por camada:** domain/, application/, adapter/ (agrupamento técnico)
- **Por feature:** user/, question/, vote/ com camadas dentro de cada (agrupamento de negócio)

## Decisão

Usaremos **Arquitetura Hexagonal com pacotes por camada**:

```java
com.devsanar.<servico>/
├── domain/              // Entidades, value objects, domain services, interfaces de porta
├── application/         // Casos de uso, application services, DTOs
├── adapter/
│   ├── in/
│   │   └── web/        // Controllers REST
│   └── out/
│       └── persistence/ // Repositories JPA, adaptadores de banco
└── config/              // Configuração Spring
```

**Princípios centrais:**
- **Camada de domínio:** Lógica de negócio pura, sem dependências de framework
- **Camada de aplicação:** Casos de uso orquestrando objetos de domínio, definindo interfaces de porta
- **Camada de adaptador:** Implementa portas com código específico de framework (Spring, JPA, Kafka)
- **Regra de dependência:** Dependências apontam para dentro (domínio tem zero dependências)

## Consequências

### Positivas
- **Testabilidade:** Lógica de domínio testada sem contexto Spring, bancos de dados ou dependências externas
- **Independência de framework:** Código de domínio não importa Spring, JPA ou Kafka
- **Limites claros:** Interfaces de porta tornam as dependências explícitas
- **Conformidade SOLID:** Inversão de dependência naturalmente imposta
- **Flexibilidade:** Fácil trocar adaptadores (ex: JPA → MongoDB, REST → GraphQL)
- **Valor no currículo:** Demonstra entendimento de padrões arquiteturais avançados

### Negativas
- **Mais arquivos:** Portas são interfaces separadas, mais indireção que camadas tradicionais
- **Overhead inicial:** Leva mais tempo para configurar comparado aos padrões do Spring Boot
- **Curva de aprendizado da equipe:** Requer entendimento do conceito de portas/adaptadores
- **Overkill para serviços simples:** Alguns serviços (api-gateway) não precisam dessa complexidade

### Neutras
- **Estrutura de pacotes:** Baseada em camadas mantém camadas relacionadas juntas, mais fácil de navegar que baseada em feature
- **Alinhamento com DDD:** Funciona bem com padrões táticos de Domain-Driven Design
- **Compatibilidade com Spring Boot:** Injeção de dependência do Spring funciona naturalmente com esse padrão

## Trade-offs: Pacotes por Camada vs por Feature

Escolhemos pacotes **por camada** por:
- **Serviços menores:** Cada microsserviço já tem escopo de feature (user-service faz usuários, não usuários + perguntas)
- **Foco em aprendizado:** Mais fácil entender "esta é a camada de domínio" quando é explícito
- **Consistência:** Todos os serviços seguem a mesma estrutura visível

**Baseado em feature** seria melhor para:
- Serviços monolíticos grandes com múltiplas features não relacionadas
- Equipes maiores onde features são de propriedade de pessoas diferentes

## Diretrizes de Implementação

**Regras da camada de domínio:**
- Sem anotações Spring (`@Component`, `@Service`)
- Sem anotações JPA (`@Entity` em modelos de domínio é discutível - usaremos para simplicidade mas mapearemos para objetos de domínio em casos complexos)
- Sem imports do Kafka
- Java/Kotlin puro, testável apenas com JUnit

**Camada de aplicação:**
- Define interfaces de porta (ex: interface `UserRepository`)
- Casos de uso podem usar `@Service` do Spring para wiring
- DTOs vivem aqui (entrada/saída para casos de uso)

**Camada de adaptador:**
- Implementa interfaces de porta
- Usa anotações de framework (`@RestController`, `@Repository`, `@KafkaListener`)
- Converte entre modelos de domínio e modelos específicos de framework

## Notas

Nem todos os serviços precisarão estritamente de arquitetura hexagonal:
- **api-gateway:** Roteamento simples, sem lógica de domínio → estrutura tradicional é adequada
- **notification-service:** Serviço fino, principalmente consumidor Kafka → hexagonal relaxada

A arquitetura é mais valiosa no **question-service** onde lógica de domínio complexa vive (votos, cálculos de reputação, regras de negócio).

Esta decisão suporta o objetivo do projeto de demonstrar padrões de nível de produção para vagas Java sênior.
