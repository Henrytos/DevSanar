# ADR-002: Java 21 e Spring Boot 3.3.x

**Status:** Aceito  
**Data:** 2026-10-11  
**Decisores:** Henry

## Contexto

Precisamos selecionar versões de Java e Spring Boot para todos os microsserviços backend. A escolha impacta recursos de linguagem disponíveis, capacidades do framework, suporte de longo prazo e relevância no mercado.

**Opções disponíveis:**
- Java 17 LTS + Spring Boot 3.2.x (estável, amplamente adotado)
- Java 21 LTS + Spring Boot 3.3.x (LTS mais recente, recursos modernos)
- Java 11 LTS + Spring Boot 2.7.x (mais antigo, ainda suportado)

**Considerações de mercado:**
- Java 17 é atualmente o mais comum em ambientes corporativos
- Adoção do Java 21 está crescendo rapidamente, especialmente para projetos greenfield
- Spring Boot 3.x requer Java 17 mínimo (Jakarta EE, não javax)

## Decisão

Usaremos **Java 21 LTS** com **Spring Boot 3.3.x** para todos os microsserviços.

**Principais recursos aproveitados:**
- **Virtual Threads (Project Loom):** Concorrência leve para operações de I/O bloqueantes
- **Pattern Matching para switch:** Lógica de domínio mais limpa
- **Record Patterns:** Extração melhorada de dados de records
- **Sequenced Collections:** APIs de coleções melhores
- **Recursos do Spring Boot 3.3:** Observabilidade melhorada, RestClient, suporte a compilação nativa

## Consequências

### Positivas
- **Recursos modernos de linguagem:** Código mais limpo e expressivo (pattern matching, records, text blocks)
- **Virtual Threads:** Melhor utilização de recursos para serviços I/O-bound (banco de dados, Kafka, chamadas HTTP)
- **Suporte de longo prazo:** Java 21 LTS suportado até 2029
- **Relevância no currículo:** Demonstra conhecimento do ecossistema Java mais recente
- **Spring Boot 3.3:** Pronto para compilação nativa, métricas melhoradas, cliente REST moderno

### Negativas
- **Requisitos de deployment:** Ambiente de produção deve suportar Java 21 (Docker mitiga isso)
- **Curva de aprendizado:** Alguns recursos do Java 21 são novos e requerem aprendizado
- **Compatibilidade de bibliotecas:** Caso raro onde uma biblioteca suporta apenas versões antigas do Java (improvável para nossa stack)

### Neutras
- **CI/CD:** GitHub Actions suporta Java 21 nativamente
- **Suporte de IDE:** IntelliJ IDEA e VS Code suportam totalmente Java 21
- **Ecossistema Spring:** Todas as bibliotecas Spring Cloud compatíveis com Spring Boot 3.3.x

## Notas

Embora Java 17 + Spring Boot 3.2.x seria uma escolha mais segura para empregabilidade imediata, Java 21 demonstra pensamento progressivo e disposição para adotar ferramentas modernas. Virtual Threads são particularmente relevantes para microsserviços com altos tempos de espera de I/O (queries de banco, chamadas a APIs externas, operações Kafka).

A estratégia de deployment containerizado (Docker) elimina preocupações com versão da JVM em produção - cada serviço traz seu próprio runtime Java 21.
