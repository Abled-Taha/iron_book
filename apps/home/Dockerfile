# Use Node 24 to match your mise.toml configuration
FROM node:24-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

# Copy monorepo configuration and lockfiles first (for caching)
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/home/package.json ./apps/home/

# Install dependencies using pnpm's monorepo filtering
RUN pnpm install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Change working directory to the NextJS app and build it
WORKDIR /app/apps/home
RUN pnpm run build

EXPOSE 3000

# Start NextJS directly
CMD ["pnpm", "start"]