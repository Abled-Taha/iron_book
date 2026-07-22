# Contributing to iron_book

First off, thank you for considering contributing to **iron_book**! Projects like this rely on community contributions, bug reports, and feedback to stay high quality.

This document outlines the workflow, environment setup, and coding conventions used across the project's polyglot monorepo.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Monorepo Architecture](#monorepo-architecture)
- [Local Development Setup](#local-development-setup)
- [Development Workflow](#development-workflow)
  - [1. Find or Create an Issue](#1-find-or-create-an-issue)
  - [2. Branch Naming Conventions](#2-branch-naming-conventions)
  - [3. Making Changes & Local Verification](#3-making-changes--local-verification)
  - [4. Working with Database & SQLx](#4-working-with-database--sqlx)
  - [5. Submitting a Pull Request](#5-submitting-a-pull-request)
- [Coding & Commit Standards](#coding--commit-standards)

---

## Code of Conduct

Please keep discussions, issue threads, and pull request reviews respectful, constructive, and helpful. We aim to foster an inclusive environment for developers of all skill levels.

---

## Monorepo Architecture

`iron_book` is structured into isolated layers within a single repository:

* **Backend (`/apps/api` or root Rust crate):** Built with Rust and Axum.
* **Web Frontend (`/apps/web`):** Built with Python and Django.
* **Docs Site (`/apps/home`):** Next.js with TypeScript.
* **Mobile (`/apps/mobile`):** Native Android application built with Kotlin.
* **Desktop (`/apps/...`):** Not decided yet.
* **Database:** PostgreSQL managed via SQLx migrations.

---

## Local Development Setup

Before contributing code, ensure you have the necessary runtime dependencies installed:

* **Mise**
* **Docker & Docker Compose**

---

## Development Workflow

### 1. Find or Create an Issue
Before diving into code, check the [Issue Tracker](https://github.com/Abled-Taha/iron_book/issues). 
* For existing open issues, leave a quick comment to let others know you are working on it.
* For new features or non-trivial fixes, please **open an issue first** to discuss the proposed changes.

### 2. Branch Naming Conventions
Create a descriptive branch from `main`:

* `feat/short-description` — for new features
* `fix/short-description` — for bug fixes
* `refactor/short-description` — for code cleanups
* `docs/short-description` — for documentation updates

*Example:* `feat/add-user-auth-endpoint`

### 3. Making Changes & Local Verification
Ensure all components you modified pass local compilation, type checks, and formatting rules prior to pushing:

#### Backend (Rust / Axum)
```bash
# Check syntax & types without full build
cargo check

# Enforce formatting and linting
cargo fmt --check
cargo clippy -- -D warnings

# Run test suite
cargo test
