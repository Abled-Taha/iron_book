# Project Iron Book
A Digital Financial Ledger

## Development

This section is targeted towards developers who are/will be contributing to this project.

### Philosophy

Every fucking thing needs to be reproducible on any machine. No more than 3 steps to start working on the project, among which, 2 steps are only the pre-requisites.

### Project Structure

This project is divided into multiple parts as following:

| Sub-Part          | Tech            | Development Status | Extra Notes |
| ----------------- | --------------- | :----------------: | :---------: |
| API               | Rust            |      Planned       |      -      |
| Web App           | Not Decided Yet |      Planned       |      -      |
| Android App       | Kotlin          |      Planned       |      -      |
| Linux/Windows App | Not Decided Yet |      Planned       |      -      |
| Database          | PostgreSQL      |      Planned       |      -      |
| Cache             | Redis           |      Planned       |      -      |
| Project Website   | NextJS          |      Working       |      -      |

### Project Directory Structure
```
.
├── apps
│   ├── android
│   │   ├── app
│   │   │   ├── build.gradle
│   │   │   └── src
│   │   │       └── main
│   │   │           ├── AndroidManifest.xml
│   │   │           ├── java
│   │   │           │   └── online
│   │   │           │       └── abledtaha
│   │   │           │           ├── ironbook
│   │   │           │           └── MainActivity.kt
│   │   │           └── res
│   │   │               └── values
│   │   │                   └── styles.xml
│   │   ├── build.gradle
│   │   ├── gradle
│   │   │   └── wrapper
│   │   │       ├── gradle-wrapper.jar
│   │   │       └── gradle-wrapper.properties
│   │   ├── gradle.properties
│   │   ├── gradlew
│   │   ├── gradlew.bat
│   │   ├── local.properties
│   │   └── settings.gradle
│   ├── api
│   │   ├── Cargo.toml
│   │   └── src
│   │       └── main.rs
│   └── home
│       ├── eslint.config.mjs
│       ├── next.config.ts
│       ├── package.json
│       ├── pnpm-lock.yaml
│       ├── postcss.config.mjs
│       ├── public
│       │   ├── file.svg
│       │   ├── globe.svg
│       │   ├── next.svg
│       │   ├── vercel.svg
│       │   └── window.svg
│       ├── README.md
│       ├── src
│       │   └── app
│       │       ├── favicon.ico
│       │       ├── globals.css
│       │       ├── layout.tsx
│       │       └── page.tsx
│       └── tsconfig.json
├── Cargo.lock
├── Cargo.toml
├── docker-compose.yaml
├── Dockerfile
├── .env.example
├── .gitignore
├── iron_book.sh
├── LICENSE
├── mise.toml
├── package.json
├── pnpm-lock.yaml
├── pnpm-workspace.yaml
├── README.md
├── setup.sh
└── .vscode
    └── settings.json
```

### Setup

1. Install [Mise](https://mise.jdx.dev/)
1. Clone the repo
1. Run `setup.sh`

### Todo

- [ ] Rather than this `README.md`, make the Project Website the main page, as well as the documentation.
- [ ] Implement `setup.ps1`
- [ ] Implement Nix Flakes
- [ ] Implement Docker

## Users

This section is targeted towards the users of this project.

### Features

- None

### Complaints

Open an issue on [GitHub][GitHub]

---

[GitHub]: https://github.com/Abled-Taha/iron_book