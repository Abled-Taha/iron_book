# Project Iron Book
A Digital Financial Ledger

## This README.md is for formal purposes and is updated less frequently than the [Documentation](https://docs.ironbook.app.abledtaha.online) site.

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
| API               | Rust            |      Working       |      -      |
| Web App           | Python          |      Planned       |      -      |
| Android App       | Kotlin          |      Planned       |      -      |
| Linux/Windows App | Not Decided Yet |      Planned       |      -      |
| Database          | PostgreSQL      |      Working       |      -      |
| Cache             | Redis           |      Planned       |      -      |
| Project Website   | NextJS          |      Live          |      -      |

### Setup

1. Install [Mise](https://mise.jdx.dev/) & [Docker / Docker Compose](https://www.docker.com/)
1. Clone the repo
1. Run `./setup.sh`

## Users

This section is targeted towards the users of this project.

### Features

1. 7 different parts integrated and managed into one polyglot monorepo
2. Multiple tech stacks working together with no redundancies while being environment agnostic
3. Simple developer on-boarding in no more than 3 steps

### Complaints

Open an issue on [GitHub][GitHub]

---

[GitHub]: https://github.com/Abled-Taha/iron_book
