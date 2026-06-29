FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies (npm ci for reproducible installs)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build
COPY tsconfig.json build.mjs ./
COPY src ./src
RUN node build.mjs

# ── Production image ─────────────────────────────────────────
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Only install production deps
COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# Copy build output
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/index.mjs"]
