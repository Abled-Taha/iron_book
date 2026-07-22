# Security Policy

`iron_book` takes the security of our application, API services, and user data seriously. If you discover a vulnerability or potential security flaw, we appreciate your help in disclosing it to us responsibly.

---

## Supported Versions

Only the latest active release or the current state of the `main` branch is actively supported with security updates.

| Version / Component | Supported          |
| ------------------- | ------------------ |
| `main` Branch       | :white_check_mark: |
| Development / Draft | :x:                |

---

## Reporting a Vulnerability

**Please do NOT open a public GitHub issue, pull request, or discussion for security vulnerabilities.**

If you discover a security vulnerability within `iron_book` (including the Axum backend API, Next.js frontend, Kotlin mobile app, or PostgreSQL/SQLx data handlers):

1. **Private Disclosure:** Go to the repository's **Security** tab on GitHub and click **"Report a vulnerability"** to submit a Private Vulnerability Report. Alternatively, reach out directly via private channel or email specified in the repository profile (abledtaha@gmail.com).
2. **Details to Include:**
   * A clear description of the vulnerability and its potential impact.
   * Steps to reproduce the issue, including proof-of-concept scripts or API payloads where applicable.
   * Affected components (e.g., Backend JWT handling, SQL injection potential, client-side token storage).
3. **Response Time:** We aim to acknowledge reports within 48 hours and provide an estimated timeline for remediation.

---

## Disclosure Guidelines

To protect our users and project integrity:

* Give us reasonable time to investigate, patch, and deploy a fix before making any details public.
* Avoid accessing or modifying sensitive user data that does not belong to you during testing.
* Conduct testing only against local instances or mock environments, never against production infrastructure.

Thank you for helping keep `iron_book` secure!
