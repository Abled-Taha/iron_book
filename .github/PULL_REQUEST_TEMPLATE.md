## Description

Fixes #

---

## Type of Change

- [ ] 🐛 **Bug Fix**: Non-breaking change that fixes an issue
- [ ] ✨ **New Feature**: Non-breaking change that adds functionality
- [ ] 💥 **Breaking Change**: Fix or feature that would cause existing functionality to change
- [ ] 🛠️ **Refactor / Performance**: Code improvement without functional changes
- [ ] 📚 **Docs**: Documentation updates
- [ ] 🏗️ **CI/CD / Infra**: Changes to build pipeline, dependencies, or configuration

---

## Affected Components

Select all components modified in this pull request:

- [ ] 🦀 **Backend** (`Axum` / `Rust`)
- [ ] 📄 **Web Frontend** (`Django` / `Python`)
- [ ] 🌐 **Docs** (`Next.JS` / `TypeScript`)
- [ ] 📱 **Mobile** (`Android` / `Kotlin`)
- [ ] 🖥️ **Desktop** (`Avalonia` / `C#`)
- [ ] 🗄️ **Database** (`PostgreSQL` / `SQLx` migrations)
- [ ] ⚙️ **Infra / Root Config**

---

## Verification & Testing

Explain how these changes were tested. Include commands used to verify locally.

### Local Execution (Only required for what you worked on)
- [ ] **Rust Backend**: Executed `mise run //apps/api:dev` clean with no warnings
- [ ] **SQLx**: Migrations run cleanly, and `cargo sqlx prepare` updated (if query macros changed)
- [ ] **Web App**: Executed `mise run //apps/web:dev` clean with no warnings
- [ ] **Docs**: Executed `mise run //apps/home:dev`clean with no warnings
- [ ] **Mobile**: App builds and runs on emulator/device
- [ ] **Desktop** App builds and runs on desktop

---

## Screenshots / API Payloads (If Applicable)

| Before | After |
| :--- | :--- |
| *Screenshot/JSON* | *Screenshot/JSON* |

---

## Checklist

- [ ] My code follows the code style guidelines of this project
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have updated relevant documentation
