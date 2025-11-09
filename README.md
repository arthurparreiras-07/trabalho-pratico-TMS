# 🚀 Monitoramento DevOps

Sistema de monitoramento DevOps desenvolvido em TypeScript com Docker, Prometheus, Alertmanager e Grafana.

## 🎯 Objetivos

Demonstrar práticas DevOps fundamentais:
- ✅ Containerização com Docker
- ✅ Monitoramento com Prometheus
- ✅ Alertas automatizados
- ✅ Observabilidade e métricas
- ✅ Automação de infraestrutura

## 🛠️ Tecnologias Utilizadas

- **TypeScript/Node.js**: Aplicação backend
- **Express**: Framework web
- **Prom-client**: Cliente Prometheus para Node.js
- **Docker**: Containerização
- **Prometheus**: Sistema de monitoramento
- **Alertmanager**: Gerenciamento de alertas
- **Grafana**: Visualização de métricas

## 🏗️ Arquitetura do Sistema

O projeto utiliza uma arquitetura baseada em microserviços containerizados que se comunicam através de uma rede Docker personalizada:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network                            │
│                         (monitoring)                             │
│                                                                  │
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐  │
│  │  Aplicação   │────▶│  Prometheus   │────▶│ Alertmanager │  │
│  │  Node.js     │      │              │      │              │  │
│  │  :3000       │      │    :9090     │      │    :9093     │  │
│  │              │      │              │      │              │  │
│  │ /metrics     │◀─────│  Scraping    │      │   Webhook    │  │
│  │ /simulate/*  │      │  (5s)        │      │              │  │
│  └──────────────┘      └──────────────┘      └──────────────┘  │
│         │                     │                      │          │
│         │                     │                      │          │
│         │              ┌──────────────┐             │          │
│         └─────────────▶│   Grafana    │◀────────────┘          │
│                        │   :3001      │                        │
│                        │              │                        │
│                        │ Dashboards   │                        │
│                        └──────────────┘                        │
└─────────────────────────────────────────────────────────────────┘
```

### Componentes da Arquitetura

#### 1. **Aplicação Node.js** (\`app\`)
- **Função**: Expõe métricas e endpoints de simulação
- **Porta**: 3000
- **Endpoints principais**:
  - \`GET /metrics\` - Métricas no formato Prometheus
  - \`GET /simulate/error\` - Simula erro HTTP 500
  - \`GET /simulate/slow\` - Simula requisição lenta (2s)
  - \`GET /simulate/users\` - Simula pico de usuários
  - \`GET /simulate/memory\` - Simula alto uso de memória
  - \`POST /webhook\` - Recebe notificações do Alertmanager
- **Métricas exportadas**:
  - \`http_requests_total\` - Total de requisições HTTP
  - \`app_errors_total\` - Total de erros
  - \`app_active_users\` - Usuários ativos no momento
  - \`app_memory_usage_bytes\` - Uso de memória em bytes

#### 2. **Prometheus** (\`prometheus\`)
- **Função**: Coleta e armazena métricas de séries temporais
- **Porta**: 9090
- **Configurações**:
  - Intervalo de scrape: **5 segundos**
  - Intervalo de avaliação: **15 segundos**
  - Retenção de dados: 15 dias
- **Responsabilidades**:
  - Coleta métricas da aplicação a cada 5s
  - Avalia regras de alertas definidas em \`prometheus/alerts.yml\`
  - Envia alertas disparados para o Alertmanager

#### 3. **Alertmanager** (\`alertmanager\`)
- **Função**: Gerencia, agrupa e roteia alertas
- **Porta**: 9093
- **Recursos**:
  - Deduplicação de alertas
  - Agrupamento por severidade
  - Roteamento para webhooks
  - Silenciamento manual de alertas
- **Notificações**: Envia alertas via webhook para \`http://app:3000/webhook\`

#### 4. **Grafana** (\`grafana\`)
- **Função**: Visualização de métricas e dashboards
- **Porta**: 3001
- **Credenciais padrão**: \`admin\` / \`admin\`
- **Configuração**: Prometheus pré-configurado como datasource

### Fluxo de Monitoramento

1. **Coleta de Métricas**:
   - Aplicação expõe métricas em \`/metrics\`
   - Prometheus coleta (scrape) as métricas a cada 5 segundos

2. **Avaliação de Alertas**:
   - Prometheus avalia regras de alerta a cada 15 segundos
   - Se uma condição for atingida, o alerta é disparado

3. **Notificação**:
   - Alerta é enviado ao Alertmanager
   - Alertmanager agrupa e roteia para o webhook
   - Aplicação recebe notificação via POST \`/webhook\`

4. **Visualização**:
   - Grafana consulta métricas do Prometheus
   - Dashboards exibem gráficos em tempo real

## 🚀 Como Executar

### Opção 1: Usando Makefile (Recomendado)

O projeto inclui um Makefile com comandos automatizados:

\`\`\`bash
# Ver todos os comandos disponíveis
make help

# Iniciar todos os containers
make up

# Parar todos os containers
make down

# Ver logs em tempo real
make logs

# Reiniciar todos os serviços
make restart

# Limpar containers e volumes
make clean

# Ver status dos containers
make status
\`\`\`

### Opção 2: Usando Docker Compose Diretamente

1. **Clone o repositório:**
\`\`\`bash
git clone <url-do-repositorio>
cd trabalho-pratico-TMS
\`\`\`

2. **Inicie os containers:**
\`\`\`bash
docker-compose up -d --build
\`\`\`

3. **Verifique se os containers estão rodando:**
\`\`\`bash
docker-compose ps
\`\`\`

4. **Acesse as interfaces:**
- Aplicação: http://localhost:3000
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Grafana: http://localhost:3001 (admin/admin)

### Primeiro Acesso

1. **Verifique a aplicação:**
\`\`\`bash
curl http://localhost:3000/metrics
\`\`\`

2. **Acesse o Prometheus:**
   - Abra http://localhost:9090
   - Vá em **Status** → **Targets** para ver os scrape targets
   - Vá em **Alerts** para ver as regras de alertas

3. **Configure o Grafana:**
   - Acesse http://localhost:3001
   - Login: \`admin\` / \`admin\`
   - O Prometheus já está configurado como datasource
   - Crie dashboards personalizados ou importe templates

## 🚨 Sistema de Alertas

O projeto possui 5 alertas configurados:

| Alerta | Severidade | Condição | Duração |
|--------|-----------|----------|---------|
| **HighErrorRate** | warning | Taxa de erros > 0.5/s | 30s |
| **SlowRequests** | warning | P95 > 1 segundo | 1min |
| **HighActiveUsers** | info | Usuários > 150 | 30s |
| **HighMemoryUsage** | warning | Memória > 100MB | 1min |
| **ApplicationDown** | critical | App offline | 30s |

### Testar Alertas

Use os comandos do Makefile para simular cenários:

\`\`\`bash
# Testar TODOS os alertas sequencialmente
make test-all

# Testar alertas individuais
make test-error      # Dispara HighErrorRate
make test-slow       # Dispara SlowRequests
make test-users      # Dispara HighActiveUsers
make test-memory     # Dispara HighMemoryUsage
make test-app-down   # Dispara ApplicationDown

# Verificar alertas ativos
make check-alerts

# Monitorar alertas em tempo real
make watch-alerts

# Monitorar métricas em tempo real
make watch-metrics
\`\`\`

## 📊 Endpoints da Aplicação

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | \`/\` | Página inicial |
| GET | \`/metrics\` | Métricas Prometheus |
| GET | \`/simulate/error\` | Simula erro HTTP 500 |
| GET | \`/simulate/slow\` | Simula requisição lenta (2s) |
| GET | \`/simulate/users\` | Simula 200 usuários ativos |
| GET | \`/simulate/memory\` | Registra uso de memória |
| POST | \`/webhook\` | Recebe alertas do Alertmanager |

## 📁 Estrutura do Projeto

\`\`\`
trabalho-pratico-TMS/
├── app/                      # Aplicação Node.js
│   ├── src/
│   │   └── index.ts         # Código principal
│   ├── Dockerfile           # Build da aplicação
│   ├── package.json
│   └── tsconfig.json
├── prometheus/              # Configurações Prometheus
│   ├── prometheus.yml      # Config principal
│   └── alerts.yml          # Regras de alertas
├── alertmanager/           # Configurações Alertmanager
│   └── alertmanager.yml   # Rotas e receivers
├── docker-compose.yml     # Orquestração dos containers
├── Makefile              # Comandos automatizados
└── README.md            # Documentação

\`\`\`

## 📚 Recursos Adicionais

- [Documentação Prometheus](https://prometheus.io/docs/)
- [Documentação Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Documentação Grafana](https://grafana.com/docs/)
- [Prom-client (Node.js)](https://github.com/siimon/prom-client)

## 👥 Equipe

Projeto desenvolvido para a disciplina de Teste e Manutenção de Software - PUC Minas
- Arthur Felipe Parreiras
- Arthur Santos Bezerra
- Élder Vanderlei Coleta de Freitas
- Gabriel Rodrigues Martins
- Humberto Roosevelt Figueredo Junior
- Ian Martins Rosa
- Marcos Vinicius dos Reis Santos
- Matheus Felipe Coelho Rodrigues
