# Review Security

Run a comprehensive security audit of the repository:

1. Check .gitignore for proper secret patterns
2. Scan git history for accidentally committed secrets
3. Review .env files and environment variable handling
4. Check for hardcoded credentials in code
5. Verify Docker security configurations
6. Review npm dependencies for known vulnerabilities
7. Check GitHub repository settings (branch protection, secret scanning)
8. Verify CI/CD pipeline security (no secrets in logs)

Provide a detailed report with:

- Current security posture
- Identified vulnerabilities or risks
- Recommended remediation steps
- Priority level for each finding
