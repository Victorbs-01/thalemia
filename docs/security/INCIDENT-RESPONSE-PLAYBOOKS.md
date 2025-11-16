# Incident Response Playbooks

> **Entrepreneur OS Security Platform**  
> Standard Operating Procedures for security incident response

## 📋 Table of Contents

- [Overview](#overview)
- [General Response Framework](#general-response-framework)
- [Playbook Index](#playbook-index)
- [Detailed Playbooks](#detailed-playbooks)
- [Communication Templates](#communication-templates)
- [Tools & Resources](#tools--resources)

---

## Overview

### Purpose

These playbooks provide step-by-step procedures for responding to security incidents in a consistent, effective manner.

### Incident Severity Matrix

| Severity          | Definition                              | Response Time | Escalation       |
| ----------------- | --------------------------------------- | ------------- | ---------------- |
| **P1 - Critical** | Active breach, data loss, system down   | 15 minutes    | CISO, Leadership |
| **P2 - High**     | Confirmed incident, limited impact      | 1 hour        | Security Lead    |
| **P3 - Medium**   | Suspicious activity, potential incident | 4 hours       | SOC L2           |
| **P4 - Low**      | Minor issue, informational              | 24 hours      | SOC L1           |

### Roles & Responsibilities

```yaml
Incident Commander (IC):
  - Overall incident response leadership
  - Decision making authority
  - Communication with leadership
  - Resource allocation

SOC Analyst (L1):
  - Alert monitoring and triage
  - Initial investigation
  - Documentation
  - Escalation to L2

SOC Analyst (L2):
  - Deep investigation
  - Evidence collection
  - Containment actions
  - Escalation to IC

Forensic Analyst:
  - Memory/disk forensics
  - Malware analysis
  - Timeline reconstruction
  - Expert witness if needed

Communications Lead:
  - Stakeholder notifications
  - Status updates
  - External communications
  - Media relations (if needed)

IT Operations:
  - System isolation
  - Network changes
  - Backup/restore
  - System rebuilding
```

---

## General Response Framework

### NIST Incident Response Lifecycle

```
┌─────────────┐
│Preparation  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│Detection &      │
│Analysis         │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│Containment,     │
│Eradication &    │
│Recovery         │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│Post-Incident    │
│Activity         │
└─────────────────┘
```

### Standard Response Steps

```yaml
1. Detection:
  - Alert triggered
  - Initial triage
  - Severity assessment

2. Analysis:
  - Gather context
  - Determine scope
  - Identify indicators
  - Assess impact

3. Containment:
  - Short-term: Stop the bleeding
  - Long-term: Prevent reoccurrence

4. Eradication:
  - Remove threat
  - Patch vulnerabilities
  - Verify clean state

5. Recovery:
  - Restore services
  - Validate functionality
  - Monitor for reinfection

6. Lessons Learned:
  - Post-mortem meeting
  - Documentation
  - Process improvements
  - Detection enhancements
```

---

## Playbook Index

| ID         | Playbook Name                                        | Severity | MITRE Tactics             |
| ---------- | ---------------------------------------------------- | -------- | ------------------------- |
| **PB-001** | [Malware Infection](#pb-001-malware-infection)       | High     | Initial Access, Execution |
| **PB-002** | [Phishing Attack](#pb-002-phishing-attack)           | Medium   | Initial Access            |
| **PB-003** | [Data Breach](#pb-003-data-breach)                   | Critical | Exfiltration              |
| **PB-004** | [Insider Threat](#pb-004-insider-threat)             | High     | Collection, Exfiltration  |
| **PB-005** | [DDoS Attack](#pb-005-ddos-attack)                   | High     | Impact                    |
| **PB-006** | [Ransomware](#pb-006-ransomware)                     | Critical | Impact                    |
| **PB-007** | [Account Compromise](#pb-007-account-compromise)     | High     | Credential Access         |
| **PB-008** | [Privilege Escalation](#pb-008-privilege-escalation) | Critical | Privilege Escalation      |
| **PB-009** | [Data Exfiltration](#pb-009-data-exfiltration)       | Critical | Exfiltration              |
| **PB-010** | [Supply Chain Attack](#pb-010-supply-chain-attack)   | Critical | Initial Access            |
| **PB-011** | [SQL Injection](#pb-011-sql-injection)               | High     | Initial Access            |
| **PB-012** | [Brute Force Attack](#pb-012-brute-force-attack)     | Medium   | Credential Access         |

---

## Detailed Playbooks

### PB-001: Malware Infection

**Severity:** High  
**MITRE:** T1204 (User Execution), T1059 (Command Execution)

#### Indicators

- Antivirus/EDR alert
- Suspicious process execution
- Unexpected network connections
- File system modifications
- Performance degradation

#### Response Steps

**1. DETECT & ANALYZE (15 minutes)**

```yaml
Actions:
  - [ ] Verify alert authenticity
  - [ ] Identify affected system(s)
  - [ ] Determine malware type (if known)
  - [ ] Check for lateral movement
  - [ ] Assess potential data impact

Commands:
  # Check running processes
  ps aux | grep -E "(suspicious|malware|miner)"

  # Check network connections
  netstat -tulpn | grep ESTABLISHED

  # Check recent file modifications
  find / -mtime -1 -type f

  # Memory dump (if needed)
  sudo dd if=/dev/mem of=/tmp/memory.dump bs=1M

Collect:
  - System logs (/var/log/)
  - Process list
  - Network connections
  - File integrity logs
  - Memory dump (if possible)
```

**2. CONTAIN (30 minutes)**

```yaml
Short-term Containment:
  - [ ] Isolate affected system from network
  - [ ] Disable user account (if compromised)
  - [ ] Kill malicious processes
  - [ ] Block malicious IPs/domains at firewall
  - [ ] Preserve evidence (memory, disk)

Commands:
  # Isolate system (Tailscale)
  sudo tailscale down

  # Or block all traffic except SSH
  sudo ufw default deny incoming
  sudo ufw default deny outgoing
  sudo ufw allow from YOUR_IP to any port 22
  sudo ufw enable

  # Kill malicious process
  sudo kill -9 <PID>

  # Block malicious IP
  sudo iptables -A INPUT -s <MALICIOUS_IP> -j DROP
  sudo iptables -A OUTPUT -d <MALICIOUS_IP> -j DROP

Long-term Containment:
  - [ ] Patch vulnerability (if known)
  - [ ] Update detection signatures
  - [ ] Review access controls
  - [ ] Monitor for reinfection
```

**3. ERADICATE (1-2 hours)**

```yaml
Actions:
  - [ ] Remove malware files
  - [ ] Clean registry/cron (if persistence)
  - [ ] Reset compromised credentials
  - [ ] Patch exploited vulnerability
  - [ ] Scan all systems for same malware
  - [ ] Update antivirus signatures

Commands:
  # Remove malware
  sudo rm -f /path/to/malware

  # Check for persistence
  crontab -l
  cat /etc/crontab
  systemctl list-units --type=service

  # Remove suspicious cron
  crontab -r

  # Full system scan
  sudo clamscan -r / --exclude-dir=/sys --exclude-dir=/proc
```

**4. RECOVER (2-4 hours)**

```yaml
Actions:
  - [ ] Restore from clean backup (if needed)
  - [ ] Rebuild system (if severely compromised)
  - [ ] Re-enable network access
  - [ ] Verify system functionality
  - [ ] Monitor for 48-72 hours
  - [ ] User communication

Validation:
  - [ ] No malicious processes running
  - [ ] No unauthorized network connections
  - [ ] File integrity verified
  - [ ] System performance normal
  - [ ] Logs clean for 24 hours
```

**5. LESSONS LEARNED (Within 72 hours)**

```yaml
Post-Mortem:
  - How did malware enter? (root cause)
  - What was the dwell time?
  - Was detection effective?
  - Was response timely?
  - What can be improved?

Actions:
  - [ ] Update detection rules
  - [ ] Implement additional controls
  - [ ] User training (if applicable)
  - [ ] Document incident
  - [ ] Update playbook
```

#### Decision Tree

```
Malware Detected
       │
       ├─ Known malware?
       │  ├─ Yes → Use known remediation
       │  └─ No → Proceed with analysis
       │
       ├─ Active C2 communication?
       │  ├─ Yes → CRITICAL: Isolate immediately
       │  └─ No → Proceed with caution
       │
       ├─ Data exfiltration detected?
       │  ├─ Yes → Escalate to PB-009 (Data Exfiltration)
       │  └─ No → Continue malware response
       │
       ├─ Lateral movement detected?
       │  ├─ Yes → Investigate all affected systems
       │  └─ No → Focus on patient zero
       │
       └─ Eradication successful?
          ├─ Yes → Move to recovery
          └─ No → Consider full rebuild
```

---

### PB-002: Phishing Attack

**Severity:** Medium  
**MITRE:** T1566 (Phishing)

#### Indicators

- Suspicious email reported
- User clicked malicious link
- Credentials entered on fake site
- Attachment opened
- Email forwarding rule created

#### Response Steps

**1. DETECT & ANALYZE (10 minutes)**

```yaml
Actions:
  - [ ] Obtain email sample/headers
  - [ ] Identify all recipients
  - [ ] Check if link/attachment opened
  - [ ] Determine if credentials compromised
  - [ ] Check for follow-on activity

Analysis:
  # Extract email headers
  - Sender IP
  - SPF/DKIM/DMARC results
  - Return-Path
  - Received headers

  # Check link
  - [ ] URL analysis (VirusTotal, URLhaus)
  - [ ] Phishing kit fingerprint
  - [ ] Domain registration date

  # Check attachment (if any)
  - [ ] File hash (VirusTotal)
  - [ ] Sandbox analysis
  - [ ] Macro/script content
```

**2. CONTAIN (30 minutes)**

```yaml
Immediate Actions:
  - [ ] Delete email from all mailboxes
  - [ ] Block sender domain/IP
  - [ ] Block malicious URLs
  - [ ] Reset compromised credentials
  - [ ] Monitor for unusual activity
  - [ ] Send warning to all staff

Commands:
  # Block domain in email server
  sudo postconf -e "smtpd_sender_restrictions =
    check_sender_access hash:/etc/postfix/sender_access"
  echo "phishing-domain.com REJECT" >> /etc/postfix/sender_access
  sudo postmap /etc/postfix/sender_access
  sudo systemctl reload postfix

  # Block URL in proxy/firewall
  sudo iptables -A OUTPUT -d <PHISHING_IP> -j DROP

  # Force password reset
  # (User-specific command)
```

**3. ERADICATE (1 hour)**

```yaml
Actions:
  - [ ] Remove malware (if installed)
  - [ ] Remove email forwarding rules
  - [ ] Check for unauthorized access
  - [ ] Review email logs for similar attempts
  - [ ] Report to PhishTank/APWG

Verification:
  - [ ] No malicious emails remaining
  - [ ] URLs/domains blocked
  - [ ] Affected users secure
  - [ ] No unauthorized access detected
```

**4. RECOVER (30 minutes)**

```yaml
Actions:
  - [ ] Users resume normal operations
  - [ ] Monitor accounts for 48 hours
  - [ ] Additional MFA if needed
  - [ ] User re-training

Communication:
  - Notify affected users
  - Company-wide awareness email
  - Update training materials
```

**5. LESSONS LEARNED**

```yaml
Questions:
  - How many users fell for it?
  - Was email filter effective?
  - How quickly was it reported?
  - Can detection be improved?

Prevention:
  - [ ] Update email filters
  - [ ] Add URL to blocklist
  - [ ] User awareness training
  - [ ] Consider additional controls
```

---

### PB-003: Data Breach

**Severity:** Critical  
**MITRE:** T1048 (Exfiltration), T1530 (Data from Cloud)

#### Indicators

- Large data download/upload
- Unauthorized database access
- Customer data in public forum
- Third-party breach notification
- DLP alert

#### Response Steps

**1. DETECT & ANALYZE (30 minutes)**

```yaml
Critical Questions:
  - [ ] What data was compromised?
  - [ ] How much data?
  - [ ] Who had access?
  - [ ] Where is the data now?
  - [ ] How did breach occur?
  - [ ] When did it happen?

Data Classification:
  - [ ] Personal data (PII)
  - [ ] Financial data
  - [ ] Health data (PHI)
  - [ ] Intellectual property
  - [ ] Customer data
  - [ ] Employee data

Legal/Regulatory:
  - [ ] GDPR applicable? (72h notification)
  - [ ] PCI-DSS data involved?
  - [ ] HIPAA data involved?
  - [ ] Local privacy laws?
```

**2. CONTAIN (1 hour)**

```yaml
Immediate Actions:
  - [ ] Stop the data leak
  - [ ] Disable compromised accounts
  - [ ] Block exfiltration channels
  - [ ] Preserve evidence
  - [ ] Notify leadership IMMEDIATELY
  - [ ] Engage legal counsel
  - [ ] Prepare for notifications

Technical:
  # Block external access
  sudo iptables -A OUTPUT -d <EXTERNAL_IP> -j DROP

  # Disable user account
  sudo usermod -L <username>

  # Close database connections
  sudo -u postgres psql -c "
    SELECT pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE usename = '<username>';"

  # Enable aggressive DLP
  # (Implementation specific)
```

**3. ERADICATE (2-4 hours)**

```yaml
Actions:
  - [ ] Close vulnerability
  - [ ] Remove attacker access
  - [ ] Reset all credentials
  - [ ] Review access logs
  - [ ] Identify full scope
  - [ ] Secure remaining data

Forensics:
  - [ ] Preserve logs
  - [ ] Take disk images
  - [ ] Memory dumps
  - [ ] Network captures
  - [ ] Timeline analysis
```

**4. RECOVER (Variable)**

```yaml
Technical Recovery:
  - [ ] Restore from clean backup
  - [ ] Implement additional controls
  - [ ] Enhanced monitoring
  - [ ] Third-party security assessment

Business Recovery:
  - [ ] Customer notifications (legal review)
  - [ ] Regulatory notifications (GDPR: 72h)
  - [ ] Credit monitoring offer (if applicable)
  - [ ] Public statement (if needed)
  - [ ] Insurance claim
```

**5. LESSONS LEARNED**

```yaml
Required Analysis:
  - Root cause analysis
  - Timeline reconstruction
  - Impact assessment
  - Cost calculation
  - Prevention measures

Deliverables:
  - [ ] Incident report
  - [ ] Lessons learned document
  - [ ] Regulatory filings
  - [ ] Insurance documentation
  - [ ] Prevention plan
```

#### Notification Requirements

```yaml
GDPR (72 hours):
  Required if:
    - Personal data of EU residents
    - Risk to rights and freedoms

  Must include:
    - Nature of breach
    - Likely consequences
    - Measures taken
    - Contact point

PCI-DSS (Immediately):
  Required if:
    - Payment card data compromised

  Notify:
    - Payment brands
    - Acquiring bank
    - PCI forensic investigator

HIPAA (60 days):
  Required if:
    - Protected Health Information

  Notify:
    - Affected individuals
    - HHS
    - Media (if >500 people)
```

---

### PB-006: Ransomware

**Severity:** Critical  
**MITRE:** T1486 (Data Encrypted for Impact)

#### Indicators

- Files encrypted (changed extensions)
- Ransom note displayed
- Backup systems targeted
- Lateral movement detected
- Shadow copies deleted

#### Response Steps

**1. DETECT & ANALYZE (15 minutes)**

```yaml
Critical First Actions:
  - [ ] DO NOT pay ransom (yet)
  - [ ] Isolate affected systems IMMEDIATELY
  - [ ] Identify ransomware variant
  - [ ] Check if decryptor available
  - [ ] Assess backup status
  - [ ] Determine patient zero

Identification:
  - Ransom note text
  - File extensions
  - Contact methods
  - Bitcoin addresses
  - Submit to ID Ransomware
```

**2. CONTAIN (30 minutes - URGENT)**

```yaml
IMMEDIATE Actions:
  - [ ] Isolate ALL affected systems
  - [ ] Disconnect network shares
  - [ ] Disable cloud sync
  - [ ] Protect backups
  - [ ] Notify leadership
  - [ ] Preserve evidence

Commands:
  # ISOLATE NOW
  sudo ip link set <interface> down
  sudo systemctl stop docker  # If containers affected

  # Protect backups
  sudo chmod 000 /backup/*
  sudo umount /backup

  # Stop database (if targeted)
  sudo systemctl stop postgresql

  # Take snapshot (if VM)
  # (Hypervisor specific)

DO NOT:
  - Reboot systems
  - Delete ransom notes
  - Decrypt files manually
  - Pay ransom without leadership approval
```

**3. ERADICATION (Hours to Days)**

```yaml
Decision Tree:
  Backups Available?
    ├─ Yes → Restore from backup
    │  ├─ Verify backup integrity
    │  ├─ Test restore
    │  └─ Full restore
    │
    └─ No → Evaluate options
       ├─ Free decryptor available?
       │  ├─ Yes → Attempt decryption
       │  └─ No → Consider ransom payment
       │
       └─ Business impact assessment
          - Cost of downtime
          - Cost of data loss
          - Ransom amount
          - Legal implications
          - Reputation impact

Removal:
  - [ ] Identify malware binary
  - [ ] Remove persistence mechanisms
  - [ ] Clean all systems
  - [ ] Patch vulnerabilities
  - [ ] Reset ALL credentials
```

**4. RECOVER (Days to Weeks)**

```yaml
Restoration:
  - [ ] Rebuild critical systems first
  - [ ] Restore from clean backups
  - [ ] Verify data integrity
  - [ ] Staged restoration (not all at once)
  - [ ] Enhanced monitoring
  - [ ] Phased user access

Validation:
  - [ ] No ransomware remnants
  - [ ] Backups accessible
  - [ ] Systems functional
  - [ ] Users can work
  - [ ] Monitor for reinfection (7 days)

Business Continuity:
  - [ ] Activate DR plan
  - [ ] Manual processes
  - [ ] Customer communication
  - [ ] Revenue impact mitigation
```

**5. LESSONS LEARNED**

```yaml
Required Analysis:
  - How did ransomware enter?
  - Why weren't backups protected?
  - Was detection/response adequate?
  - Total cost (downtime + recovery + ransom)
  - Prevention measures needed

Improvements:
  - [ ] Offline/immutable backups
  - [ ] Network segmentation
  - [ ] Endpoint protection
  - [ ] User training
  - [ ] Incident response plan update
  - [ ] Cyber insurance review
```

#### Ransom Payment Decision Matrix

```yaml
Consider Payment IF:
  - Critical data with no backup
  - Business-critical systems down
  - Restore time > acceptable RTO
  - Verified decryption success stories
  - Legal counsel approval
  - Law enforcement notified

DO NOT Pay IF:
  - Backups available
  - Free decryptor exists
  - Known non-functional ransomware
  - Legal/regulatory prohibition
  - Insufficient funds
```

---

### PB-007: Account Compromise

**Severity:** High  
**MITRE:** T1078 (Valid Accounts)

#### Indicators

- Impossible travel
- Multiple failed logins then success
- Unusual access patterns
- New device/location
- Privilege escalation attempts
- Data accessed outside normal hours

#### Response Steps

**1. DETECT & ANALYZE (15 minutes)**

```yaml
Gather Information:
  - [ ] Which account?
  - [ ] What access does it have?
  - [ ] When was compromise?
  - [ ] What actions taken?
  - [ ] What data accessed?
  - [ ] Source IP/location?

Commands:
  # Check user's recent activity
  last -f /var/log/wtmp | grep <username>

  # Check sudo usage
  grep <username> /var/log/auth.log | grep sudo

  # Check file access
  find / -user <username> -mtime -1

  # Active sessions
  w | grep <username>
```

**2. CONTAIN (30 minutes)**

```yaml
Immediate Actions:
  - [ ] Disable account
  - [ ] Kill active sessions
  - [ ] Reset password
  - [ ] Revoke API keys/tokens
  - [ ] Review access logs
  - [ ] Alert user (if legitimate)

Commands:
  # Disable account
  sudo usermod -L <username>
  sudo chage -E 0 <username>

  # Kill sessions
  sudo pkill -u <username>

  # Revoke sudo
  sudo visudo
  # Comment out user's sudo line

  # Find and revoke SSH keys
  sudo rm /home/<username>/.ssh/authorized_keys
```

**3. ERADICATE (1-2 hours)**

```yaml
Actions:
  - [ ] Determine compromise method
  - [ ] Close vulnerability
  - [ ] Reset ALL user credentials
  - [ ] Enable MFA (if not already)
  - [ ] Review all user access
  - [ ] Check for backdoors

Investigation:
  - Phishing?
  - Weak password?
  - Credential stuffing?
  - Malware?
  - Insider threat?
  - Social engineering?
```

**4. RECOVER (1 hour)**

```yaml
Account Restoration:
  - [ ] Create new password (strong)
  - [ ] Enable MFA
  - [ ] Generate new API keys
  - [ ] Review/restrict permissions
  - [ ] Re-enable account
  - [ ] User training
  - [ ] Monitor for 48 hours

Validation:
  - [ ] User can log in
  - [ ] MFA working
  - [ ] No unauthorized access
  - [ ] Legitimate access working
```

**5. LESSONS LEARNED**

```yaml
Prevention:
  - [ ] Enforce MFA
  - [ ] Password policy review
  - [ ] Access review schedule
  - [ ] Impossible travel detection
  - [ ] UEBA tuning
  - [ ] User training
```

---

## Communication Templates

### Initial Alert (Internal)

```
Subject: SECURITY INCIDENT - [SEVERITY] - [TYPE]

SUMMARY:
[One-line description]

STATUS: [Investigating | Contained | Resolved]

IMPACT:
- Systems affected: [List]
- Data at risk: [Type/Amount]
- Business impact: [Description]

ACTIONS TAKEN:
- [Action 1]
- [Action 2]

NEXT STEPS:
- [Step 1]
- [Step 2]

INCIDENT COMMANDER: [Name]
UPDATES: Every [frequency]
```

### Customer Notification (Data Breach)

```
Subject: Important Security Notice

Dear [Customer],

We are writing to inform you of a security incident that may
have affected your personal information.

WHAT HAPPENED:
[Brief description]

WHAT INFORMATION WAS INVOLVED:
[List of data types]

WHAT WE ARE DOING:
[Response actions]

WHAT YOU CAN DO:
[Recommendations]

For more information or questions, please contact:
[Contact details]

Sincerely,
[Company Name]
```

---

## Tools & Resources

### Essential Tools

```yaml
Investigation:
  - OpenSearch (log analysis)
  - Jupyter (threat hunting)
  - Wireshark (network analysis)
  - Volatility (memory forensics)
  - Autopsy (disk forensics)

Response:
  - TheHive (case management)
  - Cortex (automation)
  - Ansible (remediation)
  - MISP (threat intel)

External Resources:
  - VirusTotal
  - URLhaus
  - AbuseIPDB
  - Shodan
  - Have I Been Pwned
```

### Contact List

```yaml
Internal:
  - Incident Commander: [Contact]
  - CISO: [Contact]
  - Legal: [Contact]
  - Communications: [Contact]
  - IT Operations: [Contact]

External:
  - Cyber Insurance: [Contact]
  - Legal Counsel: [Contact]
  - Law Enforcement: [Contact]
  - Forensic Firm: [Contact]
  - Public Relations: [Contact]

Regulatory:
  - Data Protection Authority: [Contact]
  - Industry Regulator: [Contact]
```

---

**Document Status:** Living Document  
**Review Frequency:** Quarterly  
**Next Review:** 2026-02-15  
**Owner:** Incident Response Team  
**Approvers:** CISO, Legal
