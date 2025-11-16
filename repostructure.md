entrepreneur-os/
├── apps/                           # Applications
├── libs/                           # Shared libraries
├── infrastructure/                 # Infrastructure as Code
│   ├── ansible/
│   │   ├── inventory/
│   │   │   ├── hosts.yml
│   │   │   └── group_vars/
│   │   ├── playbooks/
│   │   │   ├── 00-china-mirrors.yml
│   │   │   ├── 01-base-setup.yml
│   │   │   ├── 02-docker-setup.yml
│   │   │   ├── 03-tailscale-setup.yml
│   │   │   ├── 04-monitoring-stack.yml
│   │   │   ├── 05-security-stack.yml
│   │   │   └── 06-application-stack.yml
│   │   └── roles/
│   │       ├── common/
│   │       ├── docker/
│   │       ├── tailscale/
│   │       ├── opensearch/
│   │       ├── grafana/
│   │       ├── wazuh/
│   │       └── vendure/
│   ├── terraform/
│   │   ├── do-vps/
│   │   └── cloudflare/
│   ├── compose/
│   │   ├── monitoring/
│   │   │   ├── opensearch.yml
│   │   │   ├── grafana.yml
│   │   │   ├── prometheus.yml
│   │   │   └── wazuh.yml
│   │   ├── applications/
│   │   │   ├── vendure-master.yml
│   │   │   └── vendure-ecommerce.yml
│   │   └── storage/
│   │       ├── minio.yml
│   │       └── postgres.yml
│   ├── kubernetes/
│   │   ├── k3s/
│   │   └── manifests/
│   ├── monitoring/
│   │   ├── opensearch/
│   │   │   ├── opensearch.yml
│   │   │   ├── dashboards/
│   │   │   └── pipelines/
│   │   ├── grafana/
│   │   │   ├── dashboards/
│   │   │   └── provisioning/
│   │   ├── prometheus/
│   │   │   ├── prometheus.yml
│   │   │   └── alerts/
│   │   └── wazuh/
│   │       ├── rules/
│   │       └── decoders/
│   ├── security/
│   │   ├── sigma-rules/
│   │   ├── falco-rules/
│   │   └── fail2ban/
│   └── scripts/
│       ├── collect-inventory.sh
│       ├── setup-node.sh
│       ├── backup.sh
│       └── restore.sh
├── docs/
│   ├── architecture/
│   │   ├── HELK-OPENSEARCH.md
│   │   ├── NETWORK-TOPOLOGY.md
│   │   └── SECURITY-MODEL.md
│   ├── runbooks/
│   │   ├── deployment.md
│   │   ├── troubleshooting.md
│   │   └── disaster-recovery.md
│   └── guides/
│       ├── china-setup.md
│       └── monitoring-guide.md
└── tools/
├── scripts/
└── cli/