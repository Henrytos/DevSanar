# ADR-003: Angular 22 para Frontend

**Status:** Aceito  
**Data:** 2026-10-11  
**Decisores:** Henry

## Contexto

Precisamos selecionar um framework frontend e versão para o SPA DevSanar. O frontend irá se comunicar com o API Gateway, lidar com autenticação (JWT) e fornecer uma UI responsiva para o fórum de Q&A.

**Opções de framework consideradas:**
- React (mais popular, grande ecossistema)
- Vue.js (curva de aprendizado suave, flexível)
- Angular (opinativo, pronto para enterprise)
- Svelte (emergente, framework compile-time)

**Opções de versão Angular:**
- Angular 16 (NgModules, estável)
- Angular 17 (componentes standalone por padrão, signals)
- Angular 18 (última estável, signals aprimorados)
- Angular 22 (cutting-edge, recursos mais recentes)

## Decisão

Usaremos **Angular 22** com componentes standalone e padrões modernos do Angular.

**Principais recursos:**
- **Componentes standalone:** Sem boilerplate de NgModules
- **Signals:** Gerenciamento de estado reativo integrado no framework
- **Sintaxe de fluxo de controle:** `@if`, `@for`, `@switch` modernos em templates
- **Carregamento diferido:** Lazy loading granular com `@defer`
- **DI melhorado:** Função inject para injeção de dependência mais limpa
- **TypeScript 5.x:** Recursos de linguagem mais recentes

## Consequências

### Positivas
- **Padrões modernos:** Componentes standalone reduzem significativamente o boilerplate
- **Signals:** Reatividade granular sem complexidade de RxJS para estado local
- **Type safety:** Integração completa com TypeScript com modo strict
- **Ferramentas CLI:** CLI `ng` poderoso para scaffolding, build, testes
- **Padrões enterprise:** Roteamento, formulários, cliente HTTP, utilitários de teste integrados
- **Component design:** Encaixe natural para abordagem de design system mencionada nos requisitos
- **Valor no currículo:** Demonstra conhecimento do ecossistema Angular mais recente

### Negativas
- **Curva de aprendizado:** Angular é mais opinativo que React/Vue
- **Tamanho do bundle:** Maior que algumas alternativas (mitigado por lazy loading)
- **Bleeding edge:** Angular 22 é muito recente - menos respostas no Stack Overflow para casos extremos
- **Volatilidade de versão:** Pode precisar atualizar se bugs forem encontrados

### Neutras
- **RxJS:** Ainda disponível para operações assíncronas (HTTP, WebSocket, estado complexo)
- **Testes:** Jasmine/Karma ou Jest - ferramentas de teste padrão funcionam
- **Bibliotecas UI:** Pode integrar com qualquer framework CSS (Tailwind escolhido para este projeto)

## Notas

Angular foi escolhido ao invés de React por várias razões:
1. **Estrutura:** Arquitetura opinativa ajuda a manter consistência em um SPA maior
2. **Padrão de services:** Alinha bem com arquitetura de microsserviços backend conceitualmente
3. **TypeScript-first:** Melhor type safety out of the box
4. **Framework completo:** Roteamento, formulários, HTTP, testes todos incluídos

Angular 22 especificamente (vs Angular 17/18) demonstra disposição para adotar ferramentas mais recentes e aprender novos padrões. Para um projeto de portfólio, isso mostra adaptabilidade.

A combinação de componentes standalone + signals representa as melhores práticas modernas do Angular e reduz a curva de aprendizado comparada à arquitetura mais antiga de NgModules.
