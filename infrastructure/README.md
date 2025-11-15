First inventory

┌─────────────────────────────────────────────────────┐
│ DV01 (Windows) - Workstation de Desarrollo         │
│ - i9 + RTX 3070                                     │
│ - Windows 11                                        │
│ - IntelliJ IDEA + Cursor + Claude                   │
│ - Rol: Development Workstation                      │
│ - 98% RAM → NO usar para infra                      │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ DV02 (Linux) - Compute Node 1                       │
│ - ASUS Zenbook i9 + RTX 3070                        │
│ - Debian 13 + XFCE                                  │
│ - Rol: Kubernetes Master + Vendure Master           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ DV04 (Linux) - Compute Node 2                       │
│ - ASUS Zenbook i9 + RTX 3070                        │
│ - Debian 13 + XFCE                                  │
│ - Docker funcionando OK                             │
│ - Rol: Kubernetes Worker + Vendure Ecommerce        │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ DV05/DV06 (Linux) - Storage/Monitoring Nodes       │
│ - ASUS Ryzen 7 (antiguos)                           │
│ - 500GB RAM (?? o 500GB storage?)                   │
│ - Debian 13                                         │
│ - Rol: HELK/OpenSearch + Monitoring Stack           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Digital Ocean VPS - Gateway                         │
│ - Ubuntu 24.04                                      │
│ - Public IP                                         │
│ - Rol: VPN Exit Node + Reverse Proxy + CDN         │
└─────────────────────────────────────────────────────┘