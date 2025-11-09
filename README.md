# 🚀 Monitoramento DevOps

Ambiente completo de monitoramento desenvolvido em **TypeScript** com **Docker**, **Prometheus**, **Alertmanager** e **Grafana**.

## 🎯 Objetivos

Demonstrar práticas essenciais de DevOps:

- Containerização e padronização do ambiente
- Exposição e coleta de métricas
- Alerta automatizado baseado em séries temporais
- Observabilidade e visualização em dashboards
- Automação da infraestrutura com Makefile/Docker Compose



## 🛠️ Tecnologias Utilizadas

| Tecnologia | Função |
|-----------|--------|
| **Node.js / TypeScript** | Aplicação principal |
| **Express** | Servidor HTTP |
| **prom-client** | Exportação de métricas para Prometheus |
| **Docker** | Containerização e ambiente isolado |
| **Prometheus** | Coleta e armazenamento de métricas |
| **Alertmanager** | Gestão e envio de alertas |
| **Grafana** | Dashboards e visualização |


## 🏗️ Arquitetura

```

┌─────────────────────────────────────────────────────────────────┐
│                        Docker Network (monitoring)               │
│                                                                  │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     │
│  │ Aplicação    │ --> │ Prometheus   │ --> │ Alertmanager │     │
│  │ Node.js:3000 │     │ :9090        │     │ :9093        │     │
│  │ /metrics     │ <---- Scrape (5s)  │     │ Webhook      │     │
│  └──────────────┘     └──────────────┘     └──────────────┘     │
│         │                         │                              │
│         └────────────────────────▶│ Grafana :3001                │
│                                   │ Dashboards sobre Prometheus  │
└─────────────────────────────────────────────────────────────────┘

````


## 🔧 Componentes

### **1) Aplicação Node.js (`app`)**
- Porta: **3000**
- Endpoints principais:

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/` | Página inicial |
| GET | `/metrics` | Métricas para Prometheus |
| GET | `/simulate/error` | Simula erro HTTP |
| GET | `/simulate/slow` | Simula requisição lenta |
| GET | `/simulate/users` | Simula pico de usuários |
| GET | `/simulate/memory` | Simula alto uso de memória |
| POST | `/webhook` | Recebe alertas |

- Métricas expostas:
  - `http_requests_total`
  - `app_errors_total`
  - `app_active_users`
  - `app_memory_usage_bytes`


### **2) Prometheus (`prometheus`)**
- Porta: **9090**
- Scrape em `/metrics` a cada **5s**
- Avaliação de alertas a cada **15s**
- Armazena métricas históricas para visualização e análise


### **3) Alertmanager (`alertmanager`)**
- Porta: **9093**
- Agrupa, roteia e envia alertas
- Envia notificações para: `http://app:3000/webhook`


### **4) Grafana (`grafana`)**
- Porta: **3001**
- Credenciais padrão: `admin / admin`
- Datasource Prometheus já configurado


## 🚨 Sistema de Alertas

| Alerta | Severidade | Condição | Duração |
|--------|-----------|----------|---------|
| **HighErrorRate** | warning | Erros > 0.5/s | 30s |
| **SlowRequests** | warning | P95 > 1s | 1 min |
| **HighActiveUsers** | info | > 150 usuários | 30s |
| **HighMemoryUsage** | warning | > 100MB de RAM | 1 min |
| **ApplicationDown** | critical | App sem resposta | 30s |


## ▶️ Como Executar

### **Opção 1: Via Makefile (Recomendado)**

| Comando | Ação |
|--------|------|
| `make up` | Sobe o ambiente |
| `make down` | Para tudo |
| `make restart` | Reinicia |
| `make logs` | Logs em tempo real |
| `make status` | Mostra status |
| `make clean` | Remove containers/volumes |

### **Opção 2: Docker Compose**

```sh
git clone <url-do-repositorio>
cd trabalho-pratico-TMS
docker-compose up -d --build
````

Acesse:

* App: [http://localhost:3000](http://localhost:3000)
* Prometheus: [http://localhost:9090](http://localhost:9090)
* Alertmanager: [http://localhost:9093](http://localhost:9093)
* Grafana: [http://localhost:3001](http://localhost:3001)


## 🧪 Testes de Alertas

| Comando              | Gatilho             |
| -------------------- | ------------------- |
| `make test-error`    | Taxa de erro        |
| `make test-slow`     | Requisição lenta    |
| `make test-users`    | Pico de usuários    |
| `make test-memory`   | Alto uso de memória |
| `make test-app-down` | Queda da aplicação  |
| `make test-all`      | Dispara todos       |


## 📁 Estrutura do Projeto

```
trabalho-pratico-TMS/
├── app/
│   ├── src/index.ts
│   ├── Dockerfile
│   └── package.json
├── prometheus/
│   ├── prometheus.yml
│   └── alerts.yml
├── alertmanager/
│   └── alertmanager.yml
├── docker-compose.yml
├── Makefile
└── README.md
```


## 👥 Equipe

Projeto desenvolvido para a disciplina **Teste e Manutenção de Software — PUC Minas**:

* Arthur Felipe Parreiras
* Arthur Santos Bezerra
* Élder Vanderlei Coleta de Freitas
* Gabriel Rodrigues Martins
* Humberto Roosevelt Figueredo Junior
* Ian Martins Rosa
* Marcos Vinicius dos Reis Santos
* Matheus Felipe Coelho Rodrigues
