js-yaml@3.14.2 (transitive via @nx/\* 22.0.3)

- Vulnerability: prototype pollution via **proto** in YAML parsing.
- Scope: Nx build/test tooling only. No YAML from untrusted sources is parsed.
- Status: Accepted risk (dev-only).
- Plan: Re-evaluate and update Nx when a release with js-yaml >=4.1.1 is available.
