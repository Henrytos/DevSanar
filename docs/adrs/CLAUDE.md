# Guia de Registros de Decisões de Arquitetura (ADRs)

Este documento define o padrão para criar e manter Architecture Decision Records (ADRs) no projeto DevSanar.

## O que é um ADR?

Um ADR documenta uma decisão arquitetural significativa junto com seu contexto e consequências. Serve como registro histórico do porquê das decisões técnicas tomadas no projeto.

## Quando Criar um ADR?

Crie um ADR quando:
- Escolher tecnologias principais (linguagem, framework, banco de dados)
- Definir padrões arquiteturais (monorepo vs multi-repo, hexagonal, microservices)
- Tomar decisões que afetam múltiplos serviços ou o sistema como um todo
- Adotar estratégias de infraestrutura (Docker, Kubernetes, CI/CD)
- Estabelecer padrões de segurança, autenticação ou autorização
- Decidir sobre estruturas de dados ou protocolos de comunicação
- Mudar tecnologias ou arquiteturas existentes

**Não crie ADR para:**
- Implementações específicas de features
- Decisões locais a um único serviço sem impacto no resto do sistema
- Mudanças de configuração menores
- Correções de bugs

## Estrutura do ADR

### Template Obrigatório

```markdown
# ADR-XXX: [Título Descritivo Curto]

**Status:** [Proposto | Aceito | Depreciado | Substituído por ADR-YYY]  
**Data:** YYYY-MM-DD  
**Decisores:** [Nomes das pessoas envolvidas]

## Contexto

[Descrever o problema ou situação que motivou esta decisão]

**Forças em jogo:**
- [Força técnica, política, social ou de projeto 1]
- [Força técnica, política, social ou de projeto 2]
- [...]

**Opções consideradas:**
1. [Opção 1 com breve descrição]
2. [Opção 2 com breve descrição]
3. [Opção 3 com breve descrição]

## Decisão

[Declaração clara da decisão tomada - o QUE foi decidido]

**Justificativa:**
[POR QUE esta opção foi escolhida sobre as outras]

**Detalhes de implementação (se aplicável):**
[Aspectos técnicos específicos da decisão]

## Consequências

### Positivas
- [Benefício 1]
- [Benefício 2]
- [...]

### Negativas
- [Trade-off ou limitação 1]
- [Trade-off ou limitação 2]
- [...]

### Neutras
- [Aspecto neutro 1]
- [Aspecto neutro 2]
- [...]

## Alternativas Rejeitadas (opcional)

**[Nome da alternativa]:**
- Rejeitada porque [razão específica]

## Notas (opcional)

[Contexto adicional, links para recursos, observações importantes]
```

## Convenções de Nomenclatura

### Número do ADR
- Formato: `ADR-XXX` onde XXX é sequencial (001, 002, 003...)
- Começar do 001 e incrementar
- Não reutilizar números de ADRs depreciados

### Nome do Arquivo
- Formato: `XXX-titulo-kebab-case.md`
- Exemplo: `001-arquitetura-monorepo.md`
- Exemplo: `005-autenticacao-jwt.md`

### Título do ADR
- Claro e descritivo
- Máximo 60 caracteres
- Indica o ASSUNTO, não a decisão
- ✅ Bom: "Arquitetura Monorepo"
- ✅ Bom: "Autenticação JWT"
- ❌ Ruim: "Decisão sobre repositórios"
- ❌ Ruim: "Como vamos fazer autenticação"

## Status do ADR

- **Proposto:** ADR criado mas ainda em discussão
- **Aceito:** Decisão aprovada e implementada/em implementação
- **Depreciado:** Decisão não mais válida mas mantida para histórico
- **Substituído por ADR-XXX:** Decisão foi revisada, apontar para nova ADR

## Escrita Clara

### Contexto
- Explique o problema sem assumir conhecimento prévio
- Liste as forças que influenciam a decisão (técnicas, organizacionais, constraints)
- Apresente pelo menos 2-3 alternativas consideradas

### Decisão
- Uma frase clara com a decisão: "Usaremos X para Y"
- Explique POR QUE, não apenas O QUE
- Inclua detalhes técnicos relevantes

### Consequências
- Seja honesto sobre trade-offs
- Liste tanto benefícios quanto limitações
- Ajuda futuras revisões da decisão

## Manutenção de ADRs

### Atualizando ADRs Existentes
- Se a decisão muda: NÃO edite o ADR original
- Crie um NOVO ADR com a nova decisão
- Marque o ADR antigo como "Depreciado" ou "Substituído por ADR-XXX"
- Isso mantém o histórico intacto

### Linking ADRs
- Referencie ADRs relacionados no texto: `(ver ADR-001)`
- No CLAUDE.md principal, mantenha lista atualizada de todos os ADRs

## Exemplos no Projeto

Veja os ADRs existentes como referência:
- `001-arquitetura-monorepo.md` - Decisão de estrutura de repositório
- `002-versoes-java-spring.md` - Escolha de versões de tecnologias
- `004-arquitetura-hexagonal.md` - Padrão arquitetural interno
- `005-autenticacao-jwt.md` - Estratégia de autenticação

## Checklist para Revisar ADR

Antes de commitar um novo ADR, verifique:

- [ ] Número sequencial correto (próximo disponível)
- [ ] Nome do arquivo segue padrão `XXX-titulo-kebab-case.md`
- [ ] Todos os campos obrigatórios preenchidos (Status, Data, Decisores)
- [ ] Contexto explica claramente o problema
- [ ] Pelo menos 2 alternativas foram consideradas
- [ ] Decisão é clara e justificada
- [ ] Consequências positivas E negativas listadas
- [ ] Linguagem clara e objetiva (português)
- [ ] ADR adicionado à lista no `CLAUDE.md` principal

## Integração com Claude Code

Quando o Claude estiver no modo plan e identificar uma nova decisão arquitetural:

1. **Detectar** se a decisão se qualifica como ADR (afeta múltiplos serviços, escolha de tecnologia, padrão arquitetural)
2. **Criar** novo ADR seguindo este template
3. **Numerar** sequencialmente (ler pasta adrs/ para encontrar próximo número)
4. **Atualizar** lista de ADRs no `CLAUDE.md` principal
5. **Referenciar** o ADR no plano de implementação

## Dicas

- **Seja conciso:** ADRs devem ser lidos rapidamente. Evite texto excessivo.
- **Seja honesto:** Documente trade-offs reais, não idealize a decisão
- **Seja específico:** "Melhor performance" é vago. "30% menos latência em queries" é específico.
- **Mantenha histórico:** Nunca delete ADRs, apenas deprecie
- **Link generosamente:** Referencie outros ADRs e documentação relevante

## Idioma

Todos os ADRs devem ser escritos em **português** para alinhamento com a equipe brasileira.
