# Project Iron Book
A Digital Financial Ledger

## This README.md is for formal purposes and is updated less frequently than the [Documentation] site.

This repo is my biggest achievement to date because of its 3 main features, as follows:
1. It has 7 different parts to it, all integrated and managed into one polyglot monorepo.
2. All the parts of this repo use different tech stacks, and are perfectly made to work with each other with no redundancies while being environment agnostic.
3. Just like these 3 features, developer on-boarding also does not exceed more than 3 steps.

## Development

This section is targeted towards developers who are/will be contributing to this project.

### Philosophy

Everything needs to be reproducible on any machine. No more than 3 steps to start working on the project, among which, 2 of them are only the pre-requisites.

### Project Structure

This project is divided into multiple parts as following:

| Sub-Part          | Tech            | Development Status | Extra Notes |
| ----------------- | --------------- | :----------------: | :---------: |
| API               | Rust            |      Live          |      -      |
| Web App           | Python          |      Live          |      -      |
| Android App       | Kotlin          |      Live          |      -      |
| Linux/Windows App | C#              |      Live          |      -      |
| Database          | PostgreSQL      |      Live          |      -      |
| Cache             | Redis           |      Planned       |      -      |
| Project Website   | NextJS          |      Live          |      -      |

### Setup

1. Install [Mise](https://mise.jdx.dev/) & [Docker / Docker Compose](https://docker.com/) & [mingw-w64-gcc](https://www.mingw-w64.org/) (only needed manually if you are not on a [supported platform](docs/setup/supported_platforms.md))
2. Clone the repo
3. Run `scripts/ironbook.sh setup`

## Users

This section is targeted towards the users of this project.

### Installation
- Linux:
  ```bash
  curl -sSL https://raw.githubusercontent.com/ironbook-labs/ironbook/refs/heads/main/scripts/install/linux/installer.sh | sh
  ```
- Windows: Download and install the latest [Installer] or visit the [Documentation].
- Android: Download and install the latest [Stable Release] or visit the [Documentation].

### Features

1. 7 different parts integrated and managed into one polyglot monorepo
2. Multiple tech stacks working together with no redundancies while being environment agnostic
3. Simple developer on-boarding in no more than 3 steps

### Complaints

Open an issue on [GitHub]

---

[GitHub]: https://github.com/ironbook-labs/ironbook
[Documentation]: https://ironbook-labs.github.io
[Stable Release]: https://github.com/ironbook-labs/ironbook/releases/latest
[Installer]: https://github.com/ironbook-labs/ironbook/releases/latest
