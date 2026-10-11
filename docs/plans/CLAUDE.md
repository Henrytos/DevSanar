# Guia de Planos de Implementação

Este documento define o padrão para criar e manter planos de implementação (Implementation Plans) no projeto DevSanar.

## O que é um Plano de Implementação?

Um plano de implementação documenta a estratégia detalhada para executar uma tarefa significativa do projeto. Serve como roteiro técnico entre a decisão arquitetural (ADR) e o código implementado.

## Quando Criar um Plano?

Crie um plano quando:
- Inicializar nova infraestrutura ou serviços
- Implementar features complexas que abrangem múltiplos componentes
- Realizar refatorações significativas
- Adicionar novos microsserviços ao ecossistema
- Integrar tecnologias ou serviços externos
- Executar migrações de dados ou banco de dados
- Implementar pipelines de CI/CD
- Configurar ambientes (staging, produção)

**Não crie plano para:**
- Features pequenas isoladas a um serviço
- Correções de bugs simples
- Mudanças de configuração menores
- Atualizações de dependências de rotina

## Estrutura do Plano

### Template Obrigatório

```markdown
# [Título Descritivo do Plano]

**Data:** YYYY-MM-DD  
**Status:** [Proposto | Em Execução | Concluído | Cancelado]  
**Objetivo:** [Resumo em uma frase do que será implementado]

## Contexto

[Explicar POR QUE este trabalho está sendo feito agora]

**Motivação:**
[Problema que resolve, necessidade de negócio, ou próximo passo no roadmap]

**Decisões já tomadas:**
- [Link para ADR-XXX relevante]
- [Link para ADR-YYY relevante]
- [Outras decisões ou constraints]

## Estrutura Final

[Diagrama, árvore de diretórios, ou descrição visual do estado final]

```
exemplo/
├── componente-1/
├── componente-2/
└── infraestrutura/
```

## Escopo de Implementação

### 1. [Componente/Tarefa Principal 1]
- [Item específico a implementar]
- [Item específico a implementar]
- [...]

**Dependências:**
- [Biblioteca X versão Y]
- [Serviço Z configurado]

**Detalhes técnicos:**
- [Configuração ou padrão específico]

### 2. [Componente/Tarefa Principal 2]
[Mesma estrutura acima]

### 3. [Componente/Tarefa Principal 3]
[Mesma estrutura acima]

## Arquivos Críticos

Liste os principais arquivos que serão criados ou modificados:

**Criar:**
- `caminho/para/arquivo1.ext` - Propósito
- `caminho/para/arquivo2.ext` - Propósito

**Modificar:**
- `caminho/para/arquivo3.ext` - O que muda

## Critérios de Aceitação

Lista verificável do que deve funcionar ao final:

✅ **[Categoria 1]:**
- [ ] Critério específico e testável 1
- [ ] Critério específico e testável 2

✅ **[Categoria 2]:**
- [ ] Critério específico e testável 3
- [ ] Critério específico e testável 4

## Verificação Final

Comandos ou passos para validar que a implementação está completa:

```bash
# Comando 1 e resultado esperado
comando-1

# Comando 2 e resultado esperado
comando-2
```

## Próximos Passos

O que vem DEPOIS deste plano ser concluído:
1. [Próxima tarefa ou plano]
2. [Próxima tarefa ou plano]

## Notas (opcional)

[Observações, riscos conhecidos, alternativas consideradas]

## Relacionados (opcional)

- ADRs: [ADR-XXX], [ADR-YYY]
- Outros planos: [link para plano relacionado]
- Issues: [#123], [#456]
```

## Convenções de Nomenclatura

### Número do Plano
- Formato: `XXX-titulo-descritivo.md` onde XXX é sequencial (001, 002, 003...)
- Começar do 001 e incrementar
- Ordenar cronologicamente (ordem de criação)

### Nome do Arquivo
- Formato: `XXX-titulo-kebab-case.md`
- Exemplo: `001-project-initialization.md`
- Exemplo: `002-user-service-jwt-implementation.md`
- Exemplo: `003-kafka-event-streaming-setup.md`

### Título do Plano
- Claro e descritivo
- Indica O QUE será implementado
- ✅ Bom: "Implementação de Autenticação JWT no User Service"
- ✅ Bom: "Setup de Infraestrutura Kafka para Eventos"
- ❌ Ruim: "Trabalho no backend"
- ❌ Ruim: "Melhorias gerais"

## Status do Plano

- **Proposto:** Plano criado mas implementação não iniciada
- **Em Execução:** Implementação ativa no momento
- **Concluído:** Todos os critérios de aceitação cumpridos
- **Cancelado:** Plano não será mais executado (documentar razão nas Notas)

## Escrita Clara

### Contexto
- Explique POR QUE este trabalho acontece agora
- Link para ADRs que estabeleceram as decisões arquiteturais
- Descreva o estado atual vs estado desejado

### Escopo
- Seja específico sobre O QUE será construído
- Organize por componentes lógicos
- Liste dependências e versões
- Inclua detalhes técnicos (estrutura de pastas, padrões, configurações)

### Critérios de Aceitação
- Devem ser testáveis e verificáveis
- Use checkboxes para rastrear progresso
- Organize por categoria
- Seja específico: ❌ "serviço funciona" → ✅ "endpoint /health retorna 200 OK"

### Verificação Final
- Comandos exatos para validar
- Inclua resultado esperado
- Pense em alguém validando sem você presente

## Relacionamento com ADRs

Planos IMPLEMENTAM decisões feitas em ADRs:

- **ADR decide:** "Usaremos arquitetura hexagonal" (ADR-004)
- **Plano implementa:** "Criar estrutura hexagonal em todos os 5 serviços" (Plan-001)

Se durante a execução do plano você descobrir que precisa de uma nova decisão arquitetural:
1. **Pause** a implementação
2. **Crie** um novo ADR documentando a decisão
3. **Atualize** o plano para referenciar o novo ADR
4. **Continue** a implementação

## Manutenção de Planos

### Atualizando Durante Implementação
- ✅ Marque checkboxes dos critérios de aceitação conforme progride
- ✅ Adicione notas sobre descobertas ou mudanças
- ✅ Atualize status: Proposto → Em Execução → Concluído
- ❌ Não apague seções, adicione notas se algo mudou

### Após Conclusão
- Marque status como "Concluído"
- Adicione data de conclusão nas Notas
- Mantenha o plano como referência histórica
- Se implementação divergiu significativamente, documente o que mudou

## Exemplos no Projeto

Veja planos existentes como referência:
- `001-project-initialization.md` - Scaffolding inicial completo do projeto

## Checklist para Revisar Plano

Antes de commitar um novo plano, verifique:

- [ ] Número sequencial correto (próximo disponível)
- [ ] Nome do arquivo segue padrão `XXX-titulo-kebab-case.md`
- [ ] Todos os campos obrigatórios preenchidos (Data, Status, Objetivo)
- [ ] Contexto explica POR QUE (não apenas O QUE)
- [ ] ADRs relacionados estão linkados
- [ ] Escopo detalhado por componente
- [ ] Critérios de aceitação são testáveis
- [ ] Verificação final tem comandos concretos
- [ ] Linguagem clara e objetiva (português)

## Integração com Claude Code

Quando o Claude entra no modo plan:

1. **Explorar** contexto do projeto e requisitos do usuário
2. **Perguntar** clarificações necessárias
3. **Criar** novo plano seguindo este template
4. **Numerar** sequencialmente (ler pasta plans/ para próximo número)
5. **Linkar** ADRs relevantes que justificam decisões
6. **Se nova decisão arquitetural surge:**
   - Criar ADR primeiro
   - Referenciar ADR no plano
7. **Apresentar** plano para aprovação do usuário
8. **Após aprovação:** Mudar status para "Em Execução" e começar implementação

## Estrutura de Diretórios

Planos vivem em `docs/plans/`:

```
docs/plans/
├── CLAUDE.md                           # Este guia
├── 001-project-initialization.md        # Plano 1
├── 002-user-service-jwt.md             # Plano 2
└── 003-kafka-integration.md            # Plano 3
```

## Organização por Fase

Para projetos grandes, considere prefixo por fase:

- `fase1-XXX-nome.md` - Fase 1 (Fundação)
- `fase2-XXX-nome.md` - Fase 2 (Distribuição)
- `fase3-XXX-nome.md` - Fase 3 (Produção)

Exemplo: `fase1-001-project-initialization.md`

## Dicas

- **Seja específico:** "Criar serviço" é vago. "Criar user-service com estrutura hexagonal, 5 endpoints REST e autenticação JWT" é específico.
- **Pense em execução:** Escreva pensando em você mesmo ou outra pessoa executando daqui a 3 meses.
- **Quebre tarefas grandes:** Se um componente parece muito complexo, talvez precise de seu próprio plano.
- **Link generosamente:** ADRs, issues, PRs, documentação externa.
- **Mantenha atualizado:** Durante implementação, atualize o plano se descobrir algo.

## Idioma

Todos os planos devem ser escritos em **português** para alinhamento com a equipe brasileira.
