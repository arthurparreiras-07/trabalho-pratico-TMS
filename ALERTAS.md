# 🚨 Documentação de Alertas

Este documento descreve todos os alertas configurados no sistema.

## Alertas Configurados

### 1. HighErrorRate (⚠️ Warning)

- **Descrição**: Taxa de erros alta detectada
- **Condição**: Mais de 0.5 erros por segundo
- **Duração**: 30 segundos
- **Como testar**:
  ```bash
  make test-error
  # ou
  for i in {1..10}; do curl http://localhost:3000/simulate/error; sleep 1; done
  ```

### 2. SlowRequests (⚠️ Warning)

- **Descrição**: Requisições lentas detectadas
- **Condição**: 95% das requisições levando mais de 1 segundo
- **Duração**: 1 minuto
- **Como testar**:
  ```bash
  make test-slow
  # ou
  curl http://localhost:3000/simulate/slow
  ```

### 3. HighActiveUsers (ℹ️ Info)

- **Descrição**: Número alto de usuários ativos
- **Condição**: Mais de 150 usuários ativos
- **Duração**: 30 segundos
- **Como testar**:
  ```bash
  make test-users
  # ou
  curl http://localhost:3000/simulate/users
  ```

### 4. HighMemoryUsage (⚠️ Warning)

- **Descrição**: Uso alto de memória
- **Condição**: Mais de 100MB de memória em uso
- **Duração**: 1 minuto
- **Como testar**:
  ```bash
  curl http://localhost:3000/simulate/memory
  ```

### 5. ApplicationDown (🔴 Critical)

- **Descrição**: Aplicação fora do ar
- **Condição**: Aplicação não responde
- **Duração**: 30 segundos
- **Como testar**:
  ```bash
  docker-compose stop app
  ```

## Visualizando Alertas

1. **Alertmanager UI**: http://localhost:9093
2. **Prometheus Alerts**: http://localhost:9090/alerts
3. **Logs da Aplicação**: Os alertas enviados via webhook aparecem nos logs

## Webhook

Os alertas são enviados via webhook para a aplicação em:

- **Endpoint**: `POST http://app:3000/webhook`
- **Logs**: Verifique com `docker-compose logs app`
