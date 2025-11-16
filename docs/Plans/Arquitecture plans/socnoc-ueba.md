# 🔒 SOC+NOC+DLP+UEBA - Análisis Completo y Diseño

## 📊 Análisis de Sistemas de Referencia

### Exabeam (UEBA Líder)

**Características clave:**
```yaml
Capabilities:
  - User and Entity Behavior Analytics (UEBA)
  - Behavioral baselining (ML)
  - Anomaly detection
  - Risk scoring
  - Incident response automation
  - Timeline forensics
  - Peer group analysis
  
Technical:
  - ML models: Isolation Forest, LSTM, Autoencoders
  - Data lake architecture
  - Real-time streaming
  - 180+ out-of-box ML models
  
Use Cases:
  - Insider threats
  - Account compromise
  - Data exfiltration
  - Privilege escalation
  - Lateral movement
```

**Precio:** $50k-$200k/año (enterprise)

---

### ObserveIT (DLP + Session Recording)

**Características clave:**
```yaml
Capabilities:
  - User activity monitoring
  - Session recording (screen, keystroke, clipboard)
  - Privileged user monitoring
  - Data loss prevention
  - Compliance recording
  - Suspicious activity alerts
  
Technical:
  - Agent-based (Windows, Linux, Mac)
  - Centralized recording server
  - Policy engine
  - ML-based anomaly detection
  
Use Cases:
  - Prevent data theft
  - Compliance (SOX, HIPAA, PCI-DSS)
  - Insider threat detection
  - Forensic investigations
```

**Precio:** $75-$150 per user/año

---

### Teramind (DLP + Employee Monitoring)

**Características clave:**
```yaml
Capabilities:
  - Real-time user monitoring
  - Screen recording & playback
  - Application usage tracking
  - Website monitoring
  - File transfer monitoring
  - Email & chat monitoring
  - Keystroke logging
  - Productivity analytics
  - Data Loss Prevention rules
  
Technical:
  - Agent + Agentless modes
  - On-premise or cloud
  - OCR for screen content
  - Real-time alerts
  - Behavior rules engine
  
Use Cases:
  - Employee productivity
  - Prevent IP theft
  - Compliance monitoring
  - Remote workforce monitoring
  - Contractor oversight
```

**Precio:** $10-$25 per user/mes

---

### OpenUBA (Open Source UEBA)

**Características:**
```yaml
Open Source Stack:
  - Apache Metron (SIEM)
  - Apache Spot (ML anomaly detection)
  - Apache NiFi (data flow)
  - Elasticsearch (storage)
  - Jupyter (analysis)
  
Capabilities:
  - Network flow analysis
  - DNS anomaly detection
  - Proxy log analysis
  - User behavior baselining
  - Threat hunting
  
Limitations:
  - Requires significant tuning
  - No out-of-box models
  - Complex setup
  - Limited DLP capabilities
```

---

## 🎯 Nuestro Stack: "Entrepreneur Security Platform"

### Arquitectura en Capas

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 7: Security Operations Dashboard                      │
│ ├─ SOC Dashboard (Wazuh + Grafana)                         │
│ ├─ NOC Dashboard (Prometheus + Grafana)                     │
│ ├─ UEBA Dashboard (Custom + OpenSearch)                     │
│ └─ DLP Dashboard (Custom)                                   │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 6: Analytics & ML Engine                              │
│ ├─ Jupyter Hub (Interactive analysis)                       │
│ ├─ MLflow (Model management)                                │
│ ├─ Apache Spark (Batch ML processing)                       │
│ └─ Custom UEBA models (Python)                              │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 5: Detection & Correlation Engine                     │
│ ├─ Sigma Rules (Threat detection)                           │
│ ├─ YARA Rules (Malware detection)                           │
│ ├─ Custom correlation rules                                 │
│ ├─ Anomaly detection algorithms                             │
│ └─ Risk scoring engine                                      │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: SIEM & Log Analysis (OpenSearch + Wazuh)          │
│ ├─ Security events aggregation                              │
│ ├─ Log enrichment (GeoIP, threat intel)                     │
│ ├─ Timeline construction                                    │
│ └─ Incident management                                      │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Data Collection & Processing                       │
│ ├─ Vector (Log routing)                                     │
│ ├─ Redpanda (Streaming buffer)                              │
│ ├─ Filebeat/Auditbeat (System logs)                         │
│ └─ Custom agents (DLP, UEBA)                                │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Data Sources                                       │
│ ├─ System logs (auth, sudo, commands)                       │
│ ├─ Application logs (Vendure, Docker, K8s)                  │
│ ├─ Network logs (Suricata, Zeek)                            │
│ ├─ User activity (custom agents)                            │
│ ├─ File operations (auditd, osquery)                        │
│ └─ Database audit logs                                      │
└─────────────────────────────────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Infrastructure                                     │
│ ├─ DV02-DV06 (Compute + Storage)                            │
│ ├─ Network (Tailscale mesh)                                 │
│ └─ Applications (Vendure, etc)                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Componentes Detallados

### 1. SOC (Security Operations Center)

**Open Source Stack:**

```yaml
SIEM Core:
  Wazuh:
    - Host intrusion detection
    - File integrity monitoring
    - Vulnerability detection
    - Compliance monitoring (PCI-DSS, GDPR, HIPAA)
    - Active response
    - 3000+ out-of-box rules
  
  OpenSearch:
    - Log storage and indexing
    - Fast search and analytics
    - Custom dashboards
    - Alerting

Threat Detection:
  Sigma:
    - Detection rules (YAML format)
    - Convert to OpenSearch queries
    - Community rules: 2000+
    
  YARA:
    - Malware pattern matching
    - File scanning
    - Memory scanning
    
  Suricata:
    - Network IDS/IPS
    - Protocol analysis
    - File extraction
    
  Zeek (Bro):
    - Network security monitoring
    - Protocol analyzers
    - Log enrichment

Threat Intelligence:
  MISP:
    - Threat intelligence platform
    - IOC sharing
    - Correlation with events
    
  AlienVault OTX:
    - Free threat intel feed
    - API integration
    
  Custom feeds:
    - Abuse.ch
    - URLhaus
    - Malware Bazaar

Incident Response:
  TheHive:
    - Case management
    - Task assignment
    - Collaboration
    - Integration with MISP
  
  Cortex:
    - Observable enrichment
    - Automated analysis
    - 100+ analyzers
```

---

### 2. NOC (Network Operations Center)

**Monitoring Stack:**

```yaml
Infrastructure Monitoring:
  Prometheus:
    - Metrics collection
    - Time-series database
    - Alerting rules
    - Service discovery
  
  VictoriaMetrics:
    - Long-term storage
    - Better compression
    - Faster queries
  
  Grafana:
    - Visualization
    - Dashboards
    - Alerting
    - Multiple data sources

Exporters:
  - Node Exporter (system metrics)
  - cAdvisor (containers)
  - Postgres Exporter (databases)
  - Redis Exporter
  - NGINX Exporter
  - Blackbox Exporter (probes)
  - NVIDIA GPU Exporter
  - Custom exporters (Vendure)

Application Performance:
  OpenTelemetry:
    - Traces
    - Metrics
    - Logs (unified)
  
  Jaeger:
    - Distributed tracing
    - Service dependency
    - Performance analysis
  
  Pyroscope:
    - Continuous profiling
    - Flame graphs
    - Performance bottlenecks

Uptime Monitoring:
  Uptime Kuma:
    - Status page
    - Multi-protocol checks
    - Notifications
  
  Gatus:
    - Advanced health checks
    - GraphQL support
    - Webhooks

Network Monitoring:
  Netdata:
    - Real-time system metrics
    - Auto-detection
    - Low overhead
  
  LibreNMS:
    - SNMP monitoring
    - Network mapping
    - Alerting
```

---

### 3. DLP (Data Loss Prevention)

**Custom Stack (Open Source Components):**

```yaml
File Monitoring:
  Auditd:
    - System call auditing
    - File access tracking
    - Process execution
  
  Osquery:
    - SQL queries over OS
    - File integrity monitoring
    - Process monitoring
    - Network connections

Endpoint Agent:
  Custom Python Agent:
    components:
      - File operation monitor (inotify)
      - Clipboard monitor
      - USB device detection
      - Network activity monitor
      - Application usage tracker
      - Screenshot capability (optional)
    
    features:
      - Local policy enforcement
      - Real-time event streaming
      - Encryption of sensitive data
      - Offline queue
      - Resource-efficient

Network DLP:
  Suricata + Custom Rules:
    - SSL/TLS inspection (with decryption)
    - Content inspection
    - Pattern matching (regex, keywords)
    - File type detection
    - Data fingerprinting
  
  ICAP Server:
    - HTTP/HTTPS content scanning
    - Integration with proxy
    - Virus scanning
    - Policy enforcement

Email DLP:
  Rspamd:
    - Email content analysis
    - Attachment scanning
    - Keyword detection
    - Integration with mailserver
    
  Custom Rules:
    - PII detection (SSN, credit cards)
    - Sensitive document detection
    - Recipient validation
    - Attachment policy

Database Activity Monitoring:
  PostgreSQL Audit Extension:
    - Query logging
    - User tracking
    - Data access patterns
    - Compliance reporting

Content Classification:
  LibreOffice + Python:
    - Document parsing
    - Metadata extraction
    - Content fingerprinting
    
  Tesseract OCR:
    - Image text extraction
    - Screenshot analysis
    
  YARA:
    - Sensitive pattern matching
    - Custom classification rules
```

---

### 4. UEBA (User and Entity Behavior Analytics)

**ML-Powered Analytics:**

```yaml
Data Collection:
  Sources:
    - Authentication logs (SSH, web, VPN)
    - File access patterns
    - Application usage
    - Network connections
    - Database queries
    - Email activity
    - System commands
    - USB device usage
    - Print jobs
    - Cloud service access

  Enrichment:
    - User metadata (department, role, location)
    - Asset information
    - Network topology
    - Threat intelligence
    - Historical context

Behavioral Baseline:
  Per-User Models:
    - Login times (time-of-day, day-of-week)
    - Login locations (GeoIP)
    - Devices used
    - Applications accessed
    - File operations
    - Network destinations
    - Data volume transferred
    - Command patterns
  
  Peer Group Analysis:
    - Department baselines
    - Role-based baselines
    - Location baselines
    - Team baselines

ML Models:
  Anomaly Detection:
    algorithms:
      - Isolation Forest
      - One-Class SVM
      - LSTM Autoencoders
      - DBSCAN clustering
      - Local Outlier Factor (LOF)
    
    features:
      - Login frequency
      - Access patterns
      - Data volume
      - Time-based patterns
      - Location changes
      - Failed attempts
      - Privilege escalation
      - Lateral movement
  
  Sequence Models:
    - LSTM for command sequences
    - Transformer for user journeys
    - Markov chains for state transitions
  
  Risk Scoring:
    factors:
      - Anomaly score (0-100)
      - Threat intelligence match
      - Policy violations
      - Historical incidents
      - Peer comparison
      - Asset criticality
    
    formula: |
      risk_score = (
        anomaly_weight * anomaly_score +
        threat_weight * threat_score +
        violation_weight * violation_score +
        history_weight * history_score
      ) * asset_criticality_multiplier

Detection Rules:
  Insider Threats:
    - After-hours access spike
    - Unusual file downloads
    - Access to sensitive data
    - USB device usage
    - Printing sensitive documents
    - Emailing competitors
    - Cloud upload spike
  
  Account Compromise:
    - Impossible travel
    - New device login
    - Multiple failed logins
    - Password spray
    - Unusual application access
    - Privilege escalation
  
  Data Exfiltration:
    - Large data transfers
    - Multiple file downloads
    - Cloud storage uploads
    - Email with attachments
    - FTP/SCP activity
    - Database dump
  
  Lateral Movement:
    - SSH to multiple hosts
    - RDP connections
    - SMB access patterns
    - New service creation
    - Credential dumping

Implementation:
  Python Stack:
    - scikit-learn (ML algorithms)
    - TensorFlow/PyTorch (deep learning)
    - pandas (data manipulation)
    - numpy (numerical computing)
    - scipy (statistics)
  
  Data Pipeline:
    - Apache Spark (batch processing)
    - Kafka/Redpanda (streaming)
    - OpenSearch (storage)
    - Jupyter (analysis)
  
  Real-time Processing:
    - Faust (Python stream processing)
    - FastAPI (REST API)
    - Redis (caching)
    - PostgreSQL (metadata)

Visualization:
  Custom Dashboards:
    - User risk timeline
    - Anomaly heatmap
    - Peer comparison
    - Asset access map
    - Incident timeline
    - Forensic playback
  
  Investigation Tools:
    - User activity search
    - Timeline reconstruction
    - Entity relationship graph
    - Session replay
    - Pattern search
```

---

## 🏗️ Arquitectura Técnica Completa

### Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Data Sources (All Nodes)                                    │
│                                                              │
│ System:                                                      │
│ • auth.log, syslog, audit.log                              │
│ • Docker logs, K8s events                                   │
│ • Application logs (JSON structured)                        │
│                                                              │
│ Security:                                                    │
│ • Wazuh agent events                                        │
│ • Suricata alerts                                           │
│ • File integrity events                                     │
│ • Osquery results                                           │
│                                                              │
│ User Activity:                                               │
│ • Login/logout events                                       │
│ • Command history (bash, zsh)                               │
│ • File operations (inotify)                                 │
│ • Process executions                                        │
│ • Network connections                                       │
│                                                              │
│ Network:                                                     │
│ • NetFlow/IPFIX                                             │
│ • DNS queries                                               │
│ • HTTP/HTTPS logs                                           │
│ • VPN connections                                           │
└──────────────────┬──────────────────────────────────────────┘
                   │ Filebeat, Auditbeat, Custom Agents
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Streaming Buffer (Redpanda - DV06)                          │
│                                                              │
│ Topics:                                                      │
│ • logs.system                                               │
│ • logs.security                                             │
│ • logs.application                                          │
│ • events.user-activity                                      │
│ • events.network                                            │
│ • events.file-operations                                    │
│ • alerts.security                                           │
│ • metrics.system                                            │
│                                                              │
│ Retention: 48h, Replication: 2x                            │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
┌──────────────────┐  ┌──────────────────────┐
│ Vector (DV06)    │  │ Spark Streaming      │
│                  │  │ (DV06)               │
│ • Parse          │  │                      │
│ • Enrich         │  │ • ML feature         │
│ • Transform      │  │   extraction         │
│ • Route          │  │ • Aggregations       │
└────────┬─────────┘  │ • Real-time ML       │
         │            └──────────┬───────────┘
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────────────────────┐
│ OpenSearch Cluster (DV05, DV06)                             │
│                                                              │
│ Indices:                                                     │
│ • logs-system-YYYY.MM.DD (hot: 7d, warm: 30d, cold: 90d)   │
│ • logs-security-YYYY.MM.DD                                  │
│ • alerts-* (long retention)                                 │
│ • ueba-events-* (ML features)                               │
│ • ueba-baselines-* (user profiles)                          │
│ • ueba-anomalies-* (detected anomalies)                     │
│                                                              │
│ Index Lifecycle Management:                                 │
│ Hot → Warm → Cold → Delete                                  │
└──────────────────┬──────────────────────────────────────────┘
                   │
        ┌──────────┴──────────┬──────────────┐
        │                     │              │
        ▼                     ▼              ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Wazuh        │  │ UEBA Engine  │  │ DLP Engine   │
│ (DV05)       │  │ (DV06)       │  │ (DV06)       │
│              │  │              │  │              │
│ • Correlation│  │ • ML models  │  │ • Policy     │
│ • Rules      │  │ • Scoring    │  │   engine     │
│ • Alerts     │  │ • Alerts     │  │ • Content    │
└──────┬───────┘  └──────┬───────┘  │   scanning   │
       │                 │          └──────┬───────┘
       │                 │                 │
       └─────────────────┴─────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Alert & Incident Management                                 │
│                                                              │
│ TheHive (DV05):                                             │
│ • Alert aggregation                                         │
│ • Case creation                                             │
│ • Task management                                           │
│ • Playbook automation                                       │
│                                                              │
│ Cortex:                                                      │
│ • Observable enrichment                                     │
│ • Automated response                                        │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Dashboards & Visualization                                  │
│                                                              │
│ SOC Dashboard (Wazuh UI):                                   │
│ • Security events                                           │
│ • Compliance status                                         │
│ • Vulnerability scans                                       │
│                                                              │
│ NOC Dashboard (Grafana):                                    │
│ • System metrics                                            │
│ • Application performance                                   │
│ • Network status                                            │
│                                                              │
│ UEBA Dashboard (Custom React):                              │
│ • User risk scores                                          │
│ • Anomaly timeline                                          │
│ • Investigation tools                                       │
│                                                              │
│ DLP Dashboard (Custom React):                               │
│ • Policy violations                                         │
│ • Data movement                                             │
│ • Incident reports                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Componentes Custom

### 1. DLP Agent (Python)

```python
"""
entrepreneur_dlp_agent.py
Lightweight DLP agent for endpoint monitoring
"""

import os
import json
import psutil
import pyinotify
import logging
from datetime import datetime
from kafka import KafkaProducer

class DLPAgent:
    def __init__(self, config_path='/etc/dlp-agent/config.json'):
        self.config = self.load_config(config_path)
        self.producer = KafkaProducer(
            bootstrap_servers=self.config['kafka_brokers'],
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        
    def monitor_file_operations(self):
        """Monitor file read/write/delete operations"""
        wm = pyinotify.WatchManager()
        mask = pyinotify.IN_ACCESS | pyinotify.IN_MODIFY | pyinotify.IN_DELETE
        
        class EventHandler(pyinotify.ProcessEvent):
            def process_default(self, event):
                self.log_file_event(event)
        
        handler = EventHandler()
        notifier = pyinotify.Notifier(wm, handler)
        
        # Watch sensitive directories
        for path in self.config['monitored_paths']:
            wm.add_watch(path, mask, rec=True)
        
        notifier.loop()
    
    def monitor_clipboard(self):
        """Monitor clipboard for sensitive data"""
        # Implementation for clipboard monitoring
        pass
    
    def monitor_usb_devices(self):
        """Monitor USB device connections"""
        # Implementation for USB monitoring
        pass
    
    def scan_content(self, content):
        """Scan content for sensitive patterns"""
        findings = []
        
        for pattern in self.config['dlp_patterns']:
            if pattern['regex'].match(content):
                findings.append({
                    'pattern': pattern['name'],
                    'severity': pattern['severity'],
                    'matched': pattern['regex'].findall(content)
                })
        
        return findings
    
    def send_event(self, event_type, data):
        """Send event to Kafka"""
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'hostname': os.uname().nodename,
            'event_type': event_type,
            'data': data
        }
        
        self.producer.send(
            self.config['kafka_topic'],
            value=event
        )
```

### 2. UEBA Engine (Python + ML)

```python
"""
ueba_engine.py
User behavior analytics and anomaly detection
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense

class UEBAEngine:
    def __init__(self, opensearch_client):
        self.os = opensearch_client
        self.models = {}
        
    def build_user_baseline(self, username, days=30):
        """Build behavioral baseline for a user"""
        
        # Query historical data
        query = {
            "bool": {
                "must": [
                    {"term": {"username": username}},
                    {"range": {
                        "timestamp": {
                            "gte": f"now-{days}d"
                        }
                    }}
                ]
            }
        }
        
        data = self.os.search(index="ueba-events-*", query=query)
        df = pd.DataFrame([hit['_source'] for hit in data['hits']['hits']])
        
        # Extract features
        features = self.extract_features(df)
        
        # Train anomaly detection model
        model = IsolationForest(
            contamination=0.1,
            random_state=42
        )
        model.fit(features)
        
        self.models[username] = {
            'model': model,
            'scaler': StandardScaler().fit(features),
            'baseline_stats': features.describe()
        }
        
        return self.models[username]
    
    def detect_anomalies(self, username, recent_events):
        """Detect anomalies in recent user activity"""
        
        if username not in self.models:
            self.build_user_baseline(username)
        
        user_model = self.models[username]
        features = self.extract_features(recent_events)
        features_scaled = user_model['scaler'].transform(features)
        
        # Predict anomalies
        predictions = user_model['model'].predict(features_scaled)
        scores = user_model['model'].score_samples(features_scaled)
        
        # Calculate risk score
        anomalies = []
        for i, (pred, score) in enumerate(zip(predictions, scores)):
            if pred == -1:  # Anomaly
                risk_score = self.calculate_risk_score(
                    score,
                    recent_events.iloc[i],
                    user_model['baseline_stats']
                )
                
                anomalies.append({
                    'event': recent_events.iloc[i].to_dict(),
                    'anomaly_score': float(score),
                    'risk_score': risk_score,
                    'reasons': self.explain_anomaly(
                        recent_events.iloc[i],
                        user_model['baseline_stats']
                    )
                })
        
        return anomalies
    
    def extract_features(self, df):
        """Extract ML features from events"""
        features = pd.DataFrame()
        
        # Time-based features
        df['hour'] = pd.to_datetime(df['timestamp']).dt.hour
        df['day_of_week'] = pd.to_datetime(df['timestamp']).dt.dayofweek
        
        features['login_hour_mean'] = df.groupby('username')['hour'].mean()
        features['login_hour_std'] = df.groupby('username')['hour'].std()
        features['weekend_ratio'] = (df['day_of_week'] >= 5).mean()
        
        # Access patterns
        features['unique_ips'] = df.groupby('username')['source_ip'].nunique()
        features['unique_apps'] = df.groupby('username')['application'].nunique()
        features['failed_login_ratio'] = (df['event_type'] == 'login_failed').mean()
        
        # Data movement
        features['bytes_transferred'] = df.groupby('username')['bytes'].sum()
        features['files_accessed'] = df.groupby('username')['file_path'].nunique()
        
        return features
    
    def calculate_risk_score(self, anomaly_score, event, baseline):
        """Calculate overall risk score (0-100)"""
        
        # Base score from anomaly detection
        base_score = min(abs(anomaly_score) * 10, 70)
        
        # Additional factors
        threat_intel_match = self.check_threat_intel(event)
        policy_violation = self.check_policy_violation(event)
        asset_criticality = self.get_asset_criticality(event)
        
        risk_score = (
            base_score +
            (threat_intel_match * 20) +
            (policy_violation * 15) +
            (asset_criticality * 10)
        )
        
        return min(risk_score, 100)
    
    def explain_anomaly(self, event, baseline):
        """Explain why an event is anomalous"""
        reasons = []
        
        # Check each feature against baseline
        if event['hour'] < baseline['login_hour_mean'] - 2 * baseline['login_hour_std']:
            reasons.append("Unusual login time (very early)")
        
        if event['hour'] > baseline['login_hour_mean'] + 2 * baseline['login_hour_std']:
            reasons.append("Unusual login time (very late)")
        
        if event['source_ip'] not in baseline['common_ips']:
            reasons.append("Login from new IP address")
        
        if event['bytes'] > baseline['bytes_transferred'] + 3 * baseline['bytes_std']:
            reasons.append("Unusually large data transfer")
        
        return reasons
```

---

## 📊 Dashboards Design

### SOC Dashboard (Wazuh + Grafana)

```yaml
Panels:
  Overview:
    - Alert severity distribution (pie chart)
    - Alerts over time (line graph)
    - Top attacked assets (bar chart)
    - Top attack sources (map)
    - Recent critical alerts (table)
  
  Compliance:
    - PCI-DSS status (gauge)
    - GDPR compliance (gauge)
    - Failed compliance checks (table)
    - Remediation tasks (kanban)
  
  Vulnerability:
    - CVE by severity (stacked bar)
    - Vulnerable systems (table)
    - Patch status (progress bars)
    - Vulnerability timeline
  
  Threat Intelligence:
    - IOC matches (table)
    - Threat actor activity (timeline)
    - MITRE ATT&CK coverage (heatmap)
    - Threat feed status (status indicators)
  
  Incident Response:
    - Open incidents (count)
    - Mean time to detect (MTTD)
    - Mean time to respond (MTTR)
    - Incident timeline (gantt chart)
    - Response playbooks (list)

### NOC Dashboard (Grafana + Prometheus)

```yaml
Panels:
  Infrastructure Health:
    - Overall system status (traffic lights)
    - CPU usage per node (gauge cluster)
    - Memory usage per node (gauge cluster)
    - Disk I/O (line graph)
    - Network throughput (area chart)
    - Container status (table)
  
  Application Performance:
    - Request rate (line graph)
    - Response time (heatmap)
    - Error rate (line graph)
    - Database queries/sec (gauge)
    - Cache hit ratio (gauge)
    - Active users (stat)
  
  Services:
    - Vendure Master status
    - Vendure Ecommerce status
    - OpenSearch cluster health
    - PostgreSQL connections
    - Redis memory usage
    - n8n workflow status
  
  Network:
    - Bandwidth usage (area chart)
    - Connection map (world map)
    - Top talkers (table)
    - Failed connections (counter)
    - DNS query rate (line graph)
    - Latency heatmap
  
  Capacity Planning:
    - Storage growth prediction (line graph)
    - CPU trend (line graph)
    - Memory trend (line graph)
    - Estimated time to full (stat)
```

### UEBA Dashboard (Custom React + OpenSearch)

```yaml
Layout:
  Header:
    - Global filters (date range, user, department)
    - Quick search
    - Alert counter (with severity badges)
  
  Main View - Risk Overview:
    Top Panel:
      - High risk users (cards with avatars)
      - Risk score distribution (histogram)
      - Trending risk (sparklines)
    
    Middle Panel:
      - User risk timeline (interactive timeline)
      - Anomaly heatmap (users x time)
      - Peer group comparison (radar chart)
    
    Bottom Panel:
      - Recent anomalies (table with drill-down)
      - Investigation queue (kanban board)
  
  User Detail View:
    Left Sidebar:
      - User profile card
      - Risk score gauge (0-100)
      - Risk factors breakdown
      - Historical risk trend
    
    Main Content:
      Tab 1 - Activity Timeline:
        - Interactive timeline of all user actions
        - Grouped by type (login, file access, etc)
        - Anomalies highlighted
        - Filters by event type
      
      Tab 2 - Behavior Analysis:
        - Login patterns (time-of-day heatmap)
        - Location map (GeoIP)
        - Device usage (pie chart)
        - Application usage (bar chart)
        - Command frequency (word cloud)
      
      Tab 3 - Peer Comparison:
        - Comparison with department average
        - Similar users (based on ML clustering)
        - Outlier metrics
      
      Tab 4 - Forensics:
        - Raw event search
        - Session reconstruction
        - File access tree
        - Network connections graph
      
      Tab 5 - Alerts:
        - All alerts for this user
        - Alert correlation
        - Response actions taken
  
  Investigation Tools:
    - Global timeline (all users)
    - Entity relationship graph
    - Pattern search (regex on activities)
    - Bulk user analysis
    - Report generator

Components:
  Risk Score Card:
    - Large gauge (0-100)
    - Color coded (green/yellow/orange/red)
    - Trend arrow (↑↓)
    - Contributing factors list
    - Quick actions (investigate, whitelist, alert)
  
  Anomaly Card:
    - Timestamp
    - Anomaly type icon
    - Severity badge
    - Brief description
    - Affected user/asset
    - Quick peek (expandable details)
    - Actions (investigate, false positive, escalate)
  
  Timeline Component:
    - Zoom and pan
    - Event clustering
    - Anomaly markers (red dots)
    - Baseline overlay (gray area)
    - Filters (event type, severity)
    - Export (CSV, PDF)
  
  Heatmap Component:
    - Users on Y-axis
    - Time on X-axis
    - Color intensity = risk/activity level
    - Click to drill-down
    - Hover for details
```

### DLP Dashboard (Custom React)

```yaml
Layout:
  Overview:
    Top Metrics:
      - Total incidents (24h, 7d, 30d)
      - High severity incidents
      - Data at risk (GB)
      - Blocked attempts
      - Policy violations
    
    Charts:
      - Incidents over time (line + bar combo)
      - Incidents by type (pie chart)
      - Incidents by department (bar chart)
      - Top violators (table)
      - Data movement trends (area chart)
  
  Incidents View:
    Table Columns:
      - Timestamp
      - Severity (badge)
      - Type (icon + label)
      - User
      - Source
      - Destination
      - Data type
      - Size
      - Action taken
      - Status
      - Actions (view, remediate, close)
    
    Filters:
      - Date range
      - Severity
      - Type
      - User/Department
      - Status (open, investigating, resolved)
      - Data classification
    
    Bulk Actions:
      - Export selected
      - Assign investigator
      - Change status
      - Generate report
  
  Policies View:
    Policy Cards:
      - Policy name
      - Description
      - Enabled/Disabled toggle
      - Triggered count
      - Last triggered
      - Actions (edit, test, duplicate, delete)
    
    Policy Builder:
      - Visual rule builder (drag-and-drop)
      - Conditions (AND/OR logic)
      - Actions (block, alert, encrypt, watermark)
      - Exceptions
      - Test against historical data
      - Preview affected events
  
  Data Classification:
    - Sensitive data inventory
    - Classification rules
    - Auto-tagging status
    - Data flow visualization
    - Compliance mapping
  
  Reports:
    - Pre-built templates
    - Custom report builder
    - Schedule generation
    - Export formats (PDF, CSV, Excel)
    - Compliance reports (PCI-DSS, GDPR, HIPAA)

Real-time Features:
  - Live incident feed (WebSocket)
  - Desktop notifications
  - Mobile app push notifications
  - Slack/Teams integration
  - Email alerts
```

---

## 🔄 CI/CD Integration - Gitea + Drone

### Why Gitea + Drone?

```yaml
Gitea:
  benefits:
    - Lightweight (< 100MB RAM)
    - Self-hosted (full control)
    - GitHub-like UI (familiar)
    - Git + Package registry
    - Container registry
    - Actions (CI/CD built-in)
    - Webhooks
    - API
  
  vs_github:
    - No external dependencies
    - No rate limits
    - No privacy concerns
    - Works in China (no GFW issues)
    - Free unlimited repos
  
  vs_gitlab:
    - Much lighter (10x less RAM)
    - Faster
    - Simpler
    - Easier to maintain

Drone CI:
  benefits:
    - Container-native
    - Simple YAML config
    - Powerful plugins
    - Matrix builds
    - Secrets management
    - Auto-scaling
  
  vs_jenkins:
    - No Java (lighter)
    - Modern UI
    - Better Docker support
    - Easier configuration
  
  vs_github_actions:
    - Self-hosted
    - More powerful
    - Better Docker integration
    - Conditional execution
```

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Developer Push                                               │
│ git push → Gitea (DV05)                                     │
└──────────────────┬──────────────────────────────────────────┘
                   │ Webhook
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Drone Server (DV05)                                         │
│ • Receives webhook                                          │
│ • Parses .drone.yml                                         │
│ • Schedules pipeline                                        │
│ • Manages secrets                                           │
└──────────────────┬──────────────────────────────────────────┘
                   │ Pipeline definition
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Drone Runners (DV02, DV04, DV06)                            │
│                                                              │
│ DV02 Runner:                                                │
│ • Build Vendure Master                                      │
│ • Run unit tests                                            │
│ • Build Docker image                                        │
│                                                              │
│ DV04 Runner:                                                │
│ • Build Storefronts                                         │
│ • Run E2E tests (Playwright)                                │
│ • Build Docker images                                       │
│                                                              │
│ DV06 Runner:                                                │
│ • Security scanning (Trivy)                                 │
│ • SAST (SonarQube)                                          │
│ • Dependency check                                          │
└──────────────────┬──────────────────────────────────────────┘
                   │ Build artifacts
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Harbor Registry (DV05)                                      │
│ • Store Docker images                                       │
│ • Vulnerability scanning                                    │
│ • Image signing                                             │
│ • Replication                                               │
└──────────────────┬──────────────────────────────────────────┘
                   │ Deploy trigger
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Deployment (K3s or Docker Swarm)                            │
│ • Rolling update                                            │
│ • Health checks                                             │
│ • Rollback on failure                                       │
│ • Notification (Slack/Email)                                │
└─────────────────────────────────────────────────────────────┘
```

### Example .drone.yml

```yaml
# .drone.yml for Vendure Master
kind: pipeline
type: docker
name: vendure-master

steps:
  # Step 1: Install dependencies
  - name: install
    image: node:24-alpine
    commands:
      - npm install -g pnpm
      - pnpm install --frozen-lockfile
    volumes:
      - name: cache
        path: /root/.pnpm-store

  # Step 2: Lint
  - name: lint
    image: node:24-alpine
    commands:
      - pnpm run lint
    depends_on:
      - install

  # Step 3: Unit tests
  - name: test
    image: node:24-alpine
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: vendure_test
      DB_USER: vendure
      DB_PASSWORD:
        from_secret: db_password
    commands:
      - pnpm run test
    depends_on:
      - install

  # Step 4: Build
  - name: build
    image: node:24-alpine
    commands:
      - pnpm run build
    depends_on:
      - test
      - lint

  # Step 5: Security scan
  - name: security-scan
    image: aquasec/trivy:latest
    commands:
      - trivy fs --severity HIGH,CRITICAL --exit-code 1 .
    depends_on:
      - build

  # Step 6: Build Docker image
  - name: docker-build
    image: plugins/docker
    settings:
      registry: harbor.entrepreneur-os.com
      repo: harbor.entrepreneur-os.com/vendure/master
      tags:
        - ${DRONE_COMMIT_SHA:0:8}
        - ${DRONE_BRANCH}
        - latest
      username:
        from_secret: harbor_username
      password:
        from_secret: harbor_password
      dockerfile: infrastructure/docker/vendure-master/Dockerfile
      cache_from:
        - harbor.entrepreneur-os.com/vendure/master:latest
    depends_on:
      - security-scan
    when:
      branch:
        - main
        - develop

  # Step 7: Deploy to staging
  - name: deploy-staging
    image: alpine/k8s:1.28.5
    environment:
      KUBECONFIG: /tmp/kubeconfig
    commands:
      - echo "$KUBECONFIG_CONTENT" > /tmp/kubeconfig
      - kubectl set image deployment/vendure-master 
        vendure-master=harbor.entrepreneur-os.com/vendure/master:${DRONE_COMMIT_SHA:0:8}
        -n staging
      - kubectl rollout status deployment/vendure-master -n staging --timeout=5m
    environment:
      KUBECONFIG_CONTENT:
        from_secret: kubeconfig_staging
    depends_on:
      - docker-build
    when:
      branch:
        - develop

  # Step 8: Deploy to production
  - name: deploy-production
    image: alpine/k8s:1.28.5
    environment:
      KUBECONFIG: /tmp/kubeconfig
    commands:
      - echo "$KUBECONFIG_CONTENT" > /tmp/kubeconfig
      - kubectl set image deployment/vendure-master 
        vendure-master=harbor.entrepreneur-os.com/vendure/master:${DRONE_COMMIT_SHA:0:8}
        -n production
      - kubectl rollout status deployment/vendure-master -n production --timeout=5m
    environment:
      KUBECONFIG_CONTENT:
        from_secret: kubeconfig_production
    depends_on:
      - docker-build
    when:
      branch:
        - main
      event:
        - tag

  # Step 9: Run E2E tests
  - name: e2e-tests
    image: mcr.microsoft.com/playwright:v1.40.0
    commands:
      - pnpm exec playwright install
      - pnpm run e2e
    environment:
      BASE_URL: https://staging.entrepreneur-os.com
    depends_on:
      - deploy-staging
    when:
      branch:
        - develop

  # Step 10: Notify
  - name: notify
    image: plugins/slack
    settings:
      webhook:
        from_secret: slack_webhook
      channel: deployments
      template: |
        {{#success build.status}}
          ✅ Build #{{build.number}} succeeded
          📦 Vendure Master deployed to {{build.branch}}
          👤 {{build.author}}
          🔗 {{build.link}}
        {{else}}
          ❌ Build #{{build.number}} failed
          📦 Vendure Master
          👤 {{build.author}}
          🔗 {{build.link}}
        {{/success}}
    depends_on:
      - deploy-staging
      - deploy-production
    when:
      status:
        - success
        - failure

# Services (databases, etc)
services:
  - name: postgres
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: vendure
      POSTGRES_PASSWORD: vendure
      POSTGRES_DB: vendure_test
    ports:
      - 5432

  - name: redis
    image: redis:7-alpine
    ports:
      - 6379

volumes:
  - name: cache
    host:
      path: /tmp/drone-cache

trigger:
  branch:
    - main
    - develop
    - feature/*
  event:
    - push
    - pull_request
    - tag
```

### Security Pipeline Integration

```yaml
# .drone.yml (security-focused)
kind: pipeline
type: docker
name: security-scan

steps:
  # SAST with SonarQube
  - name: sonarqube-scan
    image: sonarsource/sonar-scanner-cli:latest
    environment:
      SONAR_HOST_URL: https://sonar.entrepreneur-os.com
      SONAR_TOKEN:
        from_secret: sonarqube_token
    commands:
      - sonar-scanner
        -Dsonar.projectKey=vendure-master
        -Dsonar.sources=src
        -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info

  # Dependency check
  - name: dependency-check
    image: owasp/dependency-check:latest
    commands:
      - /usr/share/dependency-check/bin/dependency-check.sh
        --scan .
        --format JSON
        --out reports
        --failOnCVSS 7

  # Secret scanning
  - name: secret-scan
    image: trufflesecurity/trufflehog:latest
    commands:
      - trufflehog filesystem . --json --fail > secrets-report.json

  # Container vulnerability scan
  - name: trivy-scan
    image: aquasec/trivy:latest
    commands:
      - trivy image --severity HIGH,CRITICAL
        --exit-code 1
        harbor.entrepreneur-os.com/vendure/master:latest

  # License compliance
  - name: license-check
    image: licensefinder/license_finder:latest
    commands:
      - license_finder --decisions-file=license_decisions.yml

  # Upload to security dashboard
  - name: upload-results
    image: curlimages/curl:latest
    commands:
      - curl -X POST https://security.entrepreneur-os.com/api/scan-results
        -H "Authorization: Bearer $TOKEN"
        -F "sonar=@sonar-report.json"
        -F "dependencies=@dependency-report.json"
        -F "secrets=@secrets-report.json"
        -F "vulnerabilities=@trivy-report.json"
    environment:
      TOKEN:
        from_secret: security_api_token
    depends_on:
      - sonarqube-scan
      - dependency-check
      - secret-scan
      - trivy-scan

trigger:
  event:
    - push
    - cron
```

---

## 🎓 Training & Detection Rules

### UEBA Detection Rules (Custom)

```yaml
# ueba-rules.yml
rules:
  # Insider Threat Patterns
  - name: after_hours_sensitive_access
    description: User accessing sensitive data outside business hours
    severity: high
    conditions:
      - user.access_time NOT IN business_hours
      - file.classification IN [confidential, secret, top_secret]
      - user.role NOT IN [admin, security]
    actions:
      - alert
      - increase_risk_score: 20
      - notify: security_team

  - name: mass_file_download
    description: User downloading unusual number of files
    severity: critical
    conditions:
      - file.download_count > user.baseline.download_count * 3
      - time_window: 1h
    actions:
      - alert
      - increase_risk_score: 30
      - block_future_downloads
      - notify: soc

  - name: impossible_travel
    description: User login from geographically distant locations in short time
    severity: high
    conditions:
      - geoip.distance > 1000km
      - time_delta < 2h
    actions:
      - alert
      - increase_risk_score: 40
      - require_mfa
      - notify: user_and_security

  - name: privilege_escalation_attempt
    description: User attempting to access resources above their privilege level
    severity: critical
    conditions:
      - access.resource_level > user.privilege_level
      - access.denied = true
      - attempt_count > 3 IN 10m
    actions:
      - alert
      - increase_risk_score: 50
      - temporary_account_lock: 30m
      - notify: soc

  # Account Compromise Indicators
  - name: unusual_application_usage
    description: User accessing applications they never used before
    severity: medium
    conditions:
      - application NOT IN user.historical_apps
      - application.category = high_risk
    actions:
      - alert
      - increase_risk_score: 15
      - require_verification

  - name: login_from_tor_vpn
    description: Login from anonymization service
    severity: high
    conditions:
      - source_ip IN threat_intel.tor_exit_nodes
      OR source_ip IN threat_intel.vpn_providers
    actions:
      - alert
      - increase_risk_score: 25
      - require_mfa
      - notify: user

  # Data Exfiltration
  - name: large_email_attachments
    description: User sending large email attachments
    severity: medium
    conditions:
      - email.attachment_size > 10MB
      - email.recipient EXTERNAL
      - email.attachment_count > user.baseline.attachment_count * 2
    actions:
      - alert
      - increase_risk_score: 20
      - require_approval
      - scan_attachment

  - name: cloud_storage_upload_spike
    description: Unusual cloud storage upload activity
    severity: high
    conditions:
      - cloud.upload_size > user.baseline.upload_size * 5
      - time_window: 1h
      - cloud.provider IN [dropbox, google_drive, onedrive]
    actions:
      - alert
      - increase_risk_score: 30
      - block_upload
      - notify: soc

  # Lateral Movement
  - name: ssh_to_multiple_hosts
    description: User SSHing to unusual number of hosts
    severity: high
    conditions:
      - ssh.unique_hosts > 5
      - time_window: 1h
      - user.role NOT IN [admin, devops]
    actions:
      - alert
      - increase_risk_score: 35
      - notify: soc

  - name: credential_dumping_attempt
    description: Attempt to dump credentials from system
    severity: critical
    conditions:
      - process.name IN [mimikatz, gsecdump, pwdump]
      OR command.contains: [lsass, SAM, SYSTEM]
    actions:
      - alert
      - increase_risk_score: 80
      - kill_process
      - isolate_host
      - notify: soc_immediate
```

### DLP Policy Examples

```yaml
# dlp-policies.yml
policies:
  # PII Protection
  - name: ssn_protection
    description: Detect and protect Social Security Numbers
    enabled: true
    patterns:
      - regex: '\b\d{3}-\d{2}-\d{4}\b'
      - regex: '\b\d{9}\b'
    actions:
      - alert
      - redact
      - encrypt_at_rest
    exceptions:
      - user.department = HR
      - file.path = /secure/hr/

  - name: credit_card_protection
    description: Prevent credit card number leakage
    enabled: true
    patterns:
      - regex: '\b4[0-9]{12}(?:[0-9]{3})?\b'  # Visa
      - regex: '\b5[1-5][0-9]{14}\b'  # Mastercard
      - luhn_check: true
    actions:
      - alert
      - block_transmission
      - notify: compliance_team

  # Intellectual Property
  - name: source_code_protection
    description: Prevent source code exfiltration
    enabled: true
    conditions:
      - file.extension IN [.py, .js, .java, .cpp, .go]
      - transfer.destination = external
      - file.contains: [proprietary, confidential]
    actions:
      - block
      - alert
      - increase_risk_score: 40

  - name: database_schema_protection
    description: Protect database schemas
    enabled: true
    conditions:
      - file.type = sql_dump
      OR command.contains: [pg_dump, mysqldump]
    actions:
      - block
      - alert
      - require_approval

  # Compliance
  - name: gdpr_pii_transfer
    description: Detect PII transfer outside EU
    enabled: true
    conditions:
      - data.classification = pii
      - transfer.destination.geo NOT IN [EU]
      - user.role NOT IN [compliance, legal]
    actions:
      - block
      - alert
      - require_dpa_approval

  - name: financial_data_protection
    description: SOX compliance for financial data
    enabled: true
    conditions:
      - file.classification = financial
      - user.role NOT IN [finance, auditor]
    actions:
      - alert
      - log_access
      - require_justification
```

### Sigma Rules Integration

```yaml
# Custom Sigma rules for entrepreneur-os

title: Vendure Admin Panel Brute Force
status: experimental
description: Detects brute force attempts on Vendure admin panel
author: Entrepreneur OS Security Team
date: 2024/01/01
references:
    - https://docs.vendure.io/security
logsource:
    category: webserver
    product: vendure
detection:
    selection:
        url|contains: '/admin-api'
        http_status: 401
    timeframe: 5m
    condition: selection | count(source_ip) > 10
falsepositives:
    - Legitimate password reset attempts
    - API testing
level: high
tags:
    - attack.credential_access
    - attack.t1110

---

title: Unusual Data Export from Vendure
status: stable
description: Detects large data exports from Vendure API
author: Entrepreneur OS Security Team
date: 2024/01/01
logsource:
    category: application
    product: vendure
detection:
    selection:
        event_type: 'product_export'
        record_count: '> 1000'
    filter:
        user.role: 
            - 'admin'
            - 'data_analyst'
    condition: selection and not filter
falsepositives:
    - Scheduled backups
    - Legitimate bulk operations
level: medium
tags:
    - attack.exfiltration
    - attack.t1048

---

title: Suspicious Docker Container Execution
status: experimental
description: Detects potentially malicious Docker container execution
author: Entrepreneur OS Security Team
date: 2024/01/01
logsource:
    product: linux
    service: docker
detection:
    selection:
        event_type: 'container.start'
    suspicious:
        - container.image|contains: 
            - 'miner'
            - 'cryptominer'
            - 'xmrig'
        - container.privileged: true
        - container.volume|contains: '/etc'
        - container.network_mode: 'host'
    condition: selection and suspicious
falsepositives:
    - Legitimate system containers
    - Development containers
level: high
tags:
    - attack.execution
    - attack.t1610
```

---

## 📈 Metrics & KPIs

### SOC Metrics

```yaml
Detection:
  - True Positive Rate (TPR): > 95%
  - False Positive Rate (FPR): < 5%
  - Mean Time to Detect (MTTD): < 1 hour
  - Alert fatigue rate: < 10%
  - Coverage (MITRE ATT&CK): > 80%

Response:
  - Mean Time to Respond (MTTR): < 4 hours
  - Mean Time to Contain (MTTC): < 8 hours
  - Incident resolution rate: > 95%
  - Escalation rate: < 10%

Compliance:
  - Audit success rate: 100%
  - Policy compliance: > 98%
  - Vulnerability remediation: < 30 days
  - Patch coverage: > 95%
```

### NOC Metrics

```yaml
Availability:
  - System uptime: > 99.9%
  - Service availability: > 99.5%
  - Network uptime: > 99.9%
  - Planned downtime: < 4 hours/month

Performance:
  - API response time: < 200ms (p95)
  - Page load time: < 2s (p95)
  - Database query time: < 50ms (p95)
  - Job processing time: < 5 minutes

Capacity:
  - CPU utilization: < 70% (average)
  - Memory utilization: < 80% (average)
  - Disk usage growth: monitored
  - Network bandwidth: < 60% (peak)

Incidents:
  - Mean Time Between Failures (MTBF): > 720 hours
  - Mean Time to Repair (MTTR): < 2 hours
  - Change success rate: > 95%
  - Rollback rate: < 5%
```

### UEBA Metrics

```yaml
Detection:
  - Anomaly detection accuracy: > 90%
  - True anomaly rate: > 70%
  - Model drift: < 5% per month
  - Baseline update frequency: weekly

Investigation:
  - Mean investigation time: < 30 minutes
  - Case closure rate: > 90%
  - False positive feedback: continuous
  - Model retraining: monthly

Risk:
  - High-risk users identified: tracked
  - Risk score accuracy: > 85%
  - Insider threat detection rate: > 80%
  - Account compromise detection: > 90%
```

### DLP Metrics

```yaml
Prevention:
  - Data loss incidents: 0
  - Policy violations: tracked
  - Blocked attempts: logged
  - Encryption coverage: 100% sensitive data

Detection:
  - PII detection accuracy: > 95%
  - False positive rate: < 10%
  - Sensitive data discovery: ongoing
  - Classification accuracy: > 90%

Compliance:
  - GDPR compliance: 100%
  - PCI-DSS compliance: 100%
  - Data retention policy: enforced
  - Audit trail completeness: 100%
```

---

## 🚀 Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
```
✅ OpenSearch cluster
✅ Wazuh SIEM
✅ Basic monitoring (Prometheus + Grafana)
✅ Log collection (Vector + Filebeat)
✅ Initial dashboards
```

### Phase 2: SOC Capabilities (Weeks 3-4)
```
✅ Threat intelligence integration
✅ Sigma rules deployment
✅ Network IDS (Suricata)
✅ TheHive incident management
✅ Automated response playbooks
```

### Phase 3: UEBA Engine (Weeks 5-6)
```
✅ Data pipeline for user events
✅ ML model development
✅ Baseline building
✅ Anomaly detection
✅ Risk scoring
✅ UEBA dashboard
```

### Phase 4: DLP System (Weeks 7-8)
```
✅ Endpoint agents
✅ Policy engine
✅ Content classification
✅ Network DLP
✅ Email DLP
✅ DLP dashboard
```

### Phase 5: CI/CD (Week 9)
```
✅ Gitea installation
✅ Drone setup
✅ Harbor registry
✅ Security pipeline
✅ Automated deployment
```

### Phase 6: Advanced Features (Weeks 10-12)
```
✅ Machine learning model refinement
✅ Advanced correlation rules
✅ Threat hunting platform (Jupyter)
✅ Automated forensics
✅ Integration with business systems
✅ Custom reporting engine
```

---

## 💾 Data Architecture & Storage Strategy

### Data Tiers

```yaml
Hot Tier (DV05 - SSD):
  - Real-time logs (last 7 days)
  - Active alerts
  - UEBA working data
  - Recent anomalies
  - Metrics (last 30 days)
  
  Storage: 500GB NVMe
  Query Performance: < 50ms
  Retention: 7 days
  
Warm Tier (DV06 - SSD):
  - Historical logs (8-30 days)
  - Closed incidents
  - Compliance data
  - Archived dashboards
  
  Storage: 500GB SSD
  Query Performance: < 200ms
  Retention: 30 days

Cold Tier (DV06 - HDD + MinIO):
  - Long-term logs (31-180 days)
  - Compliance archives
  - Forensic data
  - Backup data
  
  Storage: 2TB HDD + MinIO S3
  Query Performance: < 2s
  Retention: 180 days

Glacier (DO Spaces / AWS S3):
  - Legal hold data
  - Compliance archives (> 180 days)
  - Disaster recovery backups
  
  Storage: Unlimited (cloud)
  Query Performance: minutes to hours
  Retention: 7 years (configurable)
```

### Index Lifecycle Management

```json
{
  "policy": {
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_size": "50GB",
            "max_age": "1d"
          },
          "set_priority": {
            "priority": 100
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "allocate": {
            "require": {
              "data": "warm"
            }
          },
          "forcemerge": {
            "max_num_segments": 1
          },
          "set_priority": {
            "priority": 50
          }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "allocate": {
            "require": {
              "data": "cold"
            }
          },
          "freeze": {},
          "searchable_snapshot": {
            "snapshot_repository": "minio-backup"
          }
        }
      },
      "delete": {
        "min_age": "180d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

---

## 🔐 Advanced Security Features

### 1. Deception Technology

```yaml
Honeypots:
  SSH Honeypot (Cowrie):
    location: DMZ
    purpose: Detect SSH brute force
    alerts: Real-time to SOC
    
  Web Honeypot:
    location: DV04
    purpose: Detect web attacks
    fake_endpoints:
      - /admin
      - /wp-admin
      - /phpmyadmin
      - /.env
    
  Database Honeypot:
    location: DV05
    purpose: Detect SQL injection
    fake_credentials: yes
    
  File Honeypot (Canary Tokens):
    location: All servers
    purpose: Detect unauthorized access
    types:
      - Fake SSH keys
      - Fake AWS credentials
      - Fake database backups
      - Fake source code

Honey Tokens:
  - Fake user accounts (never login)
  - Fake API keys (trigger alert)
  - Fake database records
  - Fake files with sensitive names
  
Alerts:
  - Any access to honeypot = HIGH alert
  - Automatic IP blocking
  - Threat intel feed update
  - Incident creation in TheHive
```

### 2. Threat Hunting Platform

```yaml
Jupyter Notebook Server (DV06):
  Purpose:
    - Interactive threat hunting
    - Custom analytics
    - ML model development
    - Investigation notebooks
    
  Pre-installed Libraries:
    - pandas, numpy, scipy
    - scikit-learn, tensorflow
    - matplotlib, seaborn, plotly
    - requests, elasticsearch-py
    - pymisp, pytaxii
    - yara-python
    
  Custom Notebooks:
    - User behavior analysis
    - Network traffic analysis
    - Malware analysis
    - Threat intelligence correlation
    - Incident response playbooks
    
  Data Access:
    - OpenSearch (via API)
    - PostgreSQL (read-only)
    - MISP API
    - File system access
    
  Security:
    - Authentication required
    - SSL/TLS encrypted
    - Audit logging
    - Session timeout
    - IP whitelist

Apache Zeppelin (Alternative):
  - Multi-language support (Python, SQL, Scala)
  - Collaborative notebooks
  - Spark integration
  - Scheduled execution
```

### 3. Security Orchestration (SOAR)

```yaml
TheHive + Cortex Stack:
  
  TheHive (Case Management):
    Features:
      - Alert aggregation
      - Case templates
      - Task management
      - Observables tracking
      - TTPs mapping (MITRE ATT&CK)
      - Timeline visualization
      - Collaboration
      - Reporting
    
    Integrations:
      - Wazuh (alerts)
      - UEBA engine (anomalies)
      - DLP (violations)
      - Email (notifications)
      - Slack/Teams (collaboration)
    
    Workflows:
      1. Alert received → Case created
      2. Case assigned → Analyst notified
      3. Investigation → Observables enriched
      4. Resolution → Playbook executed
      5. Closure → Report generated
  
  Cortex (Analysis & Response):
    Analyzers:
      - VirusTotal (file/URL analysis)
      - AbuseIPDB (IP reputation)
      - Shodan (IP/domain intel)
      - MISP (threat correlation)
      - PassiveTotal (DNS/WHOIS)
      - MaxMind (GeoIP)
      - Custom analyzers
    
    Responders:
      - Block IP (firewall)
      - Isolate host (network)
      - Kill process
      - Reset password
      - Disable account
      - Send notification
      - Create ticket
      - Custom actions

Shuffle (Workflow Automation):
  Purpose:
    - No-code workflow builder
    - API integrations
    - Conditional logic
    - Scheduled tasks
  
  Use Cases:
    - Automated triage
    - Enrichment pipeline
    - Response playbooks
    - Report generation
    - Ticket creation
```

### 4. Adversary Emulation

```yaml
Atomic Red Team:
  Purpose: Test detection capabilities
  
  Tests:
    - T1003: Credential Dumping
    - T1055: Process Injection
    - T1059: Command Execution
    - T1071: Application Layer Protocol
    - T1087: Account Discovery
    - T1110: Brute Force
    - T1136: Create Account
    - T1482: Domain Trust Discovery
    
  Execution:
    - Scheduled weekly
    - Safe environment (isolated)
    - Results logged
    - Detection gaps identified

Caldera (MITRE):
  Purpose: Automated adversary emulation
  
  Features:
    - Red team operations
    - Purple team exercises
    - Attack chain simulation
    - Autonomous operations
    
  Integrations:
    - MITRE ATT&CK
    - Detection logging
    - Automated reporting

Purple Team Exercises:
  Frequency: Monthly
  
  Process:
    1. Plan attack scenario
    2. Execute attack (Red)
    3. Monitor detection (Blue)
    4. Document gaps
    5. Improve detections
    6. Re-test
```

---

## 📊 Advanced Analytics

### 1. Predictive Analytics

```python
# Predictive risk scoring with time-series forecasting

from prophet import Prophet
import pandas as pd

class RiskForecaster:
    def __init__(self, opensearch_client):
        self.os = opensearch_client
        
    def forecast_user_risk(self, username, days_ahead=7):
        """
        Predict future risk score for a user
        """
        # Fetch historical risk scores
        query = {
            "bool": {
                "must": [
                    {"term": {"username": username}},
                    {"range": {"timestamp": {"gte": "now-90d"}}}
                ]
            }
        }
        
        results = self.os.search(
            index="ueba-risk-scores-*",
            query=query,
            size=10000,
            sort=[{"timestamp": "asc"}]
        )
        
        # Prepare data for Prophet
        df = pd.DataFrame([
            {
                'ds': hit['_source']['timestamp'],
                'y': hit['_source']['risk_score']
            }
            for hit in results['hits']['hits']
        ])
        
        # Train model
        model = Prophet(
            daily_seasonality=True,
            weekly_seasonality=True,
            yearly_seasonality=False
        )
        model.fit(df)
        
        # Make prediction
        future = model.make_future_dataframe(periods=days_ahead)
        forecast = model.predict(future)
        
        return {
            'current_risk': df['y'].iloc[-1],
            'predicted_risk': forecast['yhat'].iloc[-1],
            'trend': 'increasing' if forecast['yhat'].iloc[-1] > df['y'].iloc[-1] else 'decreasing',
            'confidence': (forecast['yhat_upper'].iloc[-1] - forecast['yhat_lower'].iloc[-1]) / 2
        }
    
    def predict_incidents(self, days_ahead=30):
        """
        Predict number of security incidents
        """
        # Similar implementation for incident forecasting
        pass
    
    def capacity_planning(self, metric='cpu', days_ahead=90):
        """
        Predict resource usage for capacity planning
        """
        # Forecast CPU/Memory/Disk usage
        pass
```

### 2. Graph Analytics

```python
# Network relationship analysis using graph theory

import networkx as nx
from pyvis.network import Network

class ThreatGraphAnalyzer:
    def __init__(self, opensearch_client):
        self.os = opensearch_client
        self.graph = nx.DiGraph()
    
    def build_attack_graph(self, incident_id):
        """
        Build graph of attack progression
        """
        # Fetch all events related to incident
        events = self.get_incident_events(incident_id)
        
        for event in events:
            # Add nodes (users, hosts, IPs, files)
            self.add_entity_nodes(event)
            
            # Add edges (connections, accesses, transfers)
            self.add_relationships(event)
        
        return self.graph
    
    def find_lateral_movement(self):
        """
        Detect lateral movement patterns
        """
        # Find paths from external IPs to critical assets
        external_nodes = [n for n, d in self.graph.nodes(data=True) 
                         if d.get('type') == 'external_ip']
        critical_assets = [n for n, d in self.graph.nodes(data=True)
                          if d.get('criticality') == 'high']
        
        paths = []
        for ext in external_nodes:
            for asset in critical_assets:
                try:
                    path = nx.shortest_path(self.graph, ext, asset)
                    paths.append({
                        'source': ext,
                        'target': asset,
                        'path': path,
                        'hops': len(path) - 1
                    })
                except nx.NetworkXNoPath:
                    continue
        
        return paths
    
    def identify_pivot_points(self):
        """
        Find critical nodes that enable lateral movement
        """
        # Calculate betweenness centrality
        centrality = nx.betweenness_centrality(self.graph)
        
        # Sort by centrality
        pivot_points = sorted(
            centrality.items(),
            key=lambda x: x[1],
            reverse=True
        )[:10]
        
        return pivot_points
    
    def visualize_attack(self, output_file='attack_graph.html'):
        """
        Create interactive visualization
        """
        net = Network(height='800px', width='100%', directed=True)
        
        # Add nodes with colors based on type
        for node, data in self.graph.nodes(data=True):
            color = self.get_node_color(data['type'])
            net.add_node(node, label=node, color=color, **data)
        
        # Add edges
        for source, target, data in self.graph.edges(data=True):
            net.add_edge(source, target, **data)
        
        net.show(output_file)
```

### 3. Behavioral Clustering

```python
# Group users by behavior patterns

from sklearn.cluster import DBSCAN, KMeans
from sklearn.preprocessing import StandardScaler
import numpy as np

class BehaviorClusterer:
    def __init__(self, opensearch_client):
        self.os = opensearch_client
        
    def cluster_users(self, n_clusters=5):
        """
        Group users into behavioral clusters
        """
        # Get user features
        users_features = self.extract_user_features()
        
        # Normalize features
        scaler = StandardScaler()
        features_scaled = scaler.fit_transform(users_features.values)
        
        # Cluster using K-Means
        kmeans = KMeans(n_clusters=n_clusters, random_state=42)
        clusters = kmeans.fit_predict(features_scaled)
        
        # Add cluster labels to users
        users_features['cluster'] = clusters
        
        # Analyze clusters
        cluster_profiles = self.profile_clusters(users_features)
        
        return {
            'clusters': users_features,
            'profiles': cluster_profiles,
            'outliers': self.find_outliers(features_scaled, clusters)
        }
    
    def find_outliers(self, features, clusters):
        """
        Find users that don't fit their cluster well
        """
        outliers = []
        
        for cluster_id in np.unique(clusters):
            cluster_members = features[clusters == cluster_id]
            
            # Use DBSCAN to find outliers within cluster
            dbscan = DBSCAN(eps=0.5, min_samples=3)
            labels = dbscan.fit_predict(cluster_members)
            
            # -1 label indicates outlier
            outlier_indices = np.where(labels == -1)[0]
            outliers.extend(outlier_indices)
        
        return outliers
    
    def detect_peer_group_anomalies(self, username):
        """
        Compare user to their peer group
        """
        # Get user's cluster
        user_cluster = self.get_user_cluster(username)
        
        # Get peer group (same cluster)
        peers = self.get_cluster_members(user_cluster)
        
        # Calculate Z-scores for each metric
        user_metrics = self.get_user_metrics(username)
        peer_metrics = [self.get_user_metrics(p) for p in peers]
        
        anomalies = []
        for metric in user_metrics.keys():
            peer_values = [p[metric] for p in peer_metrics]
            mean = np.mean(peer_values)
            std = np.std(peer_values)
            
            z_score = (user_metrics[metric] - mean) / std
            
            if abs(z_score) > 3:  # 3 sigma threshold
                anomalies.append({
                    'metric': metric,
                    'user_value': user_metrics[metric],
                    'peer_mean': mean,
                    'z_score': z_score,
                    'severity': 'high' if abs(z_score) > 4 else 'medium'
                })
        
        return anomalies
```

---

## 🎯 Integration with Business Systems

### Vendure Integration

```python
# Monitor e-commerce specific security events

class VendureSecurityMonitor:
    def __init__(self, vendure_api_url, opensearch_client):
        self.api = vendure_api_url
        self.os = opensearch_client
    
    def monitor_suspicious_orders(self):
        """
        Detect potentially fraudulent orders
        """
        suspicious_patterns = [
            {
                'name': 'high_value_new_customer',
                'conditions': {
                    'order_total': {'gt': 1000},
                    'customer_orders_count': {'eq': 1},
                    'shipping_country': {'ne': 'billing_country'}
                }
            },
            {
                'name': 'velocity_abuse',
                'conditions': {
                    'orders_last_hour': {'gt': 5},
                    'failed_payments': {'gt': 2}
                }
            },
            {
                'name': 'account_takeover_indicator',
                'conditions': {
                    'password_changed': {'within': '1h'},
                    'shipping_address_changed': True,
                    'large_order': {'gt': 500}
                }
            }
        ]
        
        alerts = []
        for pattern in suspicious_patterns:
            matches = self.query_vendure(pattern['conditions'])
            if matches:
                alerts.append({
                    'type': pattern['name'],
                    'severity': 'high',
                    'orders': matches,
                    'recommended_action': 'manual_review'
                })
        
        return alerts
    
    def detect_scraping(self):
        """
        Detect product catalog scraping
        """
        # Analyze API call patterns
        query = {
            "bool": {
                "must": [
                    {"term": {"api_endpoint": "products"}},
                    {"range": {"timestamp": {"gte": "now-1h"}}}
                ]
            }
        }
        
        agg = {
            "by_ip": {
                "terms": {"field": "source_ip", "size": 100},
                "aggs": {
                    "requests_per_minute": {
                        "rate": {
                            "unit": "minute"
                        }
                    }
                }
            }
        }
        
        results = self.os.search(
            index="vendure-api-logs-*",
            query=query,
            aggs=agg
        )
        
        scrapers = []
        for bucket in results['aggregations']['by_ip']['buckets']:
            rpm = bucket['requests_per_minute']['value']
            if rpm > 60:  # More than 1 request per second
                scrapers.append({
                    'ip': bucket['key'],
                    'requests_per_minute': rpm,
                    'total_requests': bucket['doc_count'],
                    'action': 'rate_limit_or_block'
                })
        
        return scrapers
    
    def monitor_admin_actions(self):
        """
        Track sensitive admin operations
        """
        sensitive_actions = [
            'user.create',
            'user.delete',
            'product.delete',
            'order.cancel',
            'settings.update',
            'payment.refund'
        ]
        
        alerts = []
        for action in sensitive_actions:
            events = self.get_admin_events(action)
            
            # Check for unusual patterns
            if self.is_unusual(events):
                alerts.append({
                    'action': action,
                    'events': events,
                    'severity': 'medium',
                    'requires_review': True
                })
        
        return alerts
```

### ERP/CRM Integration (Future)

```python
# Monitor business system access and data movement

class BusinessSystemMonitor:
    def __init__(self, systems):
        self.erp = systems.get('erpnext')
        self.crm = systems.get('twenty')
        
    def monitor_financial_data_access(self):
        """
        Track access to financial records
        """
        # Monitor who accesses P&L, balance sheets, etc.
        pass
    
    def detect_customer_data_exfiltration(self):
        """
        Detect mass export of customer data
        """
        # Monitor CRM bulk exports
        pass
    
    def track_quote_to_cash_anomalies(self):
        """
        Detect suspicious sales activities
        """
        # Unusual discounts, payment terms, etc.
        pass
```

---

## 📱 Mobile & Remote Access Monitoring

```yaml
Mobile Device Management:
  Policies:
    - Device enrollment required
    - Encryption mandatory
    - Remote wipe capability
    - App whitelist/blacklist
    - Jailbreak/root detection
  
  Monitoring:
    - Device location tracking
    - App usage monitoring
    - Data transfer logging
    - Suspicious app installation
    - Policy violations

VPN Monitoring:
  Metrics:
    - Connection success rate
    - Bandwidth usage
    - Session duration
    - Concurrent connections
    - Geographic distribution
  
  Security:
    - Failed authentication attempts
    - Unusual connection times
    - Impossible travel detection
    - Multiple simultaneous connections
    - Protocol anomalies

Remote Desktop Monitoring:
  Session Recording:
    - Screen capture (policy-based)
    - Keystroke logging (if enabled)
    - File transfers
    - Clipboard operations
    - Application usage
  
  Alerts:
    - Off-hours access
    - Sensitive data access
    - Unusual commands
    - Lateral movement
    - Privilege escalation
```

---

## 🎓 Training & Documentation

### SOC Runbooks

```yaml
Incident Response Playbooks:
  - Malware Infection
  - Phishing Attack
  - Data Breach
  - Insider Threat
  - DDoS Attack
  - Ransomware
  - Account Compromise
  - Privilege Escalation
  - Data Exfiltration
  - Supply Chain Attack

Investigation Guides:
  - Timeline Analysis
  - Memory Forensics
  - Network Forensics
  - Log Analysis
  - Malware Analysis
  - User Behavior Analysis

SOC Analyst Training:
  Level 1 (Triage):
    - Alert monitoring
    - Initial triage
    - Ticket creation
    - Basic investigation
    - Escalation procedures
  
  Level 2 (Investigation):
    - Deep dive analysis
    - Threat hunting
    - Correlation
    - Evidence collection
    - Report writing
  
  Level 3 (Expert):
    - Advanced forensics
    - Malware reverse engineering
    - Threat intelligence
    - Tool development
    - Training others
```

---

## 🔮 Future Enhancements

### AI/ML Advanced Features

```yaml
Natural Language Processing:
  - Log anomaly detection using transformers
  - Automated report generation
  - Chatbot for SOC queries
  - Threat intelligence extraction from text

Computer Vision:
  - Screenshot analysis for DLP
  - Anomalous UI behavior detection
  - Visual reconnaissance detection

Reinforcement Learning:
  - Automated response optimization
  - Alert prioritization learning
  - Attack simulation improvement

Federated Learning:
  - Cross-organization threat sharing
  - Privacy-preserving ML models
  - Collaborative detection improvement
```

---

## 💰 Cost Comparison

### Commercial Solutions (Annual)

```
Exabeam: $50,000 - $200,000
ObserveIT: $150,000 (1000 users)
Teramind: $120,000 (1000 users)
Splunk Enterprise Security: $150,000+
CrowdStrike: $100,000+
Palo Alto Cortex XDR: $200,000+

Total Commercial: $770,000+/year
```

### Our Open Source Stack

```
Hardware (one-time):
  - Already owned (DV02-DV06): $0
  - Network equipment: $500

Software:
  - All open source: $0

Cloud (monthly):
  - DO VPS: $12/month = $144/year
  - Backup storage: $5/month = $60/year

Personnel (assuming you're building it):
  - Learning time: priceless
  - Maintenance: 10 hours/month

Total: ~$700/year (99% savings!)
```

---

## ✅ Summary

We've designed a **complete Security Operations Platform** that rivals commercial solutions:

**Capabilities:**
- ✅ SOC (Security Operations Center)
- ✅ NOC (Network Operations Center)
- ✅ DLP (Data Loss Prevention)
- ✅ UEBA (User/Entity Behavior Analytics)
- ✅ SIEM (Security Information & Event Management)
- ✅ SOAR (Security Orchestration & Automated Response)
- ✅ Threat Intelligence
- ✅ Incident Response
- ✅ Compliance Monitoring
- ✅ Forensics Capabilities
- ✅ CI/CD Security Pipeline

**Technology Stack:**
- OpenSearch (instead of Elasticsearch)
- Wazuh (SIEM/HIDS)
- Custom UEBA Engine (Python + ML)
- Custom DLP System
- TheHive + Cortex (SOAR)
- Gitea + Drone (CI/CD)
- Prometheus + Grafana (Monitoring)
- And much more...

**Cost:** 99% cheaper than commercial solutions
**Control:** 100% owned by you
**Learning:** Invaluable experience
**Scalability:** Grows with your business

This system will give you **enterprise-grade security** for your Entrepreneur OS cloud! 🚀🔒