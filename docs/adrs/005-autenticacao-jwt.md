# ADR-005: Autenticação Baseada em JWT

**Status:** Aceito  
**Data:** 2026-10-11  
**Decisores:** Henry

## Contexto

A plataforma DevSanar requer autenticação segura entre múltiplos microsserviços. Usuários autenticam uma vez e acessam recursos através de diferentes serviços (perguntas, reputação, notificações).

**Estratégias de autenticação consideradas:**

1. **JWT (JSON Web Tokens):** Tokens stateless emitidos pelo user-service, validados pelo API Gateway
2. **Baseada em sessão:** Sessões server-side no Redis, ID de sessão no cookie
3. **OAuth2 com provedor externo:** Delegar para OAuth do Google/GitHub
4. **Keycloak/Auth0:** Serviço dedicado de provedor de identidade

**Variantes de JWT:**
- **JWT puro:** Implementação customizada com Spring Security + biblioteca jjwt
- **Spring Security OAuth2 Resource Server:** Validação JWT OAuth2 padrão
- **Firebase Auth:** Autenticação gerenciada do Google

## Decisão

Usaremos **autenticação JWT pura** com o seguinte fluxo:

1. **user-service** emite tokens JWT em login bem-sucedido
2. **API Gateway** valida JWT em cada request, rejeita tokens inválidos
3. **Serviços internos** confiam no Gateway, não revalidam (JWT já verificado)

**Estrutura JWT:**
```json
{
  "sub": "user-id",
  "username": "john.doe",
  "roles": ["USER", "ADMIN"],
  "iat": 1234567890,
  "exp": 1234571490
}
```

**Implementação:**
- Biblioteca: `jjwt` (io.jsonwebtoken:jjwt-api)
- Algoritmo: HS256 (HMAC-SHA256) com secret compartilhado
- Tempo de vida do token: 15 minutos (access token), 7 dias (refresh token)
- Armazenamento: Cliente armazena token em memória ou cookie httpOnly
- Mecanismo de refresh: Endpoint separado `/auth/refresh`

## Consequências

### Positivas
- **Stateless:** Não requer armazenamento de sessão, escala horizontalmente facilmente
- **Performance:** Sem lookup de banco em cada request (diferente de baseada em sessão)
- **Amigável a microsserviços:** Token contém contexto do usuário, serviços não precisam chamar user-service
- **Padrão:** JWT é padrão da indústria, bem documentado
- **Valor de aprendizado:** Demonstra entendimento de autenticação stateless
- **Arquitetura simples:** Sem dependência de serviço de auth externo

### Negativas
- **Revogação de token:** Não pode invalidar tokens antes da expiração (mitigado por expiração curta)
- **Gerenciamento de secret:** Secret compartilhado deve ser distribuído com segurança ao API Gateway
- **Tamanho do token:** JWT em cada request adiciona ~500 bytes (aceitável para REST)
- **Sem MFA integrado:** Precisaria de implementação customizada
- **Ataques de replay:** Requer HTTPS em produção

### Neutras
- **Cache Redis:** Pode cachear detalhes do usuário para evitar lookups repetidos de banco
- **Refresh tokens:** Tokens de vida mais longa separados para renovação contínua
- **Requisito HTTPS:** Deve usar TLS em produção (já planejado)

## Considerações de Segurança

**Mitigações implementadas:**
1. **Expiração curta:** Tokens de acesso de 15 minutos limitam janela para tokens roubados
2. **Rotação de refresh token:** Refresh tokens são de uso único
3. **Apenas HTTPS:** Tokens nunca transmitidos por HTTP puro em produção
4. **Cookies httpOnly:** Se usar cookies, prevenir acesso XSS
5. **Rotação de secret:** Documentar processo para rotacionar secret de assinatura JWT

**Melhorias futuras:**
- Blacklist de tokens no Redis para logout forçado
- Validação baseada em IP
- Fingerprinting de dispositivo
- Autenticação multifator (TOTP)

## Notas de Implementação

**Responsabilidades do user-service:**
- Gerar JWT em login bem-sucedido (username/password validados contra banco)
- Validar refresh tokens
- Fornecer endpoints `/auth/login`, `/auth/refresh`, `/auth/logout`
- Armazenar hashes de senha com bcrypt (fator de custo 12)

**Responsabilidades do api-gateway:**
- Extrair JWT do header Authorization (`Bearer <token>`)
- Validar assinatura com secret compartilhado
- Extrair contexto do usuário (ID do usuário, roles)
- Encaminhar contexto do usuário para serviços internos via headers (X-User-Id, X-User-Roles)
- Retornar 401 Unauthorized para tokens inválidos/expirados

**Serviços internos:**
- Confiar completamente no API Gateway (pressuposição de rede interna)
- Ler contexto do usuário dos headers
- NÃO realizar autenticação eles mesmos

## Alternativas Rejeitadas

**Autenticação baseada em sessão:**
- Rejeitada porque requer estado compartilhado (store de sessão Redis)
- Mais difícil escalar horizontalmente
- Força API Gateway a fazer chamada Redis em cada request

**OAuth2 com provedor externo:**
- Overkill para este projeto
- Adiciona dependência externa
- Reduz oportunidade de aprendizado (delegar auth ao invés de implementar)

**Keycloak/Auth0:**
- Muito pesado para um projeto de aprendizado
- Obscurece internals de autenticação
- Valioso em produção, mas não demonstra entendimento

## Notas

Esta decisão se alinha com práticas modernas de microsserviços enquanto permanece simples o suficiente para implementar e entender completamente. A abordagem JWT é prevalente em vagas reais de backend Java e demonstra consciência de segurança.

Migração futura para OAuth2 Resource Server ou Keycloak é direta se necessário.
