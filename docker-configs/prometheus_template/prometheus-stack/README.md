# Prometheus Secure Monitoring Stack (Auto-TLS with Let’s Encrypt)

A secure, internet-facing **systems monitoring and alerting stack** built with **Prometheus**, **Alertmanager**, **Grafana**, **node_exporter**, and **Caddy**.

This stack:

* Uses **automatic HTTPS via Let’s Encrypt**
* Enforces **Basic Authentication**
* Exposes **only ports 80/443**
* Keeps Prometheus internals private
* Follows Prometheus’ recommended security model (TLS/auth at the edge)

---

## Architecture

### High-level design

```
Internet
   |
   v
┌──────────────────────────────┐
│        Caddy (TLS)           │
│  • Auto HTTPS (LE)           │
│  • Basic Auth                │
│  • Reverse Proxy             │
└───────────┬──────────────────┘
            │ internal Docker network
 ┌──────────┼───────────┬───────────┐
 v          v           v
Prometheus  Alertmanager  Grafana
:9090       :9093         :3000
```

### Target Server

```
Prometheus ───(scrape)──> node_exporter :9100
                    (firewall allowlist only)
```

---

## Prerequisites

### Required

* A **domain or subdomains** pointing to the monitoring host
* Public IPv4 address
* Docker + Docker Compose
* Outbound internet access (for Let’s Encrypt ACME)

### DNS Records (example)

```
prom.example.com     A   <MONITOR_IP>
alerts.example.com   A   <MONITOR_IP>
grafana.example.com  A   <MONITOR_IP>
```

⚠️ **TLS will NOT work with raw IPs. DNS is mandatory.**

---

## Project Structure

```text
prometheus-stack/
├── docker-compose.yml
├── caddy/
│   └── Caddyfile
├── prometheus/
│   ├── prometheus.yml
│   └── alerts.yml
└── alertmanager/
    └── alertmanager.yml
```

---

## Docker Compose (Secure by Default)

### `docker-compose.yml`

```yaml
services:
  caddy:
    image: caddy:latest
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    expose:
      - "9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alerts.yml:/etc/prometheus/alerts.yml:ro
      - prom_data:/prometheus
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    expose:
      - "9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    expose:
      - "3000"
    restart: unless-stopped

volumes:
  prom_data:
  caddy_data:
  caddy_config:
```

✔ No internal service ports are exposed publicly
✔ TLS termination is centralized
✔ Automatic cert renewal is handled by Caddy

---

## Automatic TLS + Authentication (Caddy)

### `caddy/Caddyfile`

```caddyfile
{
  email admin@example.com
}

prom.example.com {
  encode gzip
  basic_auth {
    admin <BCRYPT_HASH>
  }
  reverse_proxy prometheus:9090
}

alerts.example.com {
  encode gzip
  basic_auth {
    admin <BCRYPT_HASH>
  }
  reverse_proxy alertmanager:9093
}

grafana.example.com {
  encode gzip
  basic_auth {
    admin <BCRYPT_HASH>
  }
  reverse_proxy grafana:3000
}
```

### Generate secure password hash

```bash
docker run --rm -it caddy:latest caddy hash-password
```

Paste the output hash into the `basic_auth` section.

🔐 **Passwords are never stored in plaintext**

---

## Prometheus Configuration

### `prometheus/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/alerts.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets: ["alertmanager:9093"]

scrape_configs:
  - job_name: "node"
    static_configs:
      - targets:
          - YOUR_SERVER_PUBLIC_IP_OR_DNS:9100
```

---

## Target Server (node_exporter)

### Docker (recommended)

```bash
docker run -d --name node_exporter --restart unless-stopped \ 
--net=host \ 
-v /proc:/host/proc:ro \
-v /sys:/host/sys:ro \
-v /:/rootfs:ro \ 
quay.io/prometheus/node-exporter:latest \
--path.procfs=/host/proc \
--path.sysfs=/host/sys \
--path.rootfs=/rootfs
```

### Firewall (mandatory)

Allow scraping **only** from the Prometheus server IP:

```bash
sudo ufw allow from <PROMETHEUS_IP> to any port 9100 proto tcp
sudo ufw deny 9100/tcp
```

🚫 Never expose `/metrics` publicly

---

## Bring the Stack Online

```bash
docker compose up -d
```

### Access URLs (TLS enabled automatically)

* Prometheus → `https://prom.example.com`
* Alertmanager → `https://alerts.example.com`
* Grafana → `https://grafana.example.com`

Certificates are:

* Issued automatically
* Renewed automatically
* Stored in `caddy_data` volume

---

## Grafana Setup

1. Login (default admin/admin)
2. Add Prometheus datasource:

   ```
   http://prometheus:9090
   ```
3. Import dashboard:

   * **Node Exporter Full** (ID `1860`)

---

## Security Model Summary

| Layer     | Protection                      |
| --------- | ------------------------------- |
| Transport | TLS (Let’s Encrypt, auto-renew) |
| Auth      | HTTP Basic Auth                 |
| Network   | Firewall allowlisting           |
| Metrics   | Pull-only                       |
| Storage   | Local TSDB                      |

---

## Recommended Enhancements

* Replace Basic Auth with OIDC (Authelia / Keycloak)
* Add WireGuard instead of public scraping
* Add Blackbox Exporter (HTTP uptime)
* Add SLO-based alerts
* Add backups for Prometheus TSDB

---

## License

* MIT License Prometheus ecosystem components are Apache 2.0
