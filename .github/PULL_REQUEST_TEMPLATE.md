## Description

Briefly describe the changes introduced by this PR and the problem it solves.

Fixes #(issue)

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
- [ ] 🌐 **Web Frontend** (`Next.js` / `TypeScript`)
- [ ] 📱 **Mobile** (`Kotlin` / `Android`)
- [ ] 🗄️ **Database** (`PostgreSQL` / `SQLx` migrations)
- [ ] ⚙️ **Infra / Root Config**

---

## Verification & Testing

Explain how these changes were tested. Include commands used to verify locally.

### Local Execution
- [ ] **Rust Backend**: Executed `cargo check` / `cargo test` clean with no warnings
- [ ] **SQLx**: Migrations run cleanly, and `cargo sqlx prepare` updated (if query macros changed)
- [ ] **Web App**: Executed `pnpm build` / `npm run build` without type errors
- [ ] **Mobile**: App builds and runs on emulator/device
- [ ] **Linting / Formatting**: Passed project formatting checks (`cargo fmt`, `clippy`, `eslint`, etc.)

---

## Screenshots / API Payloads (If Applicable)

| Before | After |
| :--- | :--- |
| *Paste screenshot or JSON response* | *Paste screenshot or JSON response* |

---

## Checklist

- [ ] My code follows the code style guidelines of this project
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have updated relevant documentation / OpenAPI specifications
