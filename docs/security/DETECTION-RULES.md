# Detection Rules

> **Entrepreneur OS Security Platform**  
> Comprehensive detection rules for threats, anomalies, and policy violations

## 📋 Table of Contents

- [Overview](#overview)
- [Rule Framework](#rule-framework)
- [Wazuh Rules](#wazuh-rules)
- [Sigma Rules](#sigma-rules)
- [UEBA Rules](#ueba-rules)
- [DLP Policies](#dlp-policies)
- [Network Detection Rules](#network-detection-rules)
- [Custom Application Rules](#custom-application-rules)
- [Rule Management](#rule-management)
- [Testing & Validation](#testing--validation)

---

## Overview

### Detection Philosophy

```yaml
Principles:
  - Defense in depth (multiple detection layers)
  - High signal-to-noise ratio (minimize false positives)
  - Context-aware (consider user, asset, time)
  - Adaptable (learn from feedback)
  - Actionable (clear next steps)

Detection Layers: 1. Signature-based (known threats)
  2. Anomaly-based (unusual behavior)
  3. Behavioral (user/entity patterns)
  4. Threat intelligence (known IOCs)
  5. ML-based (learned patterns)
```

### Rule Lifecycle

```
Create → Test → Deploy → Monitor → Tune → Update → Archive
  ↑                                                      |
  └──────────────────────────────────────────────────────┘
```

### Severity Levels

| Level             | Score | Description                          | Response Time | Escalation      |
| ----------------- | ----- | ------------------------------------ | ------------- | --------------- |
| **Informational** | 0-3   | FYI events, normal activity          | N/A           | None            |
| **Low**           | 4-5   | Minor issues, potential indicators   | 24 hours      | Optional        |
| **Medium**        | 6-8   | Suspicious activity, requires review | 4 hours       | SOC L1          |
| **High**          | 9-11  | Likely security incident             | 1 hour        | SOC L2          |
| **Critical**      | 12-15 | Confirmed breach, immediate action   | 15 minutes    | SOC Lead + CISO |

---

## Rule Framework

### Rule Structure

```yaml
rule:
  id: unique-identifier
  name: Human-readable name
  description: What this rule detects
  author: Rule creator
  date: Creation date
  version: 1.0

  severity: critical|high|medium|low|info
  confidence: high|medium|low

  mitre_attack:
    tactic: [TA0001, TA0002]
    technique: [T1078, T1110]
    sub_technique: [T1078.001]

  data_sources:
    - System logs
    - Application logs
    - Network traffic

  detection:
    selection:
      field1: value1
      field2: value2
    condition: selection

  false_positives:
    - Legitimate scenario 1
    - Legitimate scenario 2

  response:
    - Action 1
    - Action 2

  references:
    - https://attack.mitre.org/
```

### MITRE ATT&CK Mapping

All rules mapped to [MITRE ATT&CK Framework](https://attack.mitre.org/)

```yaml
Coverage Goals:
  Initial Access: 80%
  Execution: 85%
  Persistence: 75%
  Privilege Escalation: 80%
  Defense Evasion: 70%
  Credential Access: 90%
  Discovery: 75%
  Lateral Movement: 85%
  Collection: 80%
  Command and Control: 75%
  Exfiltration: 90%
  Impact: 80%
```

---

## Wazuh Rules

### Authentication Rules

#### Failed SSH Authentication (Brute Force)

```xml
<rule id="100001" level="10">
  <if_sid>5551</if_sid>
  <match>authentication failure|Failed password</match>
  <same_source_ip />
  <frequency>5</frequency>
  <timeframe>300</timeframe>
  <description>Multiple SSH authentication failures from same IP</description>
  <mitre>
    <id>T1110</id>
    <id>T1110.001</id>
  </mitre>
  <group>authentication_failures,brute_force,</group>
</rule>
```

**Triggers:** 5+ failed SSH logins from same IP in 5 minutes  
**Action:** Block IP via fail2ban, alert SOC  
**False Positives:** Users with wrong passwords

#### Successful Login After Multiple Failures

```xml
<rule id="100002" level="12">
  <if_sid>100001</if_sid>
  <match>Accepted password</match>
  <description>Successful login after brute force attempt</description>
  <mitre>
    <id>T1110</id>
  </mitre>
  <group>authentication_success,brute_force,</group>
</rule>
```

**Triggers:** Successful login within 1 hour of brute force  
**Action:** Alert SOC (HIGH), investigate account  
**False Positives:** Legitimate user after typos

#### Impossible Travel

```xml
<rule id="100003" level="13">
  <decoded_as>json</decoded_as>
  <field name="event.type">authentication</field>
  <field name="event.outcome">success</field>
  <script>impossible_travel.py</script>
  <description>User login from geographically impossible location</description>
  <mitre>
    <id>T1078</id>
  </mitre>
  <group>authentication,anomaly,</group>
</rule>
```

**Triggers:** Login from 2 locations >1000km apart in <2 hours  
**Action:** Alert SOC (CRITICAL), require MFA re-auth  
**False Positives:** VPN usage, travel

### System Integrity Rules

#### File Integrity Monitoring

```xml
<rule id="100010" level="7">
  <if_sid>550</if_sid>
  <field name="file">/etc/passwd</field>
  <description>Critical system file modified</description>
  <mitre>
    <id>T1098</id>
  </mitre>
  <group>syscheck,system_integrity,</group>
</rule>

<rule id="100011" level="12">
  <if_sid>550</if_sid>
  <field name="file">/etc/shadow</field>
  <description>Password file modified</description>
  <mitre>
    <id>T1003</id>
    <id>T1098</id>
  </mitre>
  <group>syscheck,system_integrity,credential_access,</group>
</rule>
```

**Triggers:** Changes to critical system files  
**Action:** Alert SOC, snapshot for forensics  
**False Positives:** System updates, legitimate admin changes

#### Suspicious Process Execution

```xml
<rule id="100020" level="10">
  <decoded_as>syscollector</decoded_as>
  <field name="process.name">nc|ncat|netcat</field>
  <description>Netcat execution detected</description>
  <mitre>
    <id>T1059</id>
  </mitre>
  <group>process_monitoring,command_execution,</group>
</rule>

<rule id="100021" level="12">
  <decoded_as>syscollector</decoded_as>
  <field name="process.name">mimikatz</field>
  <description>Credential dumping tool detected</description>
  <mitre>
    <id>T1003</id>
  </mitre>
  <group>process_monitoring,credential_access,</group>
</rule>
```

**Triggers:** Execution of known hacking tools  
**Action:** Kill process, isolate host, alert SOC  
**False Positives:** Security testing (whitelisted users)

### Malware Detection

#### YARA Rule Integration

```xml
<rule id="100030" level="13">
  <decoded_as>yara</decoded_as>
  <field name="yara.rule_match">true</field>
  <description>Malware detected by YARA</description>
  <mitre>
    <id>T1204</id>
  </mitre>
  <group>malware,yara,</group>
</rule>
```

**Triggers:** YARA rule matches malware signature  
**Action:** Quarantine file, alert SOC, scan system  
**False Positives:** False YARA matches (rare)

---

## Sigma Rules

Sigma rules are converted to OpenSearch queries using `sigmac`.

### Credential Dumping

```yaml
title: Credential Dumping via Mimikatz
id: a642964e-bead-4bed-8910-1bb4d63e3b4d
status: stable
description: Detects execution of Mimikatz credential dumping tool
author: Entrepreneur OS Security Team
date: 2024/11/15
references:
  - https://attack.mitre.org/techniques/T1003/
logsource:
  category: process_creation
  product: linux
detection:
  selection:
    CommandLine|contains:
      - 'mimikatz'
      - 'sekurlsa::logonpasswords'
      - 'lsadump::sam'
  condition: selection
falsepositives:
  - Penetration testing (authorized)
  - Security research in isolated environment
level: critical
tags:
  - attack.credential_access
  - attack.t1003
```

**OpenSearch Query:**

```json
{
  "query": {
    "bool": {
      "should": [
        { "wildcard": { "command_line": "*mimikatz*" } },
        { "wildcard": { "command_line": "*sekurlsa::logonpasswords*" } },
        { "wildcard": { "command_line": "*lsadump::sam*" } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

### Lateral Movement

```yaml
title: Suspicious SSH to Multiple Hosts
id: 8b3b3f3e-2e2e-4e4e-8e8e-9e9e9e9e9e9e
status: experimental
description: Detects SSH connections to unusual number of hosts
author: Entrepreneur OS Security Team
date: 2024/11/15
logsource:
  category: network_connection
  product: linux
detection:
  selection:
    destination_port: 22
    connection_status: established
  timeframe: 1h
  condition: selection | count(destination_ip) by source_ip > 5
falsepositives:
  - System administrators
  - Automated deployment scripts
level: high
tags:
  - attack.lateral_movement
  - attack.t1021.004
```

### Data Exfiltration

```yaml
title: Large Data Upload to Cloud Storage
id: 7c7c7c7c-7c7c-7c7c-7c7c-7c7c7c7c7c7c
status: stable
description: Detects large data uploads to cloud storage services
author: Entrepreneur OS Security Team
date: 2024/11/15
logsource:
  category: network_traffic
  product: suricata
detection:
  selection:
    destination_fqdn|endswith:
      - '.dropbox.com'
      - '.drive.google.com'
      - '.onedrive.live.com'
      - '.box.com'
    bytes_sent: '>10485760' # 10MB
  timeframe: 1h
  condition: selection | sum(bytes_sent) by source_ip > 104857600 # 100MB
falsepositives:
  - Legitimate cloud backups
  - Large file sharing (business need)
level: high
tags:
  - attack.exfiltration
  - attack.t1567
```

---

## UEBA Rules

### Behavioral Anomaly Rules

#### After-Hours Access

```yaml
rule_id: ueba_001
name: After-Hours Sensitive Data Access
description: User accessing sensitive data outside business hours
severity: high
confidence: medium

conditions:
  - user.access_time NOT IN business_hours (09:00-18:00 Mon-Fri)
  - file.classification IN [confidential, secret]
  - user.role NOT IN [admin, security, on_call]
  - user.baseline.after_hours_access = false

scoring:
  base_score: 30
  factors:
    - file_sensitivity: +20
    - user_history: +10
    - time_of_day: +10
  max_score: 70

actions:
  - alert: soc_team
  - log: opensearch
  - increase_user_risk: 30
  - require_justification: true

false_positives:
  - Emergency work
  - On-call duties
  - Different time zones
```

#### Mass File Download

```yaml
rule_id: ueba_002
name: Unusual File Download Volume
description: User downloading significantly more files than normal
severity: critical
confidence: high

conditions:
  - file.download_count > user.baseline.download_count * 3
  - time_window: 1h
  - file.type IN [document, spreadsheet, database]

scoring:
  base_score: 40
  factors:
    - download_volume: +30
    - file_sensitivity: +20
    - user_role: +10
  max_score: 100

actions:
  - alert: soc_immediate
  - block_future_downloads: 30m
  - increase_user_risk: 50
  - create_incident: thehive
  - notify: user_manager

false_positives:
  - Data migration
  - Backup operations
  - Legitimate bulk downloads
```

#### Privilege Escalation

```yaml
rule_id: ueba_003
name: Suspicious Privilege Escalation
description: User attempting to access resources above privilege level
severity: critical
confidence: high

conditions:
  - access.resource_level > user.privilege_level
  - access.denied = true
  - attempt_count > 3 IN 10m

scoring:
  base_score: 50
  factors:
    - resource_criticality: +30
    - user_history: +20
  max_score: 100

actions:
  - alert: soc_immediate
  - temporary_account_lock: 30m
  - increase_user_risk: 60
  - create_incident: thehive
  - notify: security_team

false_positives:
  - Misconfigured permissions
  - Role change pending
```

### Peer Group Anomaly

```yaml
rule_id: ueba_010
name: Deviation from Peer Group Behavior
description: User behavior significantly different from peers
severity: medium
confidence: medium

conditions:
  - user.activity_score > peer_group.avg + (3 * peer_group.std_dev)
  - peer_group = same_department OR same_role
  - metrics: [login_count, file_access, data_transfer]

scoring:
  base_score: 20
  factors:
    - deviation_magnitude: +15
    - metric_criticality: +10
  max_score: 45

actions:
  - alert: soc_team
  - log: opensearch
  - increase_user_risk: 20
  - flag_for_review: true

false_positives:
  - New employees
  - Role changes
  - Project-based work
```

---

## DLP Policies

### Sensitive Data Patterns

#### Personal Identifiable Information (PII)

```yaml
policy_id: dlp_001
name: Social Security Number Protection
description: Detect and protect SSN in documents and transfers
enabled: true
severity: high

patterns:
  - name: ssn_format_1
    regex: '\b\d{3}-\d{2}-\d{4}\b'
    confidence: high

  - name: ssn_format_2
    regex: '\b\d{9}\b'
    confidence: medium
    additional_check: luhn_algorithm

actions:
  alert: true
  block: true
  encrypt: true
  notify: [compliance_team, data_owner]

exceptions:
  - user.department = HR
  - file.location = /secure/hr/
  - user.has_permission = pii_access

logging:
  log_content: false # Privacy compliance
  log_metadata: true
  retention: 7_years
```

#### Credit Card Numbers

```yaml
policy_id: dlp_002
name: Credit Card Data Protection
description: Detect credit card numbers in transit
enabled: true
severity: critical

patterns:
  - name: visa
    regex: '\b4[0-9]{12}(?:[0-9]{3})?\b'
    validate: luhn_check

  - name: mastercard
    regex: '\b5[1-5][0-9]{14}\b'
    validate: luhn_check

  - name: amex
    regex: '\b3[47][0-9]{13}\b'
    validate: luhn_check

actions:
  alert: true
  block: true
  redact: true
  notify: [security_team, compliance]
  create_incident: true

exceptions:
  - service.name = payment_processor
  - connection.encrypted = true
  - user.role = finance_admin

logging:
  log_content: false
  log_metadata: true
  retention: 10_years # PCI-DSS requirement
```

### Data Movement Policies

#### Prevent Source Code Exfiltration

```yaml
policy_id: dlp_010
name: Source Code Protection
description: Prevent unauthorized source code transfer
enabled: true
severity: high

conditions:
  file_extensions: [.py, .js, .java, .cpp, .go, .rs]
  contains_keywords: [proprietary, confidential, internal]
  transfer_destination: external
  transfer_method: [email, usb, cloud_upload]

actions:
  block: true
  alert: true
  increase_user_risk: 40
  require_approval: [manager, security]

exceptions:
  - user.role IN [developer, devops]
  - destination IN approved_repos
  - has_approval = true

logging:
  log_content: true # For investigation
  log_metadata: true
  retention: 3_years
```

#### Database Dump Prevention

```yaml
policy_id: dlp_011
name: Database Dump Protection
description: Detect and prevent unauthorized database dumps
enabled: true
severity: critical

conditions:
  - file.type = sql_dump
  OR command.contains: [pg_dump, mysqldump, mongodump]
  - destination = external OR removable_media
  - user.role NOT IN [dba, backup_admin]

actions:
  block: true
  alert: soc_immediate
  kill_process: true
  increase_user_risk: 60
  create_incident: true

exceptions:
  - process.name = backup_script
  - destination = approved_backup_location
  - time IN maintenance_window

logging:
  log_content: false
  log_command: true
  log_metadata: true
  retention: 7_years
```

---

## Network Detection Rules

### Suricata Rules

#### Command and Control Communication

```
alert tcp $HOME_NET any -> $EXTERNAL_NET any (
  msg:"Potential C2 Beacon - Suspicious User-Agent";
  flow:established,to_server;
  content:"User-Agent|3a 20|";
  pcre:"/User-Agent\:\s*(curl|wget|python|powershell)/i";
  threshold:type threshold, track by_src, count 10, seconds 60;
  classtype:trojan-activity;
  sid:1000001;
  rev:1;
  metadata:attack_target Client_Endpoint, deployment Perimeter;
  reference:url,attack.mitre.org/techniques/T1071;
)
```

#### DNS Tunneling

```
alert dns $HOME_NET any -> any 53 (
  msg:"Potential DNS Tunneling - Excessive Subdomain Levels";
  dns_query;
  content:".";
  isdataat:!1,relative;
  pcre:"/^([a-z0-9\-]+\.){10,}/i";
  threshold:type threshold, track by_src, count 5, seconds 60;
  classtype:policy-violation;
  sid:1000002;
  rev:1;
  reference:url,attack.mitre.org/techniques/T1071.004;
)
```

#### Port Scanning

```
alert tcp any any -> $HOME_NET any (
  msg:"Port Scan Detected";
  flags:S;
  threshold:type threshold, track by_src, count 20, seconds 60;
  classtype:attempted-recon;
  sid:1000003;
  rev:1;
  reference:url,attack.mitre.org/techniques/T1046;
)
```

### Zeek Scripts

#### Detect Cryptocurrency Mining

```zeek
# crypto_mining.zeek
@load base/protocols/conn
@load base/frameworks/notice

module CryptoMining;

export {
  redef enum Notice::Type += {
    Potential_Crypto_Mining
  };

  const mining_ports: set[port] = {
    3333/tcp,  # Stratum
    4444/tcp,  # Stratum SSL
    5555/tcp,  # Stratum
    7777/tcp,  # NiceHash
    9999/tcp   # XMRig
  } &redef;
}

event connection_established(c: connection) {
  if (c$id$resp_p in mining_ports) {
    NOTICE([
      $note=Potential_Crypto_Mining,
      $conn=c,
      $msg=fmt("Potential crypto mining to %s:%s",
        c$id$resp_h, c$id$resp_p),
      $identifier=cat(c$id$orig_h, c$id$resp_h, c$id$resp_p)
    ]);
  }
}
```

---

## Custom Application Rules

### Vendure E-commerce Rules

#### Suspicious Order Pattern

```yaml
rule_id: app_vendure_001
name: High-Value Order from New Customer
description: Detect potentially fraudulent high-value orders
severity: high
enabled: true

conditions:
  - order.total > 1000
  - customer.orders_count = 1
  - customer.account_age < 24h
  - shipping.country != billing.country

actions:
  - flag_for_manual_review: true
  - alert: fraud_team
  - hold_shipment: true
  - require_verification: true

false_positives:
  - Legitimate high-value first purchase
  - Corporate orders
```

#### Product Catalog Scraping

```yaml
rule_id: app_vendure_002
name: API Scraping Detection
description: Detect automated scraping of product catalog
severity: medium
enabled: true

conditions:
  - api.endpoint = products
  - request_rate > 60/minute
  - user_agent IN [curl, wget, python, scrapy]
  OR user_agent = empty

actions:
  - rate_limit: 10/minute for 1h
  - alert: security_team
  - log: detailed
  - captcha_challenge: true

false_positives:
  - Legitimate API clients (whitelisted)
  - Mobile apps
```

### n8n Workflow Monitoring

```yaml
rule_id: app_n8n_001
name: Suspicious Workflow Modification
description: Detect unauthorized changes to n8n workflows
severity: high
enabled: true

conditions:
  - event.type = workflow_update
  - workflow.includes_credentials = true
  - user.role NOT IN [admin, devops]
  OR modification.time IN after_hours

actions:
  - alert: security_team
  - create_audit_log: true
  - require_approval: [manager, security]
  - rollback_option: true

false_positives:
  - Emergency fixes
  - Scheduled maintenance
```

---

## Rule Management

### Rule Deployment Process

```
Development → Testing → Staging → Production
     ↓           ↓          ↓          ↓
   Local     Test Lab   Staging    Production
             Env        Cluster     Cluster
```

### Version Control

```yaml
Repository: github.com/entrepreneur-os/security-rules

Structure: rules/
  wazuh/
  authentication/
  file_integrity/
  malware/
  sigma/
  credential_access/
  lateral_movement/
  exfiltration/
  ueba/
  anomalies/
  peer_groups/
  dlp/
  pii/
  intellectual_property/
  network/
  suricata/
  zeek/
  application/
  vendure/
  n8n/

Branching:
  - main: Production rules
  - develop: Staging rules
  - feature/*: Development

CI/CD:
  - Automated syntax checking
  - Rule testing against datasets
  - Performance impact analysis
  - Automated deployment to staging
  - Manual approval for production
```

### Rule Tuning

```yaml
Metrics to Monitor:
  - True Positive Rate (TPR)
  - False Positive Rate (FPR)
  - Alert Volume
  - Detection Latency
  - Coverage (MITRE ATT&CK)

Tuning Process:
  1. Collect feedback (7 days minimum)
  2. Analyze false positives
  3. Adjust thresholds
  4. Update exceptions
  5. Re-deploy
  6. Monitor improvements

Targets:
  TPR: > 95%
  FPR: < 5%
  Alert Volume: < 100/day
  Detection Latency: < 1 minute
```

---

## Testing & Validation

### Test Datasets

```yaml
Benign Traffic:
  - Normal user activity (100K events)
  - System operations (50K events)
  - Application logs (200K events)

Malicious Traffic:
  - Known attacks (MITRE ATT&CK)
  - Red team exercises
  - Atomic Red Team tests
  - Previous incidents

Validation:
  - Test each rule against both datasets
  - Calculate precision and recall
  - Measure performance impact
  - Verify MITRE ATT&CK mapping
```

### Continuous Testing

```yaml
Frequency: Daily

Automated Tests:
  - Sigma rule syntax validation
  - Wazuh rule syntax validation
  - UEBA rule logic validation
  - Performance benchmarking
  - Coverage analysis

Manual Tests:
  - Red team exercises (monthly)
  - Purple team reviews (quarterly)
  - Rule effectiveness review (quarterly)
```

---

## Appendix

### Rule Development Guidelines

```markdown
1. **Start with MITRE ATT&CK**
   - Identify technique to detect
   - Review detection methods
   - Map to data sources

2. **Define Detection Logic**
   - Clear, specific conditions
   - Avoid overly broad matches
   - Consider context

3. **Set Appropriate Severity**
   - Based on impact + likelihood
   - Consider asset criticality
   - Account for false positive risk

4. **Document Thoroughly**
   - Description
   - False positives
   - Response actions
   - References

5. **Test Before Deployment**
   - Benign data
   - Malicious data
   - Performance impact
   - False positive rate

6. **Monitor and Tune**
   - Collect feedback
   - Adjust thresholds
   - Update exceptions
   - Re-test
```

### Useful Resources

- [Sigma HQ Rules](https://github.com/SigmaHQ/sigma)
- [Wazuh Ruleset](https://github.com/wazuh/wazuh-ruleset)
- [Suricata Rules](https://rules.emergingthreats.net/)
- [YARA Rules](https://github.com/Yara-Rules/rules)
- [MITRE ATT&CK](https://attack.mitre.org/)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)

---

**Document Status:** Living Document  
**Review Frequency:** Monthly  
**Next Review:** 2026-12-15  
**Owner:** Detection Engineering Team  
**Approvers:** Security Team Lead
