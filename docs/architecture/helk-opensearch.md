📐 Arquitectura HELK-OS
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
🔧 Componentes Detallados
1. OpenSearch Cluster
   yamlCluster Name: entrepreneur-os-logs
   Nodes:
- opensearch-master-1 (DV05):
  roles: [master, ingest]
  heap: 2GB
  disk: 100GB SSD

- opensearch-data-1 (DV05):
  roles: [data, ingest]
  heap: 4GB
  disk: 500GB SSD (hot data)

- opensearch-data-2 (DV06):
  roles: [data]
  heap: 4GB
  disk: 1TB HDD (warm data)

Configuration:
cluster.name: entrepreneur-os-logs
discovery.seed_hosts: [opensearch-master-1, opensearch-data-1]
cluster.initial_master_nodes: [opensearch-master-1]
bootstrap.memory_lock: true

Security:
plugins.security.disabled: false
plugins.security.ssl.http.enabled: true
plugins.security.ssl.transport.enabled: true
2. Vector (Log Router)
   toml# vector.toml
   [sources.redpanda_logs]
   type = "kafka"
   bootstrap_servers = "redpanda:9092"
   group_id = "vector-logs"
   topics = ["logs.*"]
   decoding.codec = "json"

[transforms.parse_logs]
type = "remap"
inputs = ["redpanda_logs"]
source = '''
. = parse_json!(.message)
.timestamp = now()
.host = get_hostname!()
'''

[transforms.enrich_geoip]
type = "geoip"
inputs = ["parse_logs"]
source = ".ip_address"
target = ".geoip"

[sinks.opensearch]
type = "elasticsearch"
inputs = ["enrich_geoip"]
endpoints = ["https://opensearch-data-1:9200"]
index = "logs-%Y.%m.%d"
compression = "gzip"
bulk.index = "logs"
3. Redpanda (Kafka Alternative)
   yaml# Más ligero que Kafka, compatible con API de Kafka
# 10x más rápido, menos memoria
Resources:
CPU: 2 cores
Memory: 2GB
Disk: 50GB

Topics:
logs.system:
partitions: 3
replication: 2
retention: 24h

logs.security:
partitions: 5
replication: 2
retention: 48h

logs.application:
partitions: 3
replication: 2
retention: 24h
4. Wazuh Integration
   yamlWazuh Manager (DV05):
- Agents en todos los nodos
- Rules custom para Vendure
- Integration con OpenSearch
- Alerting a Grafana

Wazuh Indexer:
- Usa OpenSearch como backend
- wazuh-alerts-* indices
- wazuh-monitoring-* indices

Dashboards:
- Security events
- Compliance (PCI-DSS, GDPR, ISO27001)
- File integrity monitoring
- Vulnerability detection
5. Sigma Rules
   yaml# Detection rules en formato Sigma
# Convertibles a OpenSearch queries

Examples:
- Suspicious PowerShell
- SSH brute force
- SQL injection attempts
- Crypto mining
- Data exfiltration
- Privilege escalation
  📊 Dashboards Predefinidos
  Security Operations Center (SOC)
  Dashboard: Security Overview
  ├── Failed logins (24h)
  ├── Suspicious connections
  ├── Malware detections
  ├── Policy violations
  └── Critical alerts

Dashboard: Threat Hunting
├── Rare processes
├── Unusual network activity
├── File integrity changes
├── Registry modifications
└── Suspicious PowerShell

Dashboard: Compliance
├── PCI-DSS status
├── GDPR compliance
├── Failed audit checks
└── Policy exceptions
Network Operations Center (NOC)
Dashboard: System Health
├── CPU/Memory/Disk usage
├── Service status
├── Container health
├── Database connections
└── API response times

Dashboard: Application Performance
├── Vendure API latency
├── Database query times
├── Cache hit rates
├── Error rates
└── User activity

Dashboard: Network
├── Bandwidth usage
├── Connection map
├── Failed connections
├── DNS queries
└── Blocked IPs
🚀 Deployment Steps
Phase 1: OpenSearch Cluster
bash# 1. Deploy OpenSearch nodes
docker-compose -f infrastructure/compose/monitoring/opensearch.yml up -d

# 2. Wait for cluster to form
curl -k -u admin:admin https://opensearch-data-1:9200/_cluster/health

# 3. Create index templates
curl -X PUT "https://opensearch-data-1:9200/_index_template/logs-template" \
-H 'Content-Type: application/json' \
-d @infrastructure/monitoring/opensearch/templates/logs.json

# 4. Setup ISM policies (Index State Management)
curl -X PUT "https://opensearch-data-1:9200/_plugins/_ism/policies/logs-policy" \
-d @infrastructure/monitoring/opensearch/policies/logs-ism.json
Phase 2: Log Collection
bash# 1. Deploy Redpanda
docker-compose -f infrastructure/compose/monitoring/redpanda.yml up -d

# 2. Create topics
rpk topic create logs.system -p 3 -r 2
rpk topic create logs.security -p 5 -r 2
rpk topic create logs.application -p 3 -r 2

# 3. Deploy Vector on each node
ansible-playbook infrastructure/ansible/playbooks/deploy-vector.yml

# 4. Deploy Beats on each node
ansible-playbook infrastructure/ansible/playbooks/deploy-beats.yml
Phase 3: Security Stack
bash# 1. Deploy Wazuh
docker-compose -f infrastructure/compose/monitoring/wazuh.yml up -d

# 2. Install agents
ansible-playbook infrastructure/ansible/playbooks/install-wazuh-agents.yml

# 3. Deploy Falco (if K8s)
helm install falco falcosecurity/falco

# 4. Deploy Suricata
ansible-playbook infrastructure/ansible/playbooks/deploy-suricata.yml
Phase 4: Visualization
bash# 1. Deploy OpenSearch Dashboards
docker-compose -f infrastructure/compose/monitoring/dashboards.yml up -d

# 2. Import dashboards
./infrastructure/scripts/import-dashboards.sh

# 3. Configure Grafana datasources
ansible-playbook infrastructure/ansible/playbooks/configure-grafana.yml
🔍 Hunting Queries Examples
Detect SSH Brute Force
json{
"query": {
"bool": {
"must": [
{ "match": { "event.dataset": "system.auth" }},
{ "match": { "system.auth.ssh.event": "Failed" }}
],
"filter": {
"range": {
"@timestamp": {
"gte": "now-15m"
}
}
}
}
},
"aggs": {
"by_source_ip": {
"terms": {
"field": "source.ip",
"size": 10
},
"aggs": {
"failed_attempts": {
"value_count": {
"field": "source.ip"
}
}
}
}
}
}
Detect Unusual Process Execution
json{
"query": {
"bool": {
"must": [
{ "match": { "event.category": "process" }},
{ "match": { "event.type": "start" }}
],
"must_not": [
{ "terms": { "process.name": ["systemd", "dockerd", "containerd"] }}
]
}
},
"aggs": {
"rare_processes": {
"rare_terms": {
"field": "process.name"
}
}
}
}
📈 Scaling Strategy
yamlCurrent (4 nodes):
DV02: Applications
DV04: Applications
DV05: OpenSearch + Monitoring
DV06: OpenSearch + Storage

Add 5th node:
DV07: OpenSearch data node (warm tier)

Add 6th node:
DV08: Dedicated Vector + Redpanda

Benefits:
- Better data distribution
- Faster search
- More storage
- Higher availability
  🔒 Security Hardening
  yamlOpenSearch:
- Enable SSL/TLS everywhere
- Use strong passwords
- Enable audit logging
- Restrict network access
- Regular security updates

Network:
- Firewall rules (UFW)
- Fail2ban on SSH
- Rate limiting
- DDoS protection

Data:
- Encryption at rest
- Encryption in transit
- Regular backups
- Access control (RBAC)
  💾 Backup Strategy
  yamlOpenSearch:
- Snapshots to MinIO every 6h
- Retention: 7 days locally, 30 days remote
- Tested restore procedures

Configuration:
- Git-backed configs
- Ansible playbooks versioned
- IaC in repo

Disaster Recovery:
- RPO: 6 hours
- RTO: 2 hours
- Documented runbooks
  📚 Resources
  yamlOfficial Docs:
- OpenSearch: https://opensearch.org/docs/
- Vector: https://vector.dev/docs/
- Wazuh: https://documentation.wazuh.com/

HELK Original:
- GitHub: https://github.com/Cyb3rWard0g/HELK
- Blog: https://cyberwardog.blogspot.com/

Sigma Rules:
- GitHub: https://github.com/SigmaHQ/sigma
- Rules: https://github.com/SigmaHQ/sigma/tree/master/rules

Learning:
- Threat Hunting: https://threathunterplaybook.com/
- MITRE ATT&CK: https://attack.mitre.org/