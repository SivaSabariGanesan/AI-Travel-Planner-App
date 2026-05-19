# Monitoring Stack Setup - Prometheus, Loki & Grafana

This directory contains the monitoring infrastructure for the Travel Planner backend using Prometheus for metrics, Loki for logs, and Grafana for visualization.

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Travel Planner Backend                 │
│                   (Express.js + prom-client)              │
│                     Exposes /metrics                      │
└──────────────────────────────────────────────────────────┘
                              │
                              ▼
            ┌─────────────────────────────────┐
            │      Prometheus (9090)          │
            │   Scrapes metrics every 30s     │
            │  Stores time-series data (30d)  │
            └─────────────────────────────────┘
                              │
                    ┌─────────┴──────────┐
                    ▼                    ▼
        ┌──────────────────┐  ┌──────────────────┐
        │   Loki (3100)    │  │  Grafana (3000)  │
        │  Log Aggregation │  │  Visualization   │
        └──────────────────┘  └──────────────────┘
                                      ▲
                                      │
                              (Queries both)
```

## Quick Start

### Prerequisites
- Docker & Docker Compose installed
- Backend running on `localhost:5000`

### 1. Start the Monitoring Stack

```bash
cd d:\TravelPlanner_APP
docker-compose -f docker-compose.monitoring.yml up -d
```

This will start:
- **Prometheus** on `http://localhost:9090` - Metrics collection
- **Loki** on `http://localhost:3100` - Log aggregation
- **Promtail** - Log shipper
- **Grafana** on `http://localhost:3000` - Dashboards & visualization

### 2. Install Backend Dependencies

```bash
cd backend
npm install
```

This installs the `prom-client` package for Prometheus metrics.

### 3. Start the Backend with Metrics

```bash
npm run dev
```

The backend will now expose metrics at `http://localhost:5000/metrics`

### 4. Access Grafana

- **URL**: `http://localhost:3000`
- **Username**: `admin`
- **Password**: `admin`

Change the password on first login (Settings → Admin → Users)

## Monitoring Components

### Prometheus Configuration
File: `monitoring/prometheus.yml`

- Scrapes backend metrics every 30 seconds
- Retention: 30 days
- Storage location: `prometheus_data` volume

**Metrics exposed by backend:**
- `http_requests_total` - Total HTTP requests by method, path, status
- `http_request_duration_seconds` - Request latency distribution
- `http_request_duration_seconds_bucket` - Latency buckets for percentile calculations
- `process_*` - Node.js process metrics (memory, uptime, CPU)
- `nodejs_*` - Node.js runtime metrics

### Loki Configuration
File: `monitoring/loki-config.yml`

- Collects logs from Docker containers
- Storage: `loki_data` volume
- Retention: Not set (logs stored indefinitely)
- Config schema: boltdb-shipper with filesystem storage

### Grafana Dashboards
Location: `monitoring/grafana/dashboards/`

**Available Dashboards:**
1. **api-metrics.json** - API performance overview
   - Request rate (req/5m)
   - Response latency (p95)
   - Error rate (4xx & 5xx)
   - Current request load

### Data Sources (Auto-provisioned)
- **Prometheus** (default): `http://prometheus:9090`
- **Loki**: `http://loki:3100`

## Backend Instrumentation

### Metrics Middleware
File: `backend/src/middleware/metrics.ts`

Automatically tracks:
```typescript
// Request metrics
- http_requests_total{method, path, status}
- http_request_duration_seconds{method, path, status}

// Database metrics
- mongo_connection_active (1/0)

// API-specific metrics
- auth_requests_total{endpoint, status}
- ai_requests_total{endpoint, status}
- ai_request_duration_seconds{endpoint}
```

### Integration Points
The metrics middleware is integrated in `backend/src/index.ts`:
```typescript
import { metricsMiddleware, register } from "./middleware/metrics";

app.use(metricsMiddleware);  // Track all requests
app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});
```

## Common Prometheus Queries

### API Performance
```promql
# Request rate (per second)
rate(http_requests_total[5m])

# Request latency (95th percentile)
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status=~"[45].."}[5m])

# Success rate
rate(http_requests_total{status=~"2.."}[5m])

# Requests by status code
rate(http_requests_total[5m]) by (status)
```

### System Health
```promql
# Node.js memory usage
nodejs_heap_size_used_bytes

# Process uptime
process_uptime_seconds

# CPU usage
rate(process_cpu_seconds_total[5m])

# Database connection status
mongo_connection_active
```

## Common Loki Queries

```logql
# All backend logs
{service="backend"}

# Error logs
{service="backend"} | "error"

# Request logs
{service="backend"} | "request"

# Status code logs
{service="backend"} | "status"
```

## Grafana Alert Setup (Optional)

1. Go to Alerting → Notification channels
2. Add a channel (email, Slack, webhook)
3. Create alert rules:
   - High error rate: `rate(http_requests_total{status=~"[45].."}[5m]) > 0.05`
   - High latency: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1`
   - DB connection down: `mongo_connection_active == 0`

## Logs & Troubleshooting

### View Container Logs
```bash
# All containers
docker-compose -f docker-compose.monitoring.yml logs -f

# Specific container
docker-compose -f docker-compose.monitoring.yml logs -f prometheus
docker-compose -f docker-compose.monitoring.yml logs -f loki
docker-compose -f docker-compose.monitoring.yml logs -f grafana
```

### Prometheus Not Scraping Metrics
1. Check backend is running: `curl http://localhost:5000/metrics`
2. Check Prometheus config: `http://localhost:9090/config`
3. Check targets: `http://localhost:9090/targets`

### Grafana Datasource Connection Issues
1. Go to Configuration → Data Sources
2. Click "Prometheus" or "Loki"
3. Test connection and check URL is correct
4. Ensure services are on the same Docker network

### Backend Metrics Not Appearing
1. Ensure `prom-client` is installed: `npm install prom-client`
2. Restart backend: `npm run dev`
3. Check `/metrics` endpoint: `curl http://localhost:5000/metrics | head -20`

## Performance Optimization

### Prometheus
- Adjust `scrape_interval` in `prometheus.yml` for trade-off between frequency and storage
- Increase `retention` for longer metric history (default: 30d)
- Use recording rules for expensive queries

### Loki
- Configure log retention in `loki-config.yml`
- Adjust `ingestion_rate_mb` for log volume limits
- Use label filters in queries for better performance

### Grafana
- Use dashboard variables for dynamic queries
- Create alerts instead of running frequent expensive queries
- Use recording rules in Prometheus for complex queries

## Cleanup

### Stop the Stack
```bash
docker-compose -f docker-compose.monitoring.yml down
```

### Remove All Data
```bash
docker-compose -f docker-compose.monitoring.yml down -v
```

## Next Steps

1. **Create custom dashboards** for specific business metrics
2. **Set up alerts** for critical thresholds
3. **Configure log retention** based on compliance needs
4. **Add authentication** to Grafana in production
5. **Set up backup** for Prometheus and Loki data
6. **Integrate with** external services (email, Slack, PagerDuty)

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [prom-client for Node.js](https://github.com/siimon/prom-client)
