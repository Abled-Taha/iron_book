# Project Iron Book
A Digital Financial Ledger

This repo (If I finish it) is my biggest achievement till now. Because of it's 3 main features, as following:
1. It has 7 different parts to it, all integrated and managed into one ploglot monorepo.
1. All the parts of this repo use different tech stacks, and are perfectly made to work with each other with no redundancies while being environment agnostic.
1. Just like these 3 features, developer on-boarding also doesn't exceed more than 3 steps.

## Development

This section is targeted towards developers who are/will be contributing to this project.

### Philosophy

Every fucking thing needs to be reproducible on any machine. No more than 3 steps to start working on the project, among which, 2 of them are only the pre-requisites.

### Project Structure

This project is divided into multiple parts as following:

| Sub-Part          | Tech            | Development Status | Extra Notes |
| ----------------- | --------------- | :----------------: | :---------: |
| API               | Rust            |      Planned       |      -      |
| Web App           | Python          |      Planned       |      -      |
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
│   ├── home
│   │   ├── eslint.config.mjs
│   │   ├── next.config.ts
│   │   ├── package.json
│   │   ├── pnpm-lock.yaml
│   │   ├── postcss.config.mjs
│   │   ├── public
│   │   │   ├── file.svg
│   │   │   ├── globe.svg
│   │   │   ├── next.svg
│   │   │   ├── vercel.svg
│   │   │   └── window.svg
│   │   ├── README.md
│   │   ├── src
│   │   │   └── app
│   │   │       ├── favicon.ico
│   │   │       ├── globals.css
│   │   │       ├── layout.tsx
│   │   │       └── page.tsx
│   │   └── tsconfig.json
│   └── web
│       ├── iron_book
│       │   ├── asgi.py
│       │   ├── settings.py
│       │   ├── urls.py
│       │   ├── views.py
│       │   └── wsgi.py
│       ├── manage.py
│       ├── Procfile.tailwind
│       ├── pyproject.toml
│       ├── static
│       │   ├── css
│       │   │   └── animate.css
│       │   ├── img
│       │   │   └── favicon.png
│       │   └── js
│       │       ├── alpine.min.js
│       │       └── htmx.min.js
│       ├── templates
│       │   ├── 404.html
│       │   ├── base.html
│       │   ├── home.html
│       │   └── robots.txt
│       ├── theme
│       │   ├── apps.py
│       │   ├── static
│       │   │   └── css
│       │   │       └── dist
│       │   │           └── styles.css
│       │   └── static_src
│       │       └── src
│       │           └── styles.css
│       ├── uv.lock
│       └── web
│           ├── apps.py
│           ├── urls.py
│           └── views.py
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
- [ ] `setup.ps1`
- [ ] Nix Flakes
- [ ] Docker
- [ ] Django does not serve static files in prod
- [ ] Add other prod features (I can't remember right now which ones)

## Users

This section is targeted towards the users of this project.

### Features

- None

### Complaints

Open an issue on [GitHub][GitHub]

---

[GitHub]: https://github.com/Abled-Taha/iron_book