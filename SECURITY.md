# Security Policy

## Supported Versions

We release security updates for the following versions:

| Version | Supported |
|---------|-----------|
| 2.x.x   | ✅ Yes    |
| 1.x.x   | ❌ No     |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via:

- **Email**: security@littletech.app
- **GitHub Security Advisories**: [Report a vulnerability](https://github.com/Mostafa-Taher-git/LittleTech/security/advisories/new)

### What to Include

Please provide as much detail as possible:

1. **Description** of the vulnerability
2. **Steps to reproduce** (if applicable)
3. **Potential impact** (data exposure, privilege escalation, etc.)
4. **Affected versions** (if known)
5. **Suggested fix** (if you have one)
6. **Your contact info** for follow-up

## Response Timeline

| Phase | Timeline |
|-------|----------|
| **Acknowledgment** | Within 48 hours |
| **Initial Assessment** | Within 5 business days |
| **Fix Development** | Within 30 days (critical), 90 days (non-critical) |
| **Release** | Next patch release after fix |
| **Disclosure** | Coordinated with reporter |

## Security Architecture

### Threat Model

LittleTech is designed with these security principles:

| Principle | Implementation |
|-----------|----------------|
| **Offline-first** | Zero network requests; no attack surface via network |
| **Local-only data** | All data stored in app sandbox (Isar + SharedPreferences) |
| **No PII collection** | No email, phone, location, or device identifiers collected |
| **Password hashing** | PBKDF2-SHA256 (100,000 iterations) via `crypto` package |
| **User isolation** | Each account = separate DB records keyed by userId |
| **No telemetry** | Zero analytics, crash reporting, or usage tracking |

### Data Protection

| Data Type | Storage | Encryption |
|-----------|---------|------------|
| User credentials | SharedPreferences | PBKDF2 hash only (no plaintext) |
| Game progress | Isar database | OS-level (Android Keystore / iOS Keychain) |
| Preferences | SharedPreferences | OS-level |
| Assets | App bundle | N/A (read-only) |

### Account Security

- **No password recovery** — local-only, no email reset
- **Account deletion** — immediate, irreversible, wipes all data
- **Multi-user** — isolated progress per account
- **Session persistence** — optional "remember me" via SharedPreferences

## Known Security Considerations

| Area | Risk | Mitigation |
|------|------|------------|
| **Rooted/Jailbroken devices** | DB accessible | Isar encryption (optional, not default) |
| **Backup extraction** | Progress readable | No sensitive data in progress |
| **Shared device** | Account switching | Explicit logout required |
| **Clipboard** | No sensitive data copied | No copy/paste of credentials |

## Dependency Security

- **Regular updates**: `flutter pub upgrade --major-versions` monthly
- **Audit**: `flutter pub outdated` + GitHub Dependabot alerts
- **Pinned versions**: Critical deps pinned in `pubspec.yaml`
- **No dynamic code loading**: All Dart code compiled AOT

## Disclosure Policy

- We follow **Coordinated Vulnerability Disclosure**
- Credit given to reporters (unless anonymous requested)
- Fixed versions noted in release notes and `CHANGELOG.md`
- No legal action against good-faith researchers

## Contact

For security questions or concerns:

- **Email**: security@littletech.app
- **PGP Key**: Available on request
- **Response**: Within 48 hours

---

*Last updated: 2024-01-15*
*Version: 1.0*