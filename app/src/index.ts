import express, { Request, Response } from "express";
import { register, Counter, Histogram, Gauge } from "prom-client";

const app = express();
const PORT = 3000;

// ======================================
// 📊 MÉTRICAS PROMETHEUS
// ======================================

// Contador de requisições HTTP
const httpRequestsTotal = new Counter({
  name: "http_requests_total",
  help: "Total de requisições HTTP recebidas",
  labelNames: ["method", "route", "status"],
});

// Histograma de duração das requisições
const httpRequestDuration = new Histogram({
  name: "http_request_duration_seconds",
  help: "Duração das requisições HTTP em segundos",
  labelNames: ["method", "route"],
  buckets: [0.1, 0.5, 1, 2, 5],
});

// Gauge para simular uso de memória
const memoryUsage = new Gauge({
  name: "app_memory_usage_bytes",
  help: "Uso de memória da aplicação em bytes",
});

// Contador de erros
const errorsTotal = new Counter({
  name: "app_errors_total",
  help: "Total de erros da aplicação",
  labelNames: ["type"],
});

// Gauge para usuários ativos (simulado)
const activeUsers = new Gauge({
  name: "app_active_users",
  help: "Número de usuários ativos no sistema",
});

// ======================================
// 🔧 MIDDLEWARE DE MONITORAMENTO
// ======================================

// Middleware para parsing de JSON
app.use(express.json());

app.use((req: Request, res: Response, next) => {
  const start = Date.now();

  res.on("finish", () => {
    const duration = (Date.now() - start) / 1000;

    httpRequestsTotal
      .labels(req.method, req.path, res.statusCode.toString())
      .inc();
    httpRequestDuration.labels(req.method, req.path).observe(duration);
  });

  next();
});

// ======================================
// 🛣️ ROTAS DA APLICAÇÃO
// ======================================

// Página inicial
app.get("/", (req: Request, res: Response) => {
  res.json({
    message: "🚀 DevOps Monitoring Application",
    status: "running",
    timestamp: new Date().toISOString(),
    endpoints: {
      metrics: "/metrics",
      health: "/health",
      simulate: "/simulate/:scenario",
    },
  });
});

// Health check
app.get("/health", (req: Request, res: Response) => {
  const healthStatus = {
    status: "healthy",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: process.memoryUsage(),
  };

  res.json(healthStatus);
});

// Endpoint de métricas para Prometheus
app.get("/metrics", async (req: Request, res: Response) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

// Webhook para receber alertas do Alertmanager
app.post("/webhook", (req: Request, res: Response) => {
  const alerts = req.body;
  console.log("\n🚨 ALERTA RECEBIDO DO ALERTMANAGER:");
  console.log(JSON.stringify(alerts, null, 2));
  res.status(200).json({ status: "received" });
});

// Simular diferentes cenários
app.get("/simulate/:scenario", (req: Request, res: Response) => {
  const { scenario } = req.params;

  switch (scenario) {
    case "success":
      activeUsers.set(Math.floor(Math.random() * 100) + 50);
      res.json({ message: "✅ Operação bem-sucedida", scenario });
      break;

    case "slow":
      // Simula requisição lenta
      setTimeout(() => {
        res.json({ message: "🐌 Operação lenta", scenario, delay: "2s" });
      }, 2000);
      break;

    case "error":
      errorsTotal.labels("simulated").inc();
      res.status(500).json({
        message: "❌ Erro simulado",
        scenario,
        error: "Internal Server Error",
      });
      break;

    case "memory":
      // Simula uso de memória
      const used = process.memoryUsage().heapUsed;
      memoryUsage.set(used);
      res.json({
        message: "💾 Uso de memória registrado",
        scenario,
        memoryUsed: `${(used / 1024 / 1024).toFixed(2)} MB`,
      });
      break;

    case "users":
      // Simula pico de usuários (pode gerar alerta)
      const users = Math.floor(Math.random() * 200) + 100;
      activeUsers.set(users);
      res.json({
        message: "👥 Usuários ativos atualizados",
        scenario,
        activeUsers: users,
      });
      break;

    default:
      res.status(400).json({
        message: "⚠️ Cenário desconhecido",
        availableScenarios: ["success", "slow", "error", "memory", "users"],
      });
  }
});

// ======================================
// 📈 ATUALIZAÇÃO PERIÓDICA DE MÉTRICAS
// ======================================

setInterval(() => {
  // Atualiza uso de memória a cada 10 segundos
  memoryUsage.set(process.memoryUsage().heapUsed);

  // Simula variação de usuários ativos
  const currentUsers = Math.floor(Math.random() * 50) + 20;
  activeUsers.set(currentUsers);
}, 10000);

// ======================================
// 🚀 INICIALIZAÇÃO DO SERVIDOR
// ======================================

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════╗
║  🚀 DevOps Monitoring App Running    ║
╚═══════════════════════════════════════╝

📍 Server: http://localhost:${PORT}
📊 Metrics: http://localhost:${PORT}/metrics
❤️  Health: http://localhost:${PORT}/health

🎯 Cenários disponíveis:
   /simulate/success - Operação normal
   /simulate/slow    - Requisição lenta
   /simulate/error   - Gerar erro
   /simulate/memory  - Registrar memória
   /simulate/users   - Simular usuários
`);
});
