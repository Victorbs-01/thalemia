

HELK-OS Stack (OpenSearch Based):
├── OpenSearch (reemplazo de Elasticsearch)
├── OpenSearch Dashboards (reemplazo de Kibana)
├── Vector (reemplazo moderno de Logstash - más eficiente)
├── Kafka/Redpanda (streaming - Redpanda es más ligero)
├── Spark (opcional - procesamiento pesado)
├── Jupyter (análisis + ML)
├── Sigma (reglas de detección)
├── Wazuh (SIEM/HIDS)
└── Falco (runtime security K8s)

Pipelines mejorados:
Beats/Agents → Redpanda → Vector → OpenSearch → Dashboards
↓
Wazuh → OpenSearch
↓
Falco (K8s) → OpenSearch
↓
Jupyter (análisis ML)




┌─────────────────────────────────────────────────────────────┐
│                    Data Sources                              │
├─────────────────────────────────────────────────────────────┤
│ • System Logs (journald)                                    │
│ • Application Logs (Docker, K8s, Vendure)                   │
│ • Security Logs (Wazuh, Falco, Fail2ban)                    │
│ • Network Logs (Suricata, Zeek)                             │
│ • Audit Logs (auditd)                                       │
│ • Metrics (Prometheus, node_exporter)                       │
└──────────────────┬──────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│               Log Shippers (Beats)                           │
├─────────────────────────────────────────────────────────────┤
│ • Filebeat: Files → Redpanda                                │
│ • Journalbeat: Systemd → Redpanda                           │
│ • Auditbeat: Audit logs → Redpanda                          │
│ • Packetbeat: Network → Redpanda                            │
│ • Metricbeat: Metrics → Prometheus                          │
└──────────────────┬──────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│         Streaming Buffer (Redpanda)                          │
├─────────────────────────────────────────────────────────────┤
│ • Topics: logs, security, network, audit                    │
│ • Retention: 24h                                            │
│ • Replication: 2x                                           │
└──────────────────┬──────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│          Log Processing (Vector)                             │
├─────────────────────────────────────────────────────────────┤
│ • Parse logs (JSON, Syslog, CEF)                            │
│ • Enrich (GeoIP, DNS, threat intel)                         │
│ • Transform (normalize fields)                              │
│ • Route (to OpenSearch, S3, etc)                            │
└──────────────────┬──────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│        OpenSearch Cluster                                    │
├─────────────────────────────────────────────────────────────┤
│ opensearch-master-1 (DV05): Master node                     │
│ opensearch-data-1 (DV05): Data + Ingest                     │
│ opensearch-data-2 (DV06): Data + Ingest                     │
│                                                              │
│ Indices:                                                     │
│   • logs-{system,app,security}-YYYY.MM.DD                   │
│   • metrics-*                                                │
│   • wazuh-alerts-*                                           │
│   • suricata-*                                               │
│                                                              │
│ Index Lifecycle:                                             │
│   • Hot: 7 days (DV05 SSD)                                  │
│   • Warm: 30 days (DV06 HDD)                                │
│   • Cold: 90 days (MinIO)                                   │
│   • Delete: 180 days                                        │
└──────────────────┬──────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│             Analytics & Visualization                        │
├─────────────────────────────────────────────────────────────┤
│ OpenSearch Dashboards:                                       │
│   • Security dashboards                                      │
│   • Threat hunting                                           │
│   • Compliance reports                                       │
│                                                              │
│ Grafana:                                                     │
│   • System metrics                                           │
│   • Application metrics                                      │
│   • Alerting                                                │
│                                                              │
│ Jupyter:                                                     │
│   • ML analysis                                              │
│   • Threat intelligence                                      │
│   • Custom queries                                           │
└─────────────────────────────────────────────────────────────┘